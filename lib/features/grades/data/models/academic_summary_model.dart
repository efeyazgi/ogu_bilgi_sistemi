import 'package:equatable/equatable.dart';

class AcademicSummaryModel extends Equatable {
  final String? gpa; // Genel Not Ortalaması
  final String? credits; // Başarılan Kredi
  final String? akts; // Toplam/Başarılan AKTS

  const AcademicSummaryModel({this.gpa, this.credits, this.akts});

  // OgubsService'ten gelen Map'ten AcademicSummaryModel oluşturmak için factory constructor
  factory AcademicSummaryModel.fromMap(Map<String, String?> map) {
    return AcademicSummaryModel(
      gpa: map['gpa'],
      credits: map['credits'],
      akts: map['akts'],
    );
  }

  bool get isEmpty => gpa == null && credits == null && akts == null;
  bool get isNotEmpty => !isEmpty;

  @override
  List<Object?> get props => [gpa, credits, akts];
}
