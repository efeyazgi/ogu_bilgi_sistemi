import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ogu_not_sistemi_v2/core/services/ogubs_service.dart';
import 'package:ogu_not_sistemi_v2/features/grades/data/models/grade_details_model.dart';

part 'grade_details_state.dart';

class GradeDetailsCubit extends Cubit<GradeDetailsState> {
  final OgubsService _service;

  GradeDetailsCubit(this._service) : super(GradeDetailsInitial());

  Future<void> fetchDetails(String url) async {
    emit(GradeDetailsLoading());
    try {
      final details = await _service.fetchGradeDetails(url);
      emit(GradeDetailsLoaded(details));
    } catch (e) {
      emit(GradeDetailsError(e.toString()));
    }
  }
}
