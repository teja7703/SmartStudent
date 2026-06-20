import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/quiz_repository.dart';
import 'quiz_state.dart';

class QuizCubit extends Cubit<QuizState> {
  final QuizRepository _repository;

  QuizCubit(this._repository) : super(QuizInitial());

  Future<void> loadCatalog() async {
    emit(QuizLoading());
    try {
      final catalog = await _repository.getCatalog();
      if (catalog.isEmpty) {
        emit(QuizEmpty());
        return;
      }

      final classes = catalog.keys.toList()..sort(_compareClasses);

      emit(QuizCatalogLoaded(
        byClass: catalog,
        classes: classes,
        selectedClass: classes.first,
      ));
    } catch (e) {
      emit(QuizError(e.toString()));
    }
  }

  void selectClass(String classLevel) {
    final current = state;
    if (current is QuizCatalogLoaded) {
      emit(current.copyWith(selectedClass: classLevel));
    }
  }

  int _compareClasses(String a, String b) {
    final na = int.tryParse(a);
    final nb = int.tryParse(b);
    if (na != null && nb != null) return na.compareTo(nb);
    if (na != null) return -1;
    if (nb != null) return 1;
    return a.compareTo(b);
  }
}
