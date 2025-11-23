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
  bool _listExpanded = false; // Default to collapsed to focus on schedule
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
      if (mounted) setState(() => _lecturerEmails.addAll(mapped));
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
      backgroundColor: Colors.grey.shade50,
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
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.appBarColor,
        elevation: 0,
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          } else if (state is ScheduleFailure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
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
                      'Hata Oluştu',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.gradeRed),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<ScheduleBloc>().add(const LoadSchedule());
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tekrar Dene'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.appBarColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is ScheduleLoaded) {
            if (state.courses.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ders programınız bulunamadı.',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTodayCard(courses),
          const SizedBox(height: 20),
          _buildWeeklyScheduleCard(courses),
          const SizedBox(height: 20),
          _buildCourseListCard(courses, (context.read<ScheduleBloc>().state as ScheduleLoaded).registeredCourses),
        ],
      ),
    );
  }

  Widget _buildWeeklyScheduleCard(List<Course> courses) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: _weeklyExpanded,
          onExpansionChanged: (v) => setState(() => _weeklyExpanded = v),
          tilePadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.appBarColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.calendar_view_week, color: AppColors.appBarColor),
          ),
          title: const Text(
            'Haftalık Program',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: _buildScheduleTable(courses),
              ),
            ),
          ],
        ),
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

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
        dataRowColor: MaterialStateProperty.all(Colors.white),
        columnSpacing: 20,
        horizontalMargin: 16,
        border: TableBorder(
          horizontalInside: BorderSide(color: Colors.grey.shade200),
          verticalInside: BorderSide(color: Colors.grey.shade200),
        ),
        dataRowMinHeight: _compactView ? 48 : 60,
        dataRowMaxHeight: _compactView ? 64 : 80,
        columns: [
          const DataColumn(
            label: Text(
              'Saat',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          ...days.map((day) => DataColumn(
            label: Text(
              _abbrevDay(day),
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          )),
        ],
        rows: sortedTimes.map((time) {
          return DataRow(
            cells: [
              DataCell(
                Text(
                  time,
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54),
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
      ),
    );
  }

  Widget _buildCourseCell(Course? course) {
    if (course == null) {
      return const SizedBox(
        height: 50,
        child: Center(
          child: Text(
            '-',
            style: TextStyle(color: Colors.black12, fontSize: 20),
          ),
        ),
      );
    }

    final color = _colorForCourse(course.name);

    if (_compactView) {
      // Sade görünüm: renkli nokta + kısa ad
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              course.shortName,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    // Tam görünüm
    return Container(
      width: 120, // Fixed width for better table layout
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border(left: BorderSide(color: color, width: 4)),
        borderRadius: const BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            course.shortName,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color.withOpacity(1.0), // Ensure text is readable
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            course.classroom,
            style: TextStyle(
              fontSize: 10,
              color: Colors.black87.withOpacity(0.7),
              fontWeight: FontWeight.w500,
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
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: _listExpanded,
          onExpansionChanged: (v) => setState(() => _listExpanded = v),
          tilePadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.appBarColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.list_alt, color: AppColors.appBarColor),
          ),
          title: const Text(
            'Tüm Dersler',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _buildCourseChips(courses, registered),
              ),
            ),
          ],
        ),
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
      final color = _colorForCourse(name);

      final maxWidth = MediaQuery.of(context).size.width - 64;
      return ActionChip(
        elevation: 0,
        pressElevation: 2,
        backgroundColor: Colors.white,
        side: BorderSide(color: color.withOpacity(0.3)),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        label: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
        avatar: CircleAvatar(
          backgroundColor: color,
          radius: 10,
          child: const Icon(Icons.info_outline, color: Colors.white, size: 12),
        ),
        onPressed: () => _showCourseDetails(context, name, scheduleList, reg),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final byDay = <String, List<Course>>{};
        for (final c in scheduleList) {
          (byDay[c.day] ??= []).add(c);
        }
        
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _colorForCourse(name).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.menu_book, color: _colorForCourse(name), size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (reg != null) _buildCreditsSection(reg),
              if (reg != null) ...[
                const SizedBox(height: 20),
                _buildColorPicker(name),
              ],
              const SizedBox(height: 24),
              const Text('Ders Saatleri', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: byDay.entries.map((entry) {
                    final day = entry.key;
                    final times = entry.value.map((c) => '${c.time} (${c.classroom})').join(', ');
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text(day, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                          ),
                          Expanded(child: Text(times, style: const TextStyle(color: Colors.black54))),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  String _abbrevDay(String day) {
    switch (day) {
      case 'Pazartesi': return 'Paz';
      case 'Salı': return 'Sal';
      case 'Çarşamba': return 'Çar';
      case 'Perşembe': return 'Per';
      case 'Cuma': return 'Cum';
      case 'Cumartesi': return 'Cmt';
      case 'Pazar': return 'Paz';
      default: return day;
    }
  }

  Widget _buildCreditsSection(RegisteredCourse reg) {
    final email = _lecturerEmails[_normalizeLecturer(reg.lecturer)];
    final hasEmail = email != null && email.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ders Bilgileri', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _infoChip('Kod', reg.code),
              _infoChip('Kredi', reg.credit.toString()),
              _infoChip('AKTS', reg.ects.toString()),
              _infoChip('Şube', reg.subGroup),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.appBarColor.withOpacity(0.1),
                radius: 20,
                child: const Icon(Icons.person, size: 20, color: AppColors.appBarColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Öğretim Üyesi", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      reg.lecturer,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasEmail)
                IconButton(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: email));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.white),
                              const SizedBox(width: 12),
                              Expanded(child: Text('E-posta kopyalandı:\n$email')),
                            ],
                          ),
                          backgroundColor: Colors.green.shade600,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy, color: AppColors.appBarColor),
                  tooltip: 'E-postayı Kopyala',
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.appBarColor.withOpacity(0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
            ],
          ),
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
        const Text('Ders Rengi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _presetColors.map((c) {
            final selected = c.value == currentColor.value;
            return GestureDetector(
              onTap: () async {
                await context.read<StorageService>().saveCourseColor(normalized, c.value);
                await _loadSavedColors();
                if (mounted) setState(() {});
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? AppColors.appBarColor : Colors.transparent, 
                    width: selected ? 3 : 0
                  ),
                  boxShadow: [
                    BoxShadow(color: c.withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 2)),
                  ],
                ),
                child: selected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () async {
            await context.read<StorageService>().removeCourseColor(normalized);
            await _loadSavedColors();
            if (mounted) setState(() {});
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey.shade700,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
          icon: const Icon(Icons.restore),
          label: const Text('Varsayılan Renge Dön'),
        ),
      ],
    );
  }

  Widget _infoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(text: '$label: ', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700, fontSize: 12)),
            TextSpan(text: value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13)),
          ],
        ),
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
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: _todayExpanded,
          onExpansionChanged: (v) => setState(() => _todayExpanded = v),
          tilePadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.appBarColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.today, color: AppColors.appBarColor),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bugünün Dersleri',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                _abbrevDay(dayName),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: todays.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.event_available, color: Colors.grey.shade400),
                          const SizedBox(width: 12),
                          Text(
                            'Bugün dersiniz bulunmamaktadır.',
                            style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: todays.map((c) {
                        final color = _colorForCourse(c.name);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              width: 4,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            title: Text(
                              c.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            subtitle: Row(
                              children: [
                                Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Text(c.time, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                                const SizedBox(width: 16),
                                Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Text(c.classroom, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                              ],
                            ),
                            onTap: () => _openCourseByName(c.name),
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
