import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ogu_not_sistemi/core/services/ogubs_service.dart';
import 'package:ogu_not_sistemi/features/grades/data/models/course_grade_model.dart';
import 'package:ogu_not_sistemi/features/grades/data/models/academic_summary_model.dart';
import 'package:ogu_not_sistemi/features/grades/data/models/grades_page_data.dart';

part 'grades_event.dart';
part 'grades_state.dart';

class GradesBloc extends Bloc<GradesEvent, GradesState> {
  final OgubsService _ogubsService;

  GradesBloc({required OgubsService ogubsService})
    : _ogubsService = ogubsService,
      super(GradesInitial()) {
    on<LoadInitialGrades>(_onLoadInitialGrades);
    on<FetchGrades>(_onFetchGrades);
    on<ClearGrades>(_onClearGrades);
  }

  Future<void> _onLoadInitialGrades(
    LoadInitialGrades event,
    Emitter<GradesState> emit,
  ) async {
    await _fetchGradesAndEmit(emit, null, null);
  }

  Future<void> _onFetchGrades(
    FetchGrades event,
    Emitter<GradesState> emit,
  ) async {
    await _fetchGradesAndEmit(emit, event.year, event.term);
  }

  Future<void> _fetchGradesAndEmit(
    Emitter<GradesState> emit,
    String? year,
    String? term,
  ) async {
    final currentState = state;
    emit(
      GradesLoading(
        yearOptions: currentState.yearOptions,
        termOptions: currentState.termOptions,
        selectedYear: year ?? currentState.selectedYear,
        selectedTerm: term ?? currentState.selectedTerm,
      ),
    );
    try {
      final gradesData = await _ogubsService.fetchGrades(
        selectedYear: year,
        selectedTerm: term,
      );

      emit(
        GradesLoaded(
          courses: gradesData.courses,
          summary: gradesData.summary,
          yearOptions: gradesData.yearOptions,
          termOptions: gradesData.termOptions,
          selectedYear: gradesData.selectedYear,
          selectedTerm: gradesData.selectedTerm,
        ),
      );
    } catch (e) {
      emit(
        GradesFailure(
          message: 'Notlar alınırken bir hata oluştu: ${e.toString()}',
          yearOptions: state.yearOptions,
          termOptions: state.termOptions,
          selectedYear: state.selectedYear,
          selectedTerm: state.selectedTerm,
        ),
      );
    }
  }

  void _onClearGrades(ClearGrades event, Emitter<GradesState> emit) {
    emit(GradesInitial());
  }
}
