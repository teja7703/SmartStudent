import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/study_material_repository.dart';
import 'study_material_state.dart';

class StudyMaterialCubit extends Cubit<StudyMaterialState> {
  final StudyMaterialRepository _repository;
  final String academicLevel;
  final String subject;
  final String language;

  StudyMaterialCubit({
    required StudyMaterialRepository repository,
    required this.academicLevel,
    required this.subject,
    this.language = 'English',
  })  : _repository = repository,
        super(StudyMaterialInitial());

  Future<void> loadMaterials({String? search}) async {
    emit(StudyMaterialLoading());
    try {
      final materials = await _repository.getMaterials(
        academicLevel: academicLevel,
        subject: subject,
        language: language,
        search: search,
      );
      if (materials.isEmpty) {
        emit(StudyMaterialEmpty());
      } else {
        emit(StudyMaterialLoaded(
          materials: materials,
          searchQuery: search ?? '',
        ));
      }
    } catch (e) {
      emit(StudyMaterialError(e.toString()));
    }
  }
}
