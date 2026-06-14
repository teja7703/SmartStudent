import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../cubit/quiz_cubit.dart';
import '../cubit/quiz_state.dart';

class QuizScoreScreen extends StatelessWidget {
  const QuizScoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuizCubit, QuizState>(
      builder: (context, state) {
        final scoreState = state is QuizScoreState
            ? state
            : const QuizScoreState(score: 0, total: 1, pointsEarned: 0);

        final percentage =
            scoreState.total > 0 ? (scoreState.score / scoreState.total * 100).round() : 0;

        return Scaffold(
          appBar: AppBar(title: const Text('Quiz Result')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 24),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: percentage >= 50
                          ? [AppColors.secondaryGreen, AppColors.secondaryGreenLight]
                          : [AppColors.accentOrange, AppColors.accentRed],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$percentage%',
                      style: AppTextStyles.displayMedium.copyWith(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  percentage >= 50 ? 'Great Job!' : 'Keep Practicing!',
                  style: AppTextStyles.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'You scored ${scoreState.score} out of ${scoreState.total}',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 24),
                AppCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _stat('Points Earned', '${scoreState.pointsEarned}'),
                      Container(width: 1, height: 40, color: AppColors.divider),
                      _stat('Accuracy', '$percentage%'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text('Leaderboard', style: AppTextStyles.titleLarge),
                const SizedBox(height: 12),
                ..._mockLeaderboard.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: AppCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor:
                                AppColors.primaryBlue.withValues(alpha: 0.1),
                            child: Text(
                              '${entry['rank']}',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              entry['name'] as String,
                              style: AppTextStyles.titleMedium,
                            ),
                          ),
                          Text(
                            '${entry['points']} pts',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.secondaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.go('/quizzes'),
                        child: const Text('More Quizzes'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => context.go('/home'),
                        child: const Text('Go Home'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.statNumber),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.labelMedium),
      ],
    );
  }

  static const _mockLeaderboard = [
    {'rank': 1, 'name': 'Priya S.', 'points': 1250},
    {'rank': 2, 'name': 'Rahul K.', 'points': 1100},
    {'rank': 3, 'name': 'Ananya M.', 'points': 980},
    {'rank': 4, 'name': 'You', 'points': 850},
    {'rank': 5, 'name': 'Vikram R.', 'points': 720},
  ];
}
