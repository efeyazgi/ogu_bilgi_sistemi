import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogu_not_sistemi_v2/features/grades/presentation/bloc/grade_details_cubit.dart';
import 'package:ogu_not_sistemi_v2/core/theme/app_colors.dart'; // AppColors import edildi
import 'package:ogu_not_sistemi_v2/core/theme/app_theme.dart'; // AppTheme import edildi (getGradeColor için)
import 'package:ogu_not_sistemi_v2/features/grades/data/models/course_grade_model.dart';
import 'package:ogu_not_sistemi_v2/features/grades/data/models/grade_details_model.dart';

// Ham not dizesini ("YAZILI (%35): 100") ayrıştırmak için bir model.
class _GradeComponent {
  final String type;
  final String weight;
  final String grade;
  final String? url;

  _GradeComponent({
    required this.type,
    required this.weight,
    required this.grade,
    this.url,
  });

  static List<_GradeComponent> fromRawString(String raw) {
    if (raw.trim().isEmpty || raw.trim() == "Veri Yok") return [];

    // "ÖDEV (%20):90|URL, QUIZ (%10):95" gibi virgülle veya yeni satırla ayrılmış
    final parts = raw.split(RegExp(r'[,\n]'));
    return parts.map((part) {
      String temp = part.trim();
      String? url;
      
      // URL'i ayıkla
      if (temp.contains('|')) {
        final split = temp.split('|');
        temp = split[0].trim();
        if (split.length > 1) url = split[1].trim();
      }

      String type = '-';
      String weight = '-';
      String grade = '-';

      // Ağırlığı ayıkla -> "(%35)"
      final weightMatch = RegExp(r'\(%\d+\)').firstMatch(temp);
      if (weightMatch != null) {
        weight = weightMatch.group(0)!;
        temp = temp.replaceFirst(weight, '').trim();
      }

      // Sınav türünü ayıkla -> "YAZILI"
      final typeMatch = RegExp(r'^[A-ZÖÇŞİĞÜ]+').firstMatch(temp);
      if (typeMatch != null) {
        type = typeMatch.group(0)!;
        temp = temp.replaceFirst(type, '').trim();
      }

      // Geriye kalanı not olarak al
      temp = temp.replaceAll(':', '').trim();
      if (temp.isNotEmpty) {
        grade = temp;
      }

      return _GradeComponent(type: type, weight: weight, grade: grade, url: url);
    }).toList();
  }
}

class CourseInfoCard extends StatelessWidget {
  final CourseGradeModel course;
  final String? gpa;

  const CourseInfoCard({super.key, required this.course, this.gpa});

  // Tablo için satırları oluşturan yardımcı metot
  List<TableRow> _buildGradeTableRows(
    BuildContext context,
    String label,
    String rawValue,
    TextStyle style,
  ) {
    final components = _GradeComponent.fromRawString(rawValue);
    if (components.isEmpty) return [];

    return components.map((c) {
      Widget gradeWidget = Text(
        c.grade,
        style: style.copyWith(fontWeight: FontWeight.bold),
      );

      if (c.url != null) {
        gradeWidget = InkWell(
          onTap: () {
            context.read<GradeDetailsCubit>().fetchDetails(c.url!);
            showDialog(
              context: context,
              builder: (context) => Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: BlocBuilder<GradeDetailsCubit, GradeDetailsState>(
                  builder: (context, state) {
                    if (state is GradeDetailsLoading) {
                      return const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text("Detaylar yükleniyor..."),
                          ],
                        ),
                      );
                    } else if (state is GradeDetailsError) {
                      return Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 48),
                            const SizedBox(height: 16),
                            Text("Hata: ${state.message}"),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Kapat"),
                            ),
                          ],
                        ),
                      );
                    } else if (state is GradeDetailsLoaded) {
                      final details = state.details;
                      return Container(
                        padding: const EdgeInsets.all(20),
                        constraints: const BoxConstraints(maxHeight: 600),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Sınav İstatistikleri",
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.grey),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                            const Divider(thickness: 1.5),
                            const SizedBox(height: 16),
                            // Summary Cards
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.blue.shade100),
                                    ),
                                    child: Column(
                                      children: [
                                        Text("Ortalama", style: TextStyle(color: Colors.blue.shade900, fontSize: 12, fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 4),
                                        Text(
                                          details.average.toStringAsFixed(2),
                                          style: TextStyle(color: Colors.blue.shade900, fontSize: 20, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.orange.shade100),
                                    ),
                                    child: Column(
                                      children: [
                                        Text("Öğrenci Sayısı", style: TextStyle(color: Colors.orange.shade900, fontSize: 12, fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 4),
                                        Text(
                                          details.studentCount.toString(),
                                          style: TextStyle(color: Colors.orange.shade900, fontSize: 20, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Text(
                              "Not Dağılımı",
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Table(
                                  border: TableBorder.all(color: Colors.grey.shade300),
                                  columnWidths: const {
                                    0: FlexColumnWidth(1),
                                    1: FixedColumnWidth(80),
                                  },
                                  children: [
                                    TableRow(
                                      decoration: BoxDecoration(color: Colors.grey.shade200),
                                      children: const [
                                        Padding(
                                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                          child: Text("Puan Aralığı", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                          child: Text("Kişi", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87), textAlign: TextAlign.center),
                                        ),
                                      ],
                                    ),
                                    ...details.distribution.entries.map((e) {
                                      return TableRow(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                        ),
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                            child: Text(e.key, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                            child: Text(e.value.toString(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            );
          },
          child: Text(
            c.grade,
            style: style.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        );
      }

      return TableRow(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Text(
              label,
              style: style.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Text(c.type, style: style),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Text(c.weight, style: style),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: gradeWidget,
            ),
          ),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final gradeColor = AppTheme.getGradeColor(course.hnot, gpaString: gpa);
    final textTheme = Theme.of(context).textTheme;
    // Tablo içindeki metinler için temel stil
    final tableTextStyle = textTheme.bodyMedium!.copyWith(
      color: AppColors.textPrimary,
    );
    // Tablo başlıkları için stil
    final tableHeaderStyle = tableTextStyle.copyWith(
      fontWeight: FontWeight.bold,
    );

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: AppColors.cardBorder.withOpacity(0.6),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        title: Text(
          course.ad,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Harf Notu: ", style: textTheme.titleSmall),
              Text(
                course.hnot,
                style: textTheme.bodyMedium?.copyWith(
                  color: gradeColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        iconColor: AppColors.appBarColor,
        collapsedIconColor: AppColors.textPrimary,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Sayısal Not:", style: textTheme.titleSmall),
                const SizedBox(width: 8),
                Text(
                  course.snot,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 12),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(3), // Etiket (örn: Final)
              1: FlexColumnWidth(2.5), // Tür (örn: YAZILI)
              2: FlexColumnWidth(2), // Ağırlık
              3: FlexColumnWidth(1.5), // Not
            },
            children: [
              TableRow(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.cardBorder, width: 1.5),
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text("Bileşen", style: tableHeaderStyle),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text("Tür", style: tableHeaderStyle),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text("Ağırlık", style: tableHeaderStyle),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text("Not", style: tableHeaderStyle),
                    ),
                  ),
                ],
              ),
              // Boşluk satırı
              const TableRow(
                children: [
                  SizedBox(height: 8),
                  SizedBox.shrink(),
                  SizedBox.shrink(),
                  SizedBox.shrink(),
                ],
              ),
              ..._buildGradeTableRows(
                context,
                "Ara Sınav 1",
                course.as1,
                tableTextStyle,
              ),
              ..._buildGradeTableRows(
                context,
                "Ara Sınav 2",
                course.as2,
                tableTextStyle,
              ),
              ..._buildGradeTableRows(
                context,
                "Final",
                course.finalNotu,
                tableTextStyle,
              ),
              ..._buildGradeTableRows(context, "Bütünleme", course.but, tableTextStyle),
              ..._buildGradeTableRows(
                context,
                "Ek Sınavlar",
                course.eks,
                tableTextStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
