import 'package:ogu_not_sistemi/features/grades/data/models/academic_summary_model.dart';
import 'package:ogu_not_sistemi/features/grades/data/models/course_grade_model.dart';

// Dropdown'lar için genel bir model
class SelectionOption {
  final String value;
  final String text;

  SelectionOption({required this.value, required this.text});
}

class GradesPageData {
  final List<CourseGradeModel> courses;
  final AcademicSummaryModel summary;
  final List<SelectionOption> yearOptions;
  final List<SelectionOption> termOptions;
  final String? selectedYear;
  final String? selectedTerm;

  GradesPageData({
    required this.courses,
    required this.summary,
    required this.yearOptions,
    required this.termOptions,
    this.selectedYear,
    this.selectedTerm,
  });
}
