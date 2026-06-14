import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/career_repository.dart';
import 'career_state.dart';

class CareerCubit extends Cubit<CareerState> {
  final CareerRepository _repository;

  CareerCubit(this._repository) : super(CareerInitial());

  Future<void> loadCareers({String? search}) async {
    emit(CareerLoading());
    try {
      final careers = await _repository.getCareers(search: search);
      if (careers.isEmpty) {
        emit(CareerEmpty());
      } else {
        emit(CareerLoaded(careers: careers, searchQuery: search ?? ''));
      }
    } catch (e) {
      emit(CareerError(e.toString()));
    }
  }

  Future<void> loadCareerDetail(String id) async {
    emit(CareerDetailLoading());
    try {
      final career = await _repository.getCareerById(id);
      emit(CareerDetailLoaded(career));
    } catch (e) {
      emit(CareerDetailError(e.toString()));
    }
  }
}
