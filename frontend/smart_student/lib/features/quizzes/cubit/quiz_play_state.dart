import 'package:equatable/equatable.dart';
import '../models/quiz_model.dart';
import '../models/quiz_result_model.dart';

enum QuizPlayStatus { playing, finished }

class QuizPlayState extends Equatable {
  final QuizModel quiz;
  final int currentIndex;

  /// Maps a question index to the option the user selected.
  final Map<int, String> answers;
  final int secondsRemaining;
  final QuizPlayStatus status;
  final QuizResultModel? result;

  const QuizPlayState({
    required this.quiz,
    required this.currentIndex,
    required this.answers,
    required this.secondsRemaining,
    required this.status,
    this.result,
  });

  factory QuizPlayState.initial(QuizModel quiz) {
    return QuizPlayState(
      quiz: quiz,
      currentIndex: 0,
      answers: const {},
      secondsRemaining: quiz.durationSeconds,
      status: QuizPlayStatus.playing,
    );
  }

  bool get isLastQuestion => currentIndex >= quiz.totalQuestions - 1;

  bool get isFirstQuestion => currentIndex <= 0;

  int get answeredCount => answers.length;

  String? get selectedForCurrent => answers[currentIndex];

  double get progress =>
      quiz.totalQuestions == 0 ? 0 : (currentIndex + 1) / quiz.totalQuestions;

  QuizPlayState copyWith({
    int? currentIndex,
    Map<int, String>? answers,
    int? secondsRemaining,
    QuizPlayStatus? status,
    QuizResultModel? result,
  }) {
    return QuizPlayState(
      quiz: quiz,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      status: status ?? this.status,
      result: result ?? this.result,
    );
  }

  @override
  List<Object?> get props =>
      [quiz.id, currentIndex, answers, secondsRemaining, status, result];
}
