import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/quiz_repository.dart';
import 'quiz_state.dart';

class QuizCubit extends Cubit<QuizState> {
  final QuizRepository _repository;

  QuizCubit(this._repository) : super(QuizInitial());

  Future<void> loadQuizzes({
    String? classLevel,
    String? category,
    String? difficulty,
  }) async {
    emit(QuizLoading());
    try {
      final quizzes = await _repository.getQuizzes(
        classLevel: classLevel,
        category: category,
        difficulty: difficulty,
      );
      if (quizzes.isEmpty) {
        emit(QuizEmpty());
      } else {
        emit(QuizLoaded(
          quizzes: quizzes,
          classLevel: classLevel,
          category: category,
          difficulty: difficulty,
        ));
      }
    } catch (e) {
      emit(QuizError(e.toString()));
    }
  }

  Future<void> loadQuiz(String id) async {
    emit(QuizLoading());
    try {
      final quiz = await _repository.getQuizById(id);
      emit(QuizPlayLoaded(quiz: quiz));
    } catch (e) {
      emit(QuizError(e.toString()));
    }
  }

  void selectAnswer(String answer) {
    if (state is QuizPlayLoaded) {
      final current = state as QuizPlayLoaded;
      if (current.isAnswered) return;
      final isCorrect = answer == current.quiz.correctAnswer;
      emit(current.copyWith(
        selectedAnswer: answer,
        isAnswered: true,
        isCorrect: isCorrect,
      ));
    }
  }

  void showScore({required int score, required int total, required int points}) {
    emit(QuizScoreState(score: score, total: total, pointsEarned: points));
  }
}
