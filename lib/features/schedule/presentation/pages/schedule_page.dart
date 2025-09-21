import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogu_not_sistemi_v2/core/theme/app_colors.dart';
import 'package:ogu_not_sistemi_v2/core/services/storage_service.dart';
import 'package:flutter/services.dart' show rootBundle, Clipboard, ClipboardData;
import '../../data/models/course_model.dart';
import '../../data/models/registered_course.dart';
import '../bloc/schedule_bloc.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  bool _weeklyExpanded = true;
  bool _todayExpanded = true;
  bool _listExpanded = true;
  bool _compactView = false; // Sade/Tam görünüm
  Map<String, int> _savedColorMap = {}; // normalizedName -> ARGB
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

  // İsteğe bağlı: hoca e-posta eşlemesi (JSON'dan yüklenecek)
  final Map<String, String> _lecturerEmails = {
    'BELGIN KARABACAKOGLU': 'bkarabac@ogu.edu.tr',
    'NESE OZTURK': 'nozturk@ogu.edu.tr',
    'DEMET TOPALOGLU YAZICI': 'demett@ogu.edu.tr',
    'ILKNUR DEMIRAL': 'idemiral@ogu.edu.tr',
    'HILAL DEMIR KIVRAK': 'hilaldemir.kivrak@ogu.edu.tr',
    'MUSA SOLENER': 'msolener@ogu.edu.tr',
    'CEYDA BILGIC': 'cbilgic@ogu.edu.tr',
    'CANAN SAMDAN': 'caydin@ogu.edu.tr',
    'FIRAT YILMAZ': 'firat.yilmaz@ogu.edu.tr',
    'SEVGI SENSOZ': 'ssensoz@ogu.edu.tr',
    'AYSEGUL ASKIN': 'taskin@ogu.edu.tr',
    'MINE OZDEMIR': 'mnozdemi@ogu.edu.tr',
    'HAKAN DEMIRAL': 'hdemiral@ogu.edu.tr',
    'FATMA TUMSEK': 'ftumsek@ogu.edu.tr',
    'ILKER KIPCAK': 'ikipcak@ogu.edu.tr',
    'UGUR MORALI': 'umorali@ogu.edu.tr',
    'SEDA HOSGUN': 'serol@ogu.edu.tr',
    'BEGUM NISA TOSUN': 'begum.tosun@ogu.edu.tr',
    'ALIME CITAK': 'acitak@ogu.edu.tr',
    'DUYGU KAVAK': 'dbayar@ogu.edu.tr',
    'YELIZ ASCI': 'yelizbali26@gmail.com',
    'MACID NURBAS': 'mnurbas@gmail.com',
    'SALIM EROL': 'salimerol@ufl.edu',
    'SEFIKA KAYA': 'sefikakaya@ogu.edu.tr',
    'UGUR SELENGIL': 'uselen@ogu.edu.tr',
    'DERYA YILDIZ': 'dozeren@ogu.edu.tr',
    'MURAT DOGRU': 'mdogru@ogu.edu.tr',
    'BERAY ALYAKUT': 'beray.alyakut@ogu.edu.tr',
  }; // normalizedName -> email
  @override
  void initState() {
    super.initState();
    // Renkleri yükle ve programı çek
    _loadSavedColors();
    _loadLecturerEmails();
    context.read<ScheduleBloc>().add(const LoadSchedule());
  }

  Future<void> _loadLecturerEmails() async {
    try {
      final raw = await rootBundle.loadString('assets/data/lecturer_emails.json');
      final Map<String, dynamic> json = convert.jsonDecode(raw);
      final mapped = <String, String>{};
      for (final entry in json.entries) {
        final normalized = _normalizeLecturer(entry.key.toString());
        mapped[normalized] = entry.value.toString();
      }
      if (mounted) {
        setState(() => _lecturerEmails
          ..clear()
          ..addAll(mapped));
      }
    } catch (_) {
      // JSON okunamadıysa sessiz geç
    }
  }

  Future<void> _loadSavedColors() async {
    final storage = context.read<StorageService>();
    final map = await storage.loadCourseColors();
    if (mounted) {
      setState(() => _savedColorMap = map);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Image.asset(
            'assets/images/app_logo.png',
            width: 40,
            height: 40,
          ),
        ),
        title: const Text(
          "Ders Programı",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: AppColors.appBarColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(_compactView ? Icons.view_agenda : Icons.grid_on),
            tooltip: _compactView ? 'Tam Görünüm' : 'Sade Görünüm',
            onPressed: () => setState(() => _compactView = !_compactView),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Yenile',
            onPressed: () {
              context.read<ScheduleBloc>().add(const LoadSchedule());
            },
          ),
        ],
      ),
      body: BlocBuilder<ScheduleBloc, ScheduleState>(
        builder: (context, state) {
          if (state is ScheduleLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Ders programı yükleniyor...',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          } else if (state is ScheduleFailure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.gradeRed,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Hata:\n${state.message}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.gradeRed,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ScheduleBloc>().add(const LoadSchedule());
                      },
                      child: const Text('Tekrar Dene'),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is ScheduleLoaded) {
            if (state.courses.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Ders programınız bulunamadı.',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }
            
            return _buildScheduleView(state.courses);
          }
          
          return const Center(
            child: Text(
              'Ders programı için oturum açmanız gerekiyor.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
    );
  }

  Widget _buildScheduleView(List<Course> courses) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          _buildTodayCard(courses),
          const SizedBox(height: 16),
          _buildWeeklyScheduleCard(courses),
          const SizedBox(height: 16),
          _buildCourseListCard(courses, (context.read<ScheduleBloc>().state as ScheduleLoaded).registeredCourses),
        ],
      ),
    );
  }

  Widget _buildWeeklyScheduleCard(List<Course> courses) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        initiallyExpanded: _weeklyExpanded,
        maintainState: true,
        onExpansionChanged: (v) => setState(() => _weeklyExpanded = v),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        leading: const Icon(Icons.calendar_view_week, color: AppColors.appBarColor),
        title: const Text(
          'Haftalık Program',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.appBarColor,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _buildScheduleTable(courses),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTable(List<Course> courses) {
    final Map<String, Map<String, Course>> schedule = {};
    final Set<String> allTimes = {};

    // Organize courses by time and day
    for (var course in courses) {
      allTimes.add(course.time);
      if (!schedule.containsKey(course.time)) {
        schedule[course.time] = {};
      }
      schedule[course.time]![course.day] = course;
    }

    // Sort times
    final sortedTimes = allTimes.toList()..sort();
    
    const days = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];

    return DataTable(
      border: TableBorder.all(color: Colors.grey.shade300),
      headingRowColor: WidgetStateProperty.all(AppColors.appBarColor.withValues(alpha: 0.1)),
      // Ensure min height is not greater than max height to avoid non-normalized constraints
      dataRowMinHeight: _compactView ? 40 : 48,
      dataRowMaxHeight: _compactView ? 56 : 72,
      columns: [
        const DataColumn(
          label: Text(
            'Saat',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        ...days.map((day) => DataColumn(
          label: Text(
            _abbrevDay(day),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        )),
      ],
      rows: sortedTimes.map((time) {
        return DataRow(
          cells: [
            DataCell(
              Text(
                time,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            ...days.map((day) {
              final course = schedule[time]?[day];
              return DataCell(
                _buildCourseCell(course),
                onTap: course == null
                    ? null
                    : () => _openCourseByName(course.name),
              );
            }),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildCourseCell(Course? course) {
    if (course == null) {
      return const SizedBox(
        height: 50,
        child: Center(
          child: Text(
            '-',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final color = _colorForCourse(course.name);

    if (_compactView) {
      // Sade görünüm: renkli nokta + kısa ad
      return Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              course.shortName,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    // Tam görünüm
    return Container(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      padding: const EdgeInsets.only(left: 6, top: 2, bottom: 2, right: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            course.shortName,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            course.classroom,
            style: const TextStyle(
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _colorForCourse(String name) {
    final normalized = _normalize(name);
    if (_savedColorMap.containsKey(normalized)) {
      return Color(_savedColorMap[normalized]!);
    }
    // Deterministic fallback color from name hash
    final hash = normalized.hashCode;
    final candidates = _presetColors;
    return candidates[hash.abs() % candidates.length];
  }

  Widget _buildCourseListCard(List<Course> courses, List<RegisteredCourse> registered) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        initiallyExpanded: _listExpanded,
        maintainState: true,
        onExpansionChanged: (v) => setState(() => _listExpanded = v),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        leading: const Icon(Icons.list, color: AppColors.appBarColor),
        title: const Text(
          'Ders Listesi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.appBarColor,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _buildCourseChips(courses, registered),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCourseChips(List<Course> courses, List<RegisteredCourse> registered) {
    final byName = <String, List<Course>>{};
    for (final c in courses) {
      (byName[c.name] ??= []).add(c);
    }

    final regByNormalized = {for (final r in registered) r.normalizedName: r};

    return byName.entries.map((e) {
      final name = e.key;
      final scheduleList = e.value;
      final normalized = _normalize(name);
      final reg = regByNormalized[normalized];

      final maxWidth = MediaQuery.of(context).size.width - 64;
      return Tooltip(
        message: name,
        child: ActionChip(
          label: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.appBarColor, fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
          avatar: const Icon(Icons.info_outline, color: AppColors.appBarColor, size: 18),
          onPressed: () => _showCourseDetails(context, name, scheduleList, reg),
          backgroundColor: Colors.grey.shade100,
          shape: StadiumBorder(side: BorderSide(color: Colors.grey.shade300)),
        ),
      );
    }).toList();
  }

  void _openCourseByName(String name) {
    final state = context.read<ScheduleBloc>().state;
    if (state is! ScheduleLoaded) return;
    final courses = state.courses.where((c) => c.name == name).toList();
    final regMap = {for (final r in state.registeredCourses) r.normalizedName: r};
    final reg = regMap[_normalize(name)];
    _showCourseDetails(context, name, courses, reg);
  }

  void _showCourseDetails(BuildContext context, String name, List<Course> scheduleList, RegisteredCourse? reg) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        // Group schedule by day
        final byDay = <String, List<Course>>{};
        for (final c in scheduleList) {
          (byDay[c.day] ??= []).add(c);
        }
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.menu_book, color: AppColors.appBarColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.appBarColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (reg != null) _buildCreditsSection(reg),
                if (reg != null) ...[
                  const SizedBox(height: 12),
                  _buildColorPicker(name),
                ],
                const SizedBox(height: 12),
                const Text('Ders Saatleri', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ...byDay.entries.map((entry) {
                  final day = entry.key;
                  final times = entry.value.map((c) => '${c.time} (${c.classroom})').join(', ');
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 100,
                          child: Text(day, style: const TextStyle(fontWeight: FontWeight.w500)),
                        ),
                        Expanded(child: Text(times)),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  String _abbrevDay(String day) {
    switch (day) {
      case 'Pazartesi':
        return 'Paz';
      case 'Salı':
        return 'Sal';
      case 'Çarşamba':
        return 'Çar';
      case 'Perşembe':
        return 'Per';
      case 'Cuma':
        return 'Cum';
      case 'Cumartesi':
        return 'Cmt';
      case 'Pazar':
        return 'Paz';
      default:
        return day;
    }
  }

  Widget _buildCreditsSection(RegisteredCourse reg) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                Text('Ders Bilgileri', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _infoChip('Kod', reg.code),
              _infoChip('Teori', reg.theory.toString()),
              _infoChip('Uygulama', reg.practice.toString()),
              _infoChip('Kredi', reg.credit.toString()),
              _infoChip('AKTS', reg.ects.toString()),
              _infoChip('Şube', reg.subGroup),
            ],
          ),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.person, size: 18, color: AppColors.appBarColor),
            const SizedBox(width: 6),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final email = _lecturerEmails[_normalizeLecturer(reg.lecturer)] ?? '';
                  if (email.isEmpty) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Bu öğretim üyesi için e-posta kaydı bulunamadı.'),
                          backgroundColor: Colors.orange,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                    return;
                  }
                  
                  // E-posta adresini panoya kopyala
                  try {
                    await Clipboard.setData(ClipboardData(text: email));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('E-posta adresi kopyalandı: $email'),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 3),
                          action: SnackBarAction(
                            label: 'TAMAM',
                            textColor: Colors.white,
                            onPressed: () {},
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('E-posta kopyalanamadı'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: Text(
                  reg.lecturer,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    decoration: (_lecturerEmails[_normalizeLecturer(reg.lecturer)] ?? '').isNotEmpty
                        ? TextDecoration.underline
                        : TextDecoration.none,
                  ),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildColorPicker(String courseName) {
    final normalized = _normalize(courseName);
    final currentColor = _colorForCourse(courseName);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Renk', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _presetColors.map((c) {
final selected = c.toARGB32() == currentColor.toARGB32();
            return GestureDetector(
              onTap: () async {
await context.read<StorageService>().saveCourseColor(normalized, c.toARGB32());
                await _loadSavedColors();
                if (mounted) setState(() {});
              },
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: Border.all(color: selected ? AppColors.appBarColor : Colors.white, width: 2.5),
                  boxShadow: [
                    if (selected)
                      BoxShadow(color: AppColors.appBarColor.withValues(alpha: 0.25), blurRadius: 6, spreadRadius: 0.5),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () async {
              await context.read<StorageService>().removeCourseColor(normalized);
              await _loadSavedColors();
              if (mounted) setState(() {});
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.appBarColor,
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
            icon: const Icon(Icons.restore_outlined),
            label: const Text('Rengi Sıfırla'),
          ),
        ),
      ],
    );
  }

  Widget _infoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value),
        ],
      ),
    );
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

  String _normalizeLecturer(String s) {
    final titles = [
      'PROF. DR.', 'DOÇ. DR.', 'DOC. DR.', 'DR. ÖĞR. ÜYESİ', 'DR. OGR. UYESI',
      'ARAŞ. GÖR.', 'ARŞ. GÖR.', 'ARAS. GOR.', 'ARS. GOR.', 'ÖĞR. GÖR.', 'OGR. GOR.'
    ];
    var up = _normalize(s);
    // Noktalama kaldır
    up = up.replaceAll('.', ' ').replaceAll(',', ' ');
    // Ünvanları temizle
    for (final t in titles) {
      up = up.replaceAll(t, ' ');
    }
    // Fazla boşlukları tekilleştir
    up = up.replaceAll(RegExp(r"\s+"), ' ').trim();
    return up;
  }

  Widget _buildTodayCard(List<Course> courses) {
    final weekday = DateTime.now().weekday; // 1=Mon
    final dayName = const ['Pazartesi','Salı','Çarşamba','Perşembe','Cuma','Cumartesi','Pazar'][weekday-1];
    final todays = courses.where((c) => c.day == dayName).toList()
      ..sort((a, b) => a.time.compareTo(b.time));

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        initiallyExpanded: _todayExpanded,
        onExpansionChanged: (v) => setState(() => _todayExpanded = v),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        leading: const Icon(Icons.today, color: AppColors.appBarColor),
        title: Text(
          'Bugünün Dersleri (${_abbrevDay(dayName)})',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.appBarColor,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: todays.isEmpty
                ? const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Bugün dersiniz bulunmamaktadır.'),
                  )
                : Column(
                    children: todays
                        .map((c) => ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(radius: 8, backgroundColor: _colorForCourse(c.name)),
                              title: Text(c.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
subtitle: Text('${c.time}  •  ${c.classroom}', style: const TextStyle(fontSize: 12)),
                              onTap: () => _openCourseByName(c.name),
                            ))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
