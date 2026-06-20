import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/career_repository.dart';
import 'career_state.dart';

class CareerCubit extends Cubit<CareerState> {
  final CareerRepository _repository;

  CareerCubit(this._repository) : super(CareerInitial());

  Future<void> loadCatalog() async {
    emit(CareerLoading());
    try {
      final catalog = await _repository.getCatalog();
      if (catalog.isEmpty) {
        emit(CareerEmpty());
        return;
      }
      final all = catalog.values.expand((e) => e).toList();
      emit(CareerCatalogLoaded(
        byCategory: catalog,
        categories: catalog.keys.toList(),
        all: all,
      ));
    } catch (e) {
      emit(CareerError(e.toString()));
    }
  }

  Future<void> loadCareers({String? search, String? category}) async {
    emit(CareerLoading());
    try {
      final careers =
          await _repository.getCareers(search: search, category: category);
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
