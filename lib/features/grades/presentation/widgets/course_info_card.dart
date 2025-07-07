import 'package:flutter/material.dart';
import 'package:ogu_not_sistemi/core/theme/app_colors.dart'; // AppColors import edildi
import 'package:ogu_not_sistemi/core/theme/app_theme.dart'; // AppTheme import edildi (getGradeColor için)
import 'package:ogu_not_sistemi/features/grades/data/models/course_grade_model.dart';

// Ham not dizesini ("YAZILI (%35): 100") ayrıştırmak için bir model.
class _GradeComponent {
  final String type;
  final String weight;
  final String grade;

  _GradeComponent({
    required this.type,
    required this.weight,
    required this.grade,
  });

  static List<_GradeComponent> fromRawString(String raw) {
    if (raw.trim().isEmpty || raw.trim() == "Veri Yok") return [];

    // "ÖDEV (%20):90, QUIZ (%10):95" gibi virgülle ayrılmış birden fazla bileşeni işle
    final parts = raw.split(',');
    return parts.map((part) {
      String temp = part.trim();
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

      return _GradeComponent(type: type, weight: weight, grade: grade);
    }).toList();
  }
}

class CourseInfoCard extends StatelessWidget {
  final CourseGradeModel course;
  final String? gpa; // GNO'yu almak için eklendi

  const CourseInfoCard({super.key, required this.course, this.gpa});

  // Tablo için satırları oluşturan yardımcı metot
  List<TableRow> _buildGradeTableRows(
    String label,
    String rawValue,
    TextStyle style,
  ) {
    final components = _GradeComponent.fromRawString(rawValue);
    if (components.isEmpty) return [];

    return components.map((c) {
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
              child: Text(
                c.grade,
                style: style.copyWith(fontWeight: FontWeight.bold),
              ),
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
                "Ara Sınav 1",
                course.as1,
                tableTextStyle,
              ),
              ..._buildGradeTableRows(
                "Ara Sınav 2",
                course.as2,
                tableTextStyle,
              ),
              ..._buildGradeTableRows(
                "Final",
                course.finalNotu,
                tableTextStyle,
              ),
              ..._buildGradeTableRows("Bütünleme", course.but, tableTextStyle),
              ..._buildGradeTableRows(
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
