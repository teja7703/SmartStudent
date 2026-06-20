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
import '../models/quiz_model.dart';
import '../quiz_ui.dart';

class QuizzesScreen extends StatefulWidget {
  const QuizzesScreen({super.key});

  @override
  State<QuizzesScreen> createState() => _QuizzesScreenState();
}

class _QuizzesScreenState extends State<QuizzesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<QuizCubit>().loadCatalog();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quizzes'),
        actions: [
          IconButton(
            tooltip: 'Quiz History',
            icon: const Icon(Icons.history_rounded),
            onPressed: () => context.push('/quizzes/history'),
          ),
        ],
      ),
      body: BlocBuilder<QuizCubit, QuizState>(
        builder: (context, state) {
          if (state is QuizLoading || state is QuizInitial) {
            return const ShimmerLoading();
          }
          if (state is QuizError) {
            return ErrorStateWidget(
              message: state.message,
              onRetry: () => context.read<QuizCubit>().loadCatalog(),
            );
          }
          if (state is QuizEmpty) {
            return EmptyStateWidget(
              icon: Icons.quiz_outlined,
              title: 'No quizzes yet',
              message: 'Quizzes will appear here once they are added.',
              onRetry: () => context.read<QuizCubit>().loadCatalog(),
            );
          }
          if (state is QuizCatalogLoaded) {
            return _Catalog(state: state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _Catalog extends StatelessWidget {
  final QuizCatalogLoaded state;

  const _Catalog({required this.state});

  @override
  Widget build(BuildContext context) {
    final quizzes = state.quizzesForSelectedClass;
    final totalQuestions =
        quizzes.fold<int>(0, (sum, q) => sum + q.totalQuestions);

    return RefreshIndicator(
      color: AppColors.primaryBlue,
      onRefresh: () => context.read<QuizCubit>().loadCatalog(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Text('Choose your class', style: AppTextStyles.titleLarge),
          const SizedBox(height: 12),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: state.classes.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final c = state.classes[index];
                final selected = c == state.selectedClass;
                return ChoiceChip(
                  label: Text(QuizUi.classLabel(c)),
                  selected: selected,
                  showCheckmark: false,
                  backgroundColor: AppColors.surfaceLight,
                  selectedColor: AppColors.primaryBlue,
                  labelStyle: AppTextStyles.labelLarge.copyWith(
                    color: selected ? Colors.white : AppColors.textPrimary,
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  side: BorderSide(
                    color: selected
                        ? AppColors.primaryBlue
                        : AppColors.divider,
                  ),
                  onSelected: (_) =>
                      context.read<QuizCubit>().selectClass(c),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                '${quizzes.length} subjects',
                style: AppTextStyles.titleMedium,
              ),
              const Spacer(),
              Text(
                '$totalQuestions questions',
                style: AppTextStyles.labelMedium,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...quizzes.map((quiz) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _QuizCard(quiz: quiz),
              )),
        ],
      ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  final QuizModel quiz;

  const _QuizCard({required this.quiz});

  @override
  Widget build(BuildContext context) {
    final color = QuizUi.subjectColor(quiz.subject);
    final minutes = (quiz.durationSeconds / 60).ceil();

    return AppCard(
      onTap: () => context.push('/quizzes/play', extra: quiz),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: AppColors.gradientFor(color),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              QuizUi.subjectIcon(quiz.subject),
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quiz.subject,
                  style: AppTextStyles.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _MetaChip(
                      icon: Icons.help_outline_rounded,
                      label: '${quiz.totalQuestions} Qs',
                    ),
                    _MetaChip(
                      icon: Icons.timer_outlined,
                      label: '$minutes min',
                    ),
                    _MetaChip(
                      icon: Icons.star_rounded,
                      label: '${quiz.totalPoints} pts',
                      color: AppColors.secondaryGreen,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.play_circle_fill_rounded, color: color, size: 30),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _MetaChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textSecondary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: c),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(color: c),
        ),
      ],
    );
  }
}
