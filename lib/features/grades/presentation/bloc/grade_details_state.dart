part of 'grade_details_cubit.dart';

abstract class GradeDetailsState extends Equatable {
  const GradeDetailsState();

  @override
  List<Object?> get props => [];
}

class GradeDetailsInitial extends GradeDetailsState {}

class GradeDetailsLoading extends GradeDetailsState {}

class GradeDetailsLoaded extends GradeDetailsState {
  final GradeDetailsModel details;

  const GradeDetailsLoaded(this.details);

  @override
  List<Object?> get props => [details];
}

class GradeDetailsError extends GradeDetailsState {
  final String message;

  const GradeDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}
