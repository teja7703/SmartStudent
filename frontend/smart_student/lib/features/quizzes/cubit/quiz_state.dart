import 'package:equatable/equatable.dart';
import '../models/quiz_model.dart';

abstract class QuizState extends Equatable {
  const QuizState();

  @override
  List<Object?> get props => [];
}

class QuizInitial extends QuizState {}

class QuizLoading extends QuizState {}

class QuizEmpty extends QuizState {}

class QuizError extends QuizState {
  final String message;

  const QuizError(this.message);

  @override
  List<Object?> get props => [message];
}

class QuizCatalogLoaded extends QuizState {
  final Map<String, List<QuizModel>> byClass;
  final List<String> classes;
  final String selectedClass;

  const QuizCatalogLoaded({
    required this.byClass,
    required this.classes,
    required this.selectedClass,
  });

  List<QuizModel> get quizzesForSelectedClass =>
      byClass[selectedClass] ?? const [];

  QuizCatalogLoaded copyWith({String? selectedClass}) {
    return QuizCatalogLoaded(
      byClass: byClass,
      classes: classes,
      selectedClass: selectedClass ?? this.selectedClass,
    );
  }

  @override
  List<Object?> get props => [byClass, classes, selectedClass];
}
