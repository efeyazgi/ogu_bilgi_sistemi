import 'package:equatable/equatable.dart';

class CourseGradeModel extends Equatable {
  final String ad; // Ders Adı
  final String as1; // Ara Sınav 1
  final String as2; // Ara Sınav 2
  final String finalNotu; // Final
  final String but; // Bütünleme
  final String eks; // Ek Sınavlar
  final String snot; // Sayısal Not
  final String hnot; // Harf Notu

  final String? as1Url;
  final String? as2Url;
  final String? finalUrl;
  final String? butUrl;
  final String? eksUrl;

  const CourseGradeModel({
    required this.ad,
    required this.as1,
    required this.as2,
    required this.finalNotu,
    required this.but,
    required this.eks,
    required this.snot,
    required this.hnot,
    this.as1Url,
    this.as2Url,
    this.finalUrl,
    this.butUrl,
    this.eksUrl,
  });

  // OgubsService'ten gelen Map'ten CourseGradeModel oluşturmak için factory constructor
  factory CourseGradeModel.fromMap(Map<String, dynamic> map) {
    return CourseGradeModel(
      ad: map['ad'] ?? 'Bilinmiyor',
      as1: map['as1'] ?? 'Girilmemiş',
      as2: map['as2'] ?? 'Girilmemiş',
      finalNotu: map['final'] ?? 'Girilmemiş',
      but: map['but'] ?? 'Girilmemiş',
      eks: map['eks'] ?? 'Girilmemiş',
      snot: map['snot'] ?? 'Girilmemiş',
      hnot: map['hnot'] ?? 'Girilmemiş',
      as1Url: map['as1Url'],
      as2Url: map['as2Url'],
      finalUrl: map['finalUrl'],
      butUrl: map['butUrl'],
      eksUrl: map['eksUrl'],
    );
  }

  @override
  List<Object?> get props => [ad, as1, as2, finalNotu, but, eks, snot, hnot, as1Url, as2Url, finalUrl, butUrl, eksUrl];
}
