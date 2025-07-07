part of 'grades_bloc.dart';

abstract class GradesState extends Equatable {
  final List<SelectionOption> yearOptions;
  final List<SelectionOption> termOptions;
  final String? selectedYear;
  final String? selectedTerm;

  const GradesState({
    this.yearOptions = const [],
    this.termOptions = const [],
    this.selectedYear,
    this.selectedTerm,
  });

  @override
  List<Object?> get props => [
    yearOptions,
    termOptions,
    selectedYear,
    selectedTerm,
  ];
}

// Başlangıç durumu, henüz notlar yüklenmedi
class GradesInitial extends GradesState {}

// Notlar ve özet bilgiler yükleniyor
class GradesLoading extends GradesState {
  const GradesLoading({
    super.yearOptions,
    super.termOptions,
    super.selectedYear,
    super.selectedTerm,
  });
}

// Notlar ve özet bilgiler başarıyla yüklendi
class GradesLoaded extends GradesState {
  final List<CourseGradeModel> courses;
  final AcademicSummaryModel summary;

  const GradesLoaded({
    required this.courses,
    required this.summary,
    required super.yearOptions,
    required super.termOptions,
    required super.selectedYear,
    required super.selectedTerm,
  });

  @override
  List<Object?> get props => [
    courses,
    summary,
    yearOptions,
    termOptions,
    selectedYear,
    selectedTerm,
  ];
}

// Notlar veya özet bilgiler yüklenirken hata oluştu
class GradesFailure extends GradesState {
  final String message;

  const GradesFailure({
    required this.message,
    super.yearOptions,
    super.termOptions,
    super.selectedYear,
    super.selectedTerm,
  });

  @override
  List<Object?> get props => [
    message,
    yearOptions,
    termOptions,
    selectedYear,
    selectedTerm,
  ];
}
