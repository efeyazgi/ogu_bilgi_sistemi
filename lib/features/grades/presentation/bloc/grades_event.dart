part of 'grades_bloc.dart';

abstract class GradesEvent extends Equatable {
  const GradesEvent();

  @override
  List<Object?> get props => [];
}

/// Triggers fetching grades for the initial/default term and also the dropdown options.
class LoadInitialGrades extends GradesEvent {}

/// Triggers fetching grades for a specific year and term.
class FetchGrades extends GradesEvent {
  final String year;
  final String term;

  const FetchGrades({required this.year, required this.term});

  @override
  List<Object?> get props => [year, term];
}

// Notları temizlemek için event (örneğin çıkış yapıldığında)
class ClearGrades extends GradesEvent {}
