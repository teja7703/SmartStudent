import 'package:equatable/equatable.dart';
import '../models/quiz_model.dart';

abstract class QuizState extends Equatable {
  const QuizState();

  @override
  List<Object?> get props => [];
}

class QuizInitial extends QuizState {}

class QuizLoading extends QuizState {}

class QuizLoaded extends QuizState {
  final List<QuizModel> quizzes;
  final String? classLevel;
  final String? category;
  final String? difficulty;

  const QuizLoaded({
    required this.quizzes,
    this.classLevel,
    this.category,
    this.difficulty,
  });

  @override
  List<Object?> get props => [quizzes, classLevel, category, difficulty];
}

class QuizEmpty extends QuizState {}

class QuizError extends QuizState {
  final String message;

  const QuizError(this.message);

  @override
  List<Object?> get props => [message];
}

class QuizPlayLoaded extends QuizState {
  final QuizModel quiz;
  final String? selectedAnswer;
  final bool isAnswered;
  final bool isCorrect;

  const QuizPlayLoaded({
    required this.quiz,
    this.selectedAnswer,
    this.isAnswered = false,
    this.isCorrect = false,
  });

  QuizPlayLoaded copyWith({
    String? selectedAnswer,
    bool? isAnswered,
    bool? isCorrect,
  }) {
    return QuizPlayLoaded(
      quiz: quiz,
      selectedAnswer: selectedAnswer ?? this.selectedAnswer,
      isAnswered: isAnswered ?? this.isAnswered,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }

  @override
  List<Object?> get props => [quiz, selectedAnswer, isAnswered, isCorrect];
}

class QuizScoreState extends QuizState {
  final int score;
  final int total;
  final int pointsEarned;

  const QuizScoreState({
    required this.score,
    required this.total,
    required this.pointsEarned,
  });

  @override
  List<Object?> get props => [score, total, pointsEarned];
}
