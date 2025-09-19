import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ogu_not_sistemi_v2/core/services/ogubs_service.dart';
import '../../data/models/course_model.dart';
import '../../data/models/registered_course.dart';

part 'schedule_event.dart';
part 'schedule_state.dart';

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final OgubsService _ogubsService;

  ScheduleBloc({required OgubsService ogubsService})
      : _ogubsService = ogubsService,
        super(ScheduleInitial()) {
    on<LoadSchedule>(_onLoadSchedule);
    on<ClearSchedule>(_onClearSchedule);
  }

  Future<void> _onLoadSchedule(
    LoadSchedule event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(ScheduleLoading());
    try {
      final courses = await _ogubsService.fetchSchedule();
      final registered = await _ogubsService.fetchRegisteredCourses();
      emit(ScheduleLoaded(courses: courses, registeredCourses: registered));
    } catch (e) {
      emit(ScheduleFailure(message: e.toString()));
    }
  }

  Future<void> _onClearSchedule(
    ClearSchedule event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(ScheduleInitial());
  }
}