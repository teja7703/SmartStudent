import 'package:equatable/equatable.dart';
import '../models/study_material_model.dart';

abstract class StudyMaterialState extends Equatable {
  const StudyMaterialState();

  @override
  List<Object?> get props => [];
}

class StudyMaterialInitial extends StudyMaterialState {}

class StudyMaterialLoading extends StudyMaterialState {}

class StudyMaterialLoaded extends StudyMaterialState {
  final List<StudyMaterialModel> materials;
  final String searchQuery;

  const StudyMaterialLoaded({
    required this.materials,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [materials, searchQuery];
}

class StudyMaterialEmpty extends StudyMaterialState {}

class StudyMaterialError extends StudyMaterialState {
  final String message;

  const StudyMaterialError(this.message);

  @override
  List<Object?> get props => [message];
}
