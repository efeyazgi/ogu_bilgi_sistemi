part of 'schedule_bloc.dart';

abstract class ScheduleEvent extends Equatable {
  const ScheduleEvent();

  @override
  List<Object> get props => [];
}

class LoadSchedule extends ScheduleEvent {
  const LoadSchedule();
}

class ClearSchedule extends ScheduleEvent {
  const ClearSchedule();
}