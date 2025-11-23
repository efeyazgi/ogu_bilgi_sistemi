import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogu_not_sistemi_v2/core/services/ogubs_service.dart';
import 'package:ogu_not_sistemi_v2/core/theme/app_colors.dart';
import 'package:ogu_not_sistemi_v2/features/schedule/data/models/registered_course.dart';

class GpaPage extends StatefulWidget {
  const GpaPage({super.key});

  @override
  State<GpaPage> createState() => _GpaPageState();
}

class _GpaPageState extends State<GpaPage> {
  bool _includeCumulative = true; // Genel ortalamaya ekle seçeneği
  double _prevGpa = 0.0;
  int _prevCredits = 0;

  List<RegisteredCourse> _courses = [];
  final Map<String, String> _selected = {}; // code -> letter

  static const Map<String, double> _letterPoints = {
    'AA': 4.0,
    'BA': 3.5,
    'BB': 3.0,
    'CB': 2.5,
    'CC': 2.0,
    'DC': 1.5,
    'DD': 1.0,
    'FD': 0.5,
    'FF': 0.0,
  };
  static const List<String> _letters = [
    'AA','BA','BB','CB','CC','DC','DD','FD','FF'
  ];

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final ogubs = context.read<OgubsService>();
      final summary = await ogubs.fetchSummaryData();
      _prevGpa = double.tryParse((summary['gpa'] ?? '0').toString().replaceAll(',', '.')) ?? 0.0;
      _prevCredits = int.tryParse((summary['credits'] ?? '0').toString()) ?? 0;

      final regs = await ogubs.fetchRegisteredCourses();
      regs.sort((a,b) => a.name.compareTo(b.name));
      _courses = regs.where((c) => c.credit > 0).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('GPA Hesaplama', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppColors.appBarColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(onPressed: _load, tooltip: 'Yenile', icon: const Icon(Icons.refresh))
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Hata: $_error', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.gradeRed)),
      ));
    }

    final termCredits = _courses.fold<int>(0, (sum, c) => sum + c.credit);
    final termPoints = _courses.fold<double>(0.0, (sum, c) {
      final letter = _selected[c.code];
      if (letter == null) return sum;
      final p = _letterPoints[letter] ?? 0.0;
      return sum + c.credit * p;
    });

    final termGpa = termCredits > 0 ? termPoints / termCredits : 0.0;

    final prevPoints = _prevGpa * _prevCredits;
    final newPoints = prevPoints + termPoints;
    final newCredits = _prevCredits + termCredits;
    final newCumulative = newCredits > 0 ? newPoints / newCredits : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPreviousInfoCard(),
          const SizedBox(height: 16),
          _buildCourseListCard(),
          const SizedBox(height: 16),
          _buildResultCard(termCredits, termGpa, newCumulative),
          const SizedBox(height: 16),
          _buildQuickSimulationCard(),
          const SizedBox(height: 32), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildPreviousInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Mevcut Durum', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                Switch(
                  value: _includeCumulative, 
                  onChanged: (v) => setState(() => _includeCumulative = v),
                  activeColor: AppColors.primary,
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoColumn('Mevcut GNO', _prevGpa.toStringAsFixed(2), isLarge: true),
                _buildInfoColumn('Top. Kredi', _prevCredits.toString(), isLarge: true),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                _includeCumulative ? 'Genel ortalamaya dahil ediliyor' : 'Sadece dönem hesabı',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseListCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.list_alt, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text('Dersler ve Notlar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('${_courses.length} Ders', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _courses.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) => _buildCourseRow(_courses[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(int termCredits, double termGpa, double newCumulative) {
    return Card(
      elevation: 4,
      color: AppColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text('HESAPLANAN SONUÇ', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildResultItem('Dönem Ort.', termGpa.isNaN ? '0.00' : termGpa.toStringAsFixed(2)),
                Container(width: 1, height: 40, color: Colors.white24),
                _buildResultItem('Dönem Kredi', termCredits.toString()),
              ],
            ),
            if (_includeCumulative) ...[
              const SizedBox(height: 20),
              const Divider(color: Colors.white24),
              const SizedBox(height: 10),
              const Text('YENİ GENEL NOT ORTALAMASI', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 4),
              Text(
                newCumulative.isNaN ? '0.00' : newCumulative.toStringAsFixed(2),
                style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildQuickSimulationCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hızlı Simülasyon', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Tüm derslerin notunu tek tıkla değiştirin', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _letters.map((l) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ActionChip(
                    label: Text(l),
                    onPressed: () {
                      setState(() {
                        for (final c in _courses) { _selected[c.code] = l; }
                      });
                    },
                    backgroundColor: Colors.grey[100],
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseRow(RegisteredCourse c) {
    final isSelected = _selected[c.code] != null;
    return Container(
      color: isSelected ? AppColors.primary.withOpacity(0.05) : null,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.name,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('${c.credit} Kredi', style: TextStyle(color: Colors.grey[700], fontSize: 10)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isSelected ? AppColors.primary : Colors.grey[300]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selected[c.code],
                hint: const Text('Seç', style: TextStyle(fontSize: 14)),
                icon: const Icon(Icons.arrow_drop_down, size: 20),
                isDense: true,
                items: _letters
                    .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontWeight: FontWeight.bold))))
                    .toList(),
                onChanged: (v) => setState(() => _selected[c.code] = v ?? 'FF'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, {bool isLarge = false}) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isLarge ? 20 : 16,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}