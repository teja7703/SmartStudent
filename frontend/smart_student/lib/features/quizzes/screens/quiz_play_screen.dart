import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../cubit/quiz_cubit.dart';
import '../cubit/quiz_state.dart';

class QuizPlayScreen extends StatefulWidget {
  final String quizId;

  const QuizPlayScreen({super.key, required this.quizId});

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  @override
  void initState() {
    super.initState();
    context.read<QuizCubit>().loadQuiz(widget.quizId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuizCubit, QuizState>(
      builder: (context, state) {
        if (state is QuizLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Quiz')),
            body: const LoadingWidget(),
          );
        }
        if (state is QuizError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Quiz')),
            body: ErrorStateWidget(
              message: state.message,
              onRetry: () => context.read<QuizCubit>().loadQuiz(widget.quizId),
            ),
          );
        }
        if (state is QuizPlayLoaded) {
          final quiz = state.quiz;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Quiz'),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: Text(
                      '${quiz.points} pts',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.secondaryGreen,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _chip(quiz.category, AppColors.primaryBlue),
                      const SizedBox(width: 8),
                      _chip(quiz.difficulty, AppColors.accentOrange),
                    ],
                  ),
                  const SizedBox(height: 20),
                  AppCard(
                    child: Text(quiz.question, style: AppTextStyles.headlineMedium),
                  ),
                  const SizedBox(height: 20),
                  ...quiz.options.map((option) {
                    final isSelected = state.selectedAnswer == option;
                    final isCorrect = option == quiz.correctAnswer;
                    Color? borderColor;
                    Color? bgColor;

                    if (state.isAnswered) {
                      if (isCorrect) {
                        borderColor = AppColors.secondaryGreen;
                        bgColor = AppColors.secondaryGreen.withValues(alpha: 0.1);
                      } else if (isSelected) {
                        borderColor = AppColors.accentRed;
                        bgColor = AppColors.accentRed.withValues(alpha: 0.1);
                      }
                    } else if (isSelected) {
                      borderColor = AppColors.primaryBlue;
                      bgColor = AppColors.primaryBlue.withValues(alpha: 0.08);
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppCard(
                        onTap: state.isAnswered
                            ? null
                            : () => context.read<QuizCubit>().selectAnswer(option),
                        color: bgColor,
                        child: Row(
                          children: [
                            Icon(
                              state.isAnswered && isCorrect
                                  ? Icons.check_circle_rounded
                                  : state.isAnswered && isSelected
                                      ? Icons.cancel_rounded
                                      : Icons.circle_outlined,
                              color: borderColor ?? AppColors.textHint,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(option, style: AppTextStyles.bodyLarge),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  if (state.isAnswered) ...[
                    const SizedBox(height: 8),
                    AppCard(
                      color: state.isCorrect
                          ? AppColors.secondaryGreen.withValues(alpha: 0.1)
                          : AppColors.accentRed.withValues(alpha: 0.1),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.isCorrect ? 'Correct!' : 'Incorrect',
                            style: AppTextStyles.titleLarge.copyWith(
                              color: state.isCorrect
                                  ? AppColors.secondaryGreen
                                  : AppColors.accentRed,
                            ),
                          ),
                          if (quiz.explanation.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(quiz.explanation, style: AppTextStyles.bodyMedium),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<QuizCubit>().showScore(
                                score: state.isCorrect ? 1 : 0,
                                total: 1,
                                points: state.isCorrect ? quiz.points : 0,
                              );
                          context.push('/quizzes/score');
                        },
                        child: const Text('View Score'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
