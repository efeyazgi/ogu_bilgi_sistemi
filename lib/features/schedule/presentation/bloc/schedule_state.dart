part of 'schedule_bloc.dart';

abstract class ScheduleState extends Equatable {
  const ScheduleState();

  @override
  List<Object> get props => [];
}

class ScheduleInitial extends ScheduleState {}

class ScheduleLoading extends ScheduleState {}

class ScheduleLoaded extends ScheduleState {
  final List<Course> courses;
  final List<RegisteredCourse> registeredCourses;

  const ScheduleLoaded({required this.courses, required this.registeredCourses});

  @override
  List<Object> get props => [courses, registeredCourses];
}

class ScheduleFailure extends ScheduleState {
  final String message;

  const ScheduleFailure({required this.message});

  @override
  List<Object> get props => [message];
}