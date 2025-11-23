import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ogu_not_sistemi_v2/core/services/ogubs_service.dart';
import 'package:ogu_not_sistemi_v2/core/theme/app_colors.dart';
import 'package:ogu_not_sistemi_v2/core/services/storage_service.dart';
import '../../data/models/attendance_models.dart';
import '../../data/repository/attendance_repository.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  late final AttendanceRepository _repo;
  List<AttendanceCourse> _courses = [];
  Map<String, int> _used = {}; // code -> used slots
  int _weeks = 14;
  bool _loading = true;
  String? _error;

  // Ders renkleri (program sayfasındaki kayıtlardan)
  Map<String, int> _savedColorMap = {};
  final List<Color> _presetColors = const [
    Color(0xFF1976D2), // mavi
    Color(0xFF7B1FA2), // mor
    Color(0xFF388E3C), // yeşil
    Color(0xFFF57C00), // turuncu
    Color(0xFFD81B60), // pembe
    Color(0xFF00897B), // teal
    Color(0xFFFFB300), // amber
    Color(0xFF3F51B5), // indigo
  ];

  @override
  void initState() {
    super.initState();
    final ogubs = context.read<OgubsService>();
    final userId = ogubs.currentStudentNumber ?? 'default_user';
    _repo = AttendanceRepository(userId);
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final ogubs = context.read<OgubsService>();
      var courses = await _repo.loadCourses();
      if (courses.isEmpty) {
        courses = await _repo.buildCoursesFromRemote(ogubs);
      }
      _courses = courses;
      _weeks = await _repo.weeks();
      final allEntries = await _repo.loadEntries();
      // Renkler
      final storage = context.read<StorageService>();
      _savedColorMap = await storage.loadCourseColors();
      _used = {
        for (final c in _courses)
          c.code: allEntries.where((e) => e.courseCode == c.code).length
      };
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  Future<void> _openSettings() async {
    final weeksController = TextEditingController(text: _weeks.toString());
    double threshold = _courses.isNotEmpty ? _courses.first.thresholdRatio : 0.30;
    bool applyAll = true;
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Devamsızlık Ayarları'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Dönem Haftası'),
              const SizedBox(height: 4),
              TextField(
                controller: weeksController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'Örn: 14'),
              ),
              const SizedBox(height: 8),
              const Text('Devamsızlık hakkı varsayılanı: %30 (ders detayından değiştirilebilir)'),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
            ElevatedButton(
              onPressed: () async {
                final w = int.tryParse(weeksController.text.trim());
                if (w != null && w > 0) {
                  await _repo.setWeeks(w);
                }
                if (mounted) Navigator.pop(ctx);
                await _load();
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  Color _accentColor(double ratio) {
    if (ratio >= 1.0) return AppColors.gradeRed;
    if (ratio >= 0.8) return Colors.amber[700]!;
    return AppColors.appBarColor; // düşük oranlarda mor/ana renk
  }

  String _normalize(String s) => s
      .toUpperCase()
      .replaceAll('İ', 'I')
      .replaceAll('İ', 'I')
      .replaceAll('Ş', 'S')
      .replaceAll('Ğ', 'G')
      .replaceAll('Ü', 'U')
      .replaceAll('Ö', 'O')
      .replaceAll('Ç', 'C')
      .replaceAll(RegExp(r"\s+"), ' ')
      .trim();

  Color _courseColor(String name) {
    final normalized = _normalize(name);
    if (_savedColorMap.containsKey(normalized)) {
      return Color(_savedColorMap[normalized]!);
    }
    final hash = normalized.hashCode;
    final candidates = _presetColors;
    return candidates[hash.abs() % candidates.length];
  }

  Future<void> _openQuickAdd() async {
    if (_courses.isEmpty) return;
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return SafeArea(
          child: LayoutBuilder(
            builder: (context2, constraints) {
              final maxH = MediaQuery.of(context2).size.height * 0.8;
              return ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxH),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 6),
                      Container(height: 4, width: 40, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2))),
                      const SizedBox(height: 12),
                      Text('Ders seçin', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      ..._courses.map((c) => ListTile(
                            leading: const Icon(Icons.class_),
                            title: Text(c.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                            onTap: () async {
                              Navigator.pop(ctx);
                              await Navigator.of(context).push(MaterialPageRoute(builder: (_) => AttendanceDetailPage(course: c, repo: _repo)));
                              _load();
                            },
                          )),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _showCourseAbsences(AttendanceCourse c) async {
    final list = await _repo.entriesFor(c.code);
    // En yeni tarih/saati en üstte göster
    list.sort((a, b) {
      final da = DateTime.tryParse(a.date) ?? DateTime(1970);
      final db = DateTime.tryParse(b.date) ?? DateTime(1970);
      final cmp = db.compareTo(da);
      if (cmp != 0) return cmp;
      return b.time.compareTo(a.time);
    });

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setModalState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('Geçmiş devamsızlıklar', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 12),
                  if (list.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(child: Text('Kayıt bulunmuyor.')),
                    )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const Divider(height: 8),
                      itemBuilder: (_, i) {
                          final e = list[i];
                          final d = DateTime.tryParse(e.date);
                          final dateText = d != null ? DateFormat('dd.MM.yyyy EEEE', 'tr').format(d) : e.date;
                          // Aynı gün-saat için sınıf bilgisini bulmaya çalış
                          String? classroom;
                          if (d != null) {
                            for (final s in c.weeklySlots) {
                              if (s.dayOfWeek == d.weekday && s.time == e.time) {
                                classroom = s.classroom;
                                break;
                              }
                            }
                          }
                          return ListTile(
                            leading: const Icon(Icons.event_busy, color: Colors.redAccent),
                            title: Text('$dateText - ${e.time}'),
                            subtitle: classroom != null ? Text(classroom) : null,
                            onTap: () async {
                              // Düzenle: aynı gün için saat seçtir
                              if (d == null) return;
                              final daySlots = c.weeklySlots
                                  .where((s) => s.dayOfWeek == d.weekday)
                                  .map((s) => s.time)
                                  .toList()
                                ..sort();
                              String selected = e.time;
                              final changed = await showDialog<bool>(
                                context: context,
                                builder: (dctx) {
                                  return AlertDialog(
                                    title: const Text('Saat Düzelt'),
                                    content: StatefulBuilder(
                                      builder: (c2, setState2) {
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: daySlots.map((t) => RadioListTile<String>(
                                            title: Text(t),
                                            value: t,
                                            groupValue: selected,
                                            onChanged: (v) { if (v!=null) { selected = v; setState2((){});} },
                                          )).toList(),
                                        );
                                      },
                                    ),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(dctx, false), child: const Text('Vazgeç')),
                                      ElevatedButton(onPressed: () => Navigator.pop(dctx, true), child: const Text('Kaydet')),
                                    ],
                                  );
                                },
                              );
                              if (changed == true && selected != e.time) {
                                await _repo.toggleEntry(c.code, e.date, e.time); // eskiyi kaldır
                                await _repo.toggleEntry(c.code, e.date, selected); // yeniyi ekle
                                setModalState(() {
                                  list[i] = AttendanceEntry(courseCode: e.courseCode, date: e.date, time: selected, durationSlots: e.durationSlots, note: e.note);
                                });
                              }
                            },
                            onLongPress: () async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (dctx) => AlertDialog(
                                  title: const Text('Kayıt Silinsin mi?'),
                                  content: Text('$dateText - ${e.time} kaydı kaldırılacak.'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(dctx, false), child: const Text('İptal')),
                                    ElevatedButton(onPressed: () => Navigator.pop(dctx, true), child: const Text('Kaldır')),
                                  ],
                                ),
                              );
                              if (ok == true) {
                                await _repo.toggleEntry(c.code, e.date, e.time);
                                setModalState(() { list.removeAt(i); });
                              }
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devamsızlık', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.appBarColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(onPressed: _load, tooltip: 'Yenile', icon: const Icon(Icons.refresh)),
          IconButton(onPressed: _openSettings, tooltip: 'Ayarlar', icon: const Icon(Icons.settings)),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        heroTag: 'attendance_fab',
        tooltip: 'Hızlı Ekle',
        onPressed: _openQuickAdd,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Hata: $_error', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _load, child: const Text('Tekrar Dene')),
          ],
        ),
      );
    }

    if (_courses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.class_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Ders bulunamadı.', style: TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 8),
            const Text('Ders programı veya kayıtlı dersler alınamamış olabilir.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Yenile'),
            ),
          ],
        ),
      );
    }

    final bottomInset = MediaQuery.of(context).padding.bottom;
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(12, 12, 12, bottomInset + 160),
      itemCount: _courses.length,
      itemBuilder: (ctx, i) {
        final c = _courses[i];
        final weekly = c.weeklySlots.length;
        final total = weekly * _weeks;
        final allowed = (total * c.thresholdRatio).ceil();
        final used = _used[c.code] ?? 0;
        final ratio = total > 0 && allowed > 0 ? used / allowed : 0.0;
        final accent = _courseColor(c.name);

        return Card(
          elevation: 4,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _showCourseAbsences(c),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sol renk şeridi
                  Container(width: 6, height: 64, decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(4))),
                  const SizedBox(width: 12),
                  // İçerik
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                c.name,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text('${(ratio * 100).clamp(0, 999).toStringAsFixed(0)}%', style: TextStyle(fontWeight: FontWeight.w800, color: accent)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyMedium,
                            children: [
                              const TextSpan(text: 'Haftalık Ders: '),
                              TextSpan(text: '$weekly', style: TextStyle(color: accent, fontWeight: FontWeight.w600)),
                              const TextSpan(text: '  |  Kaçırılan: '),
                              TextSpan(text: '$used', style: TextStyle(color: accent, fontWeight: FontWeight.w600)),
                              const TextSpan(text: '  |  Devamsızlık hakkı: '),
                              TextSpan(text: '$allowed', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w700)),
                              const TextSpan(text: '  |  Kalan Hak: '),
                              TextSpan(text: '${allowed - used < 0 ? 0 : allowed - used}', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: ratio.isNaN ? 0 : ratio.clamp(0.0, 1.0),
                          backgroundColor: Colors.grey.shade300,
                          color: accent,
                        ),
                        if (allowed > 0 && ratio >= 0.8) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(ratio >= 1.0 ? Icons.error_outline : Icons.warning_amber_rounded, size: 18, color: accent),
                              const SizedBox(width: 8),
                              Text(
                                ratio >= 1.0 ? 'Devamsızlık limitini aştınız!' : 'Limiti aşmaya yakınsınız.',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: accent, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () async {
                      await Navigator.of(context).push(MaterialPageRoute(builder: (_) => AttendanceDetailPage(course: c, repo: _repo)));
                      _load();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class AttendanceDetailPage extends StatefulWidget {
  final AttendanceCourse course;
  final AttendanceRepository repo;
  const AttendanceDetailPage({super.key, required this.course, required this.repo});

  @override
  State<AttendanceDetailPage> createState() => _AttendanceDetailPageState();
}

class _AttendanceDetailPageState extends State<AttendanceDetailPage> {
  DateTime _date = DateTime.now();
  List<AttendanceEntry> _entries = [];
  Map<String, bool> _localMarked = {}; // seçili gün için geçici durum

  // Tekrarlı oluşturmayı azaltmak için tarih formatlayıcılarını önceden hazırla
  final DateFormat _ymd = DateFormat('yyyy-MM-dd');
  final DateFormat _humanTr = DateFormat('dd.MM.yyyy EEEE', 'tr');

  // CalendarDatePicker'da initialDate, selectableDayPredicate'i mutlaka sağlamalı.
  // Aksi halde Flutter assert hatası oluşur. Bu yardımcı fonksiyon, bugün veya
  // bugünden geriye doğru en yakın uygun günü döndürür.
  DateTime _nearestAllowedInitialDate(Set<int> allowedWeekdays) {
    final now = DateTime.now();
    var d = _date;
    
    // Eğer allowedWeekdays boşsa (manuel ders), her gün seçilebilir, o yüzden direkt d veya now döndür.
    if (allowedWeekdays.isEmpty) {
       if (d.isAfter(now)) return DateTime(now.year, now.month, now.day);
       return DateTime(d.year, d.month, d.day);
    }

    if (d.isAfter(now) || !allowedWeekdays.contains(d.weekday)) {
      d = now;
      // Maksimum 7 adım geri gitmek yeterlidir (haftanın tüm günleri).
      for (int i = 0; i < 7; i++) {
        if (!d.isAfter(now) && allowedWeekdays.contains(d.weekday)) {
          return DateTime(d.year, d.month, d.day);
        }
        d = d.subtract(const Duration(days: 1));
      }
      // Hiçbiri bulunamazsa güvenli varsayılan olarak today'i döndür.
      return DateTime(now.year, now.month, now.day);
    }
    return DateTime(d.year, d.month, d.day);
  }

  @override
  void initState() {
    super.initState();
    _load().then((_) => _rebuildLocalMarked());
  }

  Future<void> _load() async {
    final list = await widget.repo.entriesFor(widget.course.code);
    if (mounted) setState(() => _entries = list);
  }

  void _rebuildLocalMarked() {
    final keyDate = _ymd.format(_date);
    _localMarked.clear();
    for (final s in widget.course.weeklySlots.where((e) => e.dayOfWeek == _date.weekday)) {
      final exists = _entries.any((e) => e.courseCode == widget.course.code && e.date == keyDate && e.time == s.time);
      _localMarked[s.time] = exists;
    }
    if (mounted) setState(() {});
  }

  void _toggleLocal(String time) {
    if (_date.isAfter(DateTime.now())) return;
    _localMarked[time] = !(_localMarked[time] ?? false);
    setState(() {});
  }

  Future<void> _saveForDay() async {
    final keyDate = _ymd.format(_date);

    int toAdd = 0;
    int toRemove = 0;
    for (final entry in _localMarked.entries) {
      final exists = _entries.any((e) => e.courseCode == widget.course.code && e.date == keyDate && e.time == entry.key);
      if (entry.value && !exists) toAdd++;
      if (!entry.value && exists) toRemove++;
    }

    if (toAdd == 0 && toRemove == 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Değişiklik yok.')));
      }
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final human = _humanTr.format(_date);
        return AlertDialog(
          title: const Text('Kaydet Onayı'),
          content: Text('$human günü için eklenecek: $toAdd, kaldırılacak: $toRemove. Devam edilsin mi?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Onayla')),
          ],
        );
      },
    );
    if (confirmed != true) return;

    for (final entry in _localMarked.entries) {
      final exists = _entries.any((e) => e.courseCode == widget.course.code && e.date == keyDate && e.time == entry.key);
      if (entry.value && !exists) {
        await widget.repo.toggleEntry(widget.course.code, keyDate, entry.key);
      } else if (!entry.value && exists) {
        await widget.repo.toggleEntry(widget.course.code, keyDate, entry.key);
      }
    }

    await _load();
    _rebuildLocalMarked();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Değişiklikler kaydedildi.')));
    }
  }

  Future<void> _addManualEntry() async {
    // Manuel ekleme için saat seçimi
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked == null) return;

    final timeStr = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    final keyDate = _ymd.format(_date);
    
    // Zaten var mı?
    final exists = _entries.any((e) => e.courseCode == widget.course.code && e.date == keyDate && e.time == timeStr);
    if (exists) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bu saatte zaten kayıt var.')));
      return;
    }

    await widget.repo.toggleEntry(widget.course.code, keyDate, timeStr);
    await _load();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kayıt eklendi.')));
  }

  Future<void> _openCourseThreshold() async {
    double threshold = widget.course.thresholdRatio;
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Ders İçin İzin Oranı'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('İzin oranı'),
                  const SizedBox(width: 8),
                  Text('${(threshold * 100).toStringAsFixed(0)}%'),
                ],
              ),
              Slider(
                min: 0.10,
                max: 0.50,
                divisions: 40,
                value: threshold,
                onChanged: (v) {
                  threshold = v;
                  (ctx as Element).markNeedsBuild();
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
            ElevatedButton(
              onPressed: () async {
                await widget.repo.updateCourseThreshold(widget.course.code, threshold);
                if (mounted) Navigator.pop(ctx);
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dayDow = _date.weekday; // 1..7
    final daySlots = widget.course.weeklySlots.where((s) => s.dayOfWeek == dayDow).toList()..sort((a,b) => a.time.compareTo(b.time));
    
    // Manuel eklenenleri de bu listede gösterelim (eğer slotlarda yoksa)
    final keyDate = _ymd.format(_date);
    final manualEntriesForDay = _entries.where((e) => e.date == keyDate && !daySlots.any((s) => s.time == e.time)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course.name, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.appBarColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            tooltip: 'Devamsızlık sınırı',
            icon: const Icon(Icons.percent),
            onPressed: _openCourseThreshold,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Gün Seç', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Builder(builder: (context) {
                    final allowed = widget.course.weeklySlots.map((e) => e.dayOfWeek).toSet();
                    final init = _nearestAllowedInitialDate(allowed);
                    return CalendarDatePicker(
                      firstDate: DateTime(DateTime.now().year - 1),
                      lastDate: DateTime.now(),
                      initialDate: init,
                      selectableDayPredicate: (day) {
                        if (allowed.isEmpty) return !day.isAfter(DateTime.now());
                        return !day.isAfter(DateTime.now()) && allowed.contains(day.weekday);
                      },
                      onDateChanged: (d) {
                        setState(() => _date = d);
                        _rebuildLocalMarked();
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
          Card(
            child: ExpansionTile(
              initiallyExpanded: true,
              maintainState: true,
              title: const Text('Bugünün Slotları', style: TextStyle(fontWeight: FontWeight.bold)),
              children: [
                if (daySlots.isEmpty && manualEntriesForDay.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text('Seçilen günde bu ders için programda slot yok.'),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _addManualEntry,
                          icon: const Icon(Icons.add),
                          label: const Text('Manuel Ekle'),
                        ),
                      ],
                    ),
                  )
                else ...[
                   // Programdaki slotlar
                   ...daySlots.map((s) {
                    final marked = _localMarked[s.time] ?? false;
                    return SwitchListTile(
                      title: Text('${s.time}  •  ${s.classroom}'),
                      subtitle: const Text('Gitmedim olarak işaretle'),
                      value: marked,
                      onChanged: (_) => _toggleLocal(s.time),
                    );
                  }),
                  // Manuel eklenenler
                  if (manualEntriesForDay.isNotEmpty) ...[
                    const Divider(),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text('Manuel Eklenenler', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    ),
                    ...manualEntriesForDay.map((e) => ListTile(
                      leading: const Icon(Icons.edit_calendar, color: Colors.orange),
                      title: Text('${e.time}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await widget.repo.toggleEntry(widget.course.code, e.date, e.time);
                          await _load();
                        },
                      ),
                    )),
                  ],
                  if (daySlots.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                for (final s in daySlots) {
                                  _localMarked[s.time] = true;
                                }
                                setState(() {});
                              },
                              icon: const Icon(Icons.event_busy),
                              label: const Text('Tümünü Seç'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: _saveForDay,
                            icon: const Icon(Icons.save),
                            label: const Text('Kaydet'),
                          ),
                        ],
                      ),
                    ),
                  if (daySlots.isNotEmpty)
                     Padding(
                       padding: const EdgeInsets.only(bottom: 16.0),
                       child: TextButton.icon(
                         onPressed: _addManualEntry,
                         icon: const Icon(Icons.add),
                         label: const Text('Program Dışı Saat Ekle'),
                       ),
                     ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
