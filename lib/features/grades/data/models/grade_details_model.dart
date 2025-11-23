class GradeDetailsModel {
  final double average;
  final int studentCount;
  final Map<String, int> distribution;

  GradeDetailsModel({
    required this.average,
    required this.studentCount,
    required this.distribution,
  });

  @override
  String toString() {
    return 'GradeDetailsModel(average: $average, studentCount: $studentCount, distribution: $distribution)';
  }
}
