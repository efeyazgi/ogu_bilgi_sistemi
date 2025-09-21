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
      appBar: AppBar(
        title: const Text('GPA Hesaplama', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: AppColors.appBarColor,
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

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Önceki Genel Bilgiler',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _info('Önceki GNO', _prevGpa.toStringAsFixed(2)),
                    const SizedBox(width: 16),
                    _info('Toplam Kredi', _prevCredits.toString()),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('Genel ortalamaya ekle', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(width: 8),
                    Switch(value: _includeCumulative, onChanged: (v) => setState(() => _includeCumulative = v)),
                  ],
                )
              ],
            ),
          ),
        ),
        Card(
          child: ExpansionTile(
            initiallyExpanded: true,
            maintainState: true,
            title: Text('Dersler ve Not Seçimi', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: _courses.map(_buildCourseRow).toList(),
                ),
              ),
            ],
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sonuç', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(children: [
                  _info('Dönem Kredisi', termCredits.toString()),
                  const SizedBox(width: 16),
                  _info('Dönem Ort.', termGpa.isNaN ? '0.00' : termGpa.toStringAsFixed(2)),
                ]),
                const SizedBox(height: 8),
                if (_includeCumulative) Row(children: [
                  Text('Yeni GNO: ', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  Text(newCumulative.isNaN ? '0.00' : newCumulative.toStringAsFixed(2), style: const TextStyle(color: AppColors.appBarColor, fontWeight: FontWeight.w800)),
                ]),
                const SizedBox(height: 8),
                Card(
                  child: ExpansionTile(
                    initiallyExpanded: false,
                    title: const Text('Hızlı Simülasyon', style: TextStyle(fontWeight: FontWeight.w600)),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Wrap(
                          spacing: 8,
                          children: _letters.map((l) => OutlinedButton(
                            onPressed: () {
                              setState(() {
                                for (final c in _courses) { _selected[c.code] = l; }
                              });
                            },
                            child: Text('Tümü $l'),
                          )).toList(),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCourseRow(RegisteredCourse c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Uzun ders adlarını iki satırla ve elipsis ile göster.
                Text(
                  c.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text('Kredi: ${c.credit}', style: Theme.of(context).textTheme.bodyMedium),
                if (c.lecturer.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text('Öğr. Gör.: ${c.lecturer}', style: Theme.of(context).textTheme.bodySmall),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Sağ tarafta tek, kompakt bir dropdown kullan.
          SizedBox(
            width: 88,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selected[c.code],
                hint: const Text('Seçiniz'),
                isDense: true,
                items: _letters
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _selected[c.code] = v ?? 'FF'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _info(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        Text(value, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}