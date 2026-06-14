import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../cubit/quiz_cubit.dart';
import '../cubit/quiz_state.dart';

class QuizzesScreen extends StatefulWidget {
  const QuizzesScreen({super.key});

  @override
  State<QuizzesScreen> createState() => _QuizzesScreenState();
}

class _QuizzesScreenState extends State<QuizzesScreen> {
  String? _difficulty;
  String? _category;

  static const _difficulties = ['Easy', 'Medium', 'Hard'];
  static const _categories = ['Maths', 'Science', 'English', 'Social'];

  @override
  void initState() {
    super.initState();
    context.read<QuizCubit>().loadQuizzes();
  }

  void _applyFilters() {
    context.read<QuizCubit>().loadQuizzes(
          category: _category,
          difficulty: _difficulty,
        );
  }

  Color _difficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return AppColors.secondaryGreen;
      case 'Medium':
        return AppColors.accentOrange;
      case 'Hard':
        return AppColors.accentRed;
      default:
        return AppColors.primaryBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Quiz')),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                ..._difficulties.map((d) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(d),
                        selected: _difficulty == d,
                        onSelected: (selected) {
                          setState(() => _difficulty = selected ? d : null);
                          _applyFilters();
                        },
                      ),
                    )),
              ],
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                ..._categories.map((c) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(c),
                        selected: _category == c,
                        onSelected: (selected) {
                          setState(() => _category = selected ? c : null);
                          _applyFilters();
                        },
                      ),
                    )),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<QuizCubit, QuizState>(
              builder: (context, state) {
                if (state is QuizLoading) {
                  return const ShimmerLoading();
                }
                if (state is QuizError) {
                  return ErrorStateWidget(
                    message: state.message,
                    onRetry: () => context.read<QuizCubit>().loadQuizzes(),
                  );
                }
                if (state is QuizEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.quiz_outlined,
                    title: 'No quizzes available',
                    message: 'Try different filters or check back later.',
                    onRetry: () => context.read<QuizCubit>().loadQuizzes(),
                  );
                }
                if (state is QuizLoaded) {
                  return RefreshIndicator(
                    onRefresh: () async => _applyFilters(),
                    color: AppColors.primaryBlue,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.quizzes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final quiz = state.quizzes[index];
                        return AppCard(
                          onTap: () => context.push('/quizzes/play/${quiz.id}'),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _difficultyColor(quiz.difficulty)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  Icons.quiz_rounded,
                                  color: _difficultyColor(quiz.difficulty),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      quiz.question,
                                      style: AppTextStyles.titleMedium,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        _tag(quiz.category),
                                        const SizedBox(width: 6),
                                        _tag(quiz.difficulty),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${quiz.points} pts',
                                          style: AppTextStyles.labelMedium.copyWith(
                                            color: AppColors.secondaryGreen,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: AppColors.textHint),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: AppTextStyles.labelMedium.copyWith(fontSize: 11)),
    );
  }
}
