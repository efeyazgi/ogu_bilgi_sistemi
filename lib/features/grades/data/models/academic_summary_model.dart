import 'package:equatable/equatable.dart';

class AcademicSummaryModel extends Equatable {
  final String? gpa; // Genel Not Ortalaması
  final String? credits; // Başarılan Kredi

  const AcademicSummaryModel({this.gpa, this.credits});

  // OgubsService'ten gelen Map'ten AcademicSummaryModel oluşturmak için factory constructor
  factory AcademicSummaryModel.fromMap(Map<String, String?> map) {
    return AcademicSummaryModel(gpa: map['gpa'], credits: map['credits']);
  }

  bool get isEmpty => gpa == null && credits == null;
  bool get isNotEmpty => !isEmpty;

  @override
  List<Object?> get props => [gpa, credits];
}
