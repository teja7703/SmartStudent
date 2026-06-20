import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../injection.dart';
import '../models/quiz_result_model.dart';
import '../quiz_ui.dart';
import '../repositories/quiz_repository.dart';

class QuizHistoryScreen extends StatefulWidget {
  const QuizHistoryScreen({super.key});

  @override
  State<QuizHistoryScreen> createState() => _QuizHistoryScreenState();
}

class _QuizHistoryScreenState extends State<QuizHistoryScreen> {
  final QuizRepository _repository = getIt<QuizRepository>();
  List<QuizResultModel> _history = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final history = await _repository.getHistory();
    if (!mounted) return;
    setState(() {
      _history = history;
      _loading = false;
    });
  }

  Future<void> _clear() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear history?'),
        content: const Text('This will remove all your past quiz attempts.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await _repository.clearHistory();
    if (!mounted) return;
    setState(() => _history = const []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz History'),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              tooltip: 'Clear history',
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: _clear,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const LoadingWidget();
    }
    if (_history.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.history_rounded,
        title: 'No attempts yet',
        message: 'Take a quiz and your results will show up here.',
        onRetry: () => context.go('/quizzes'),
        retryLabel: 'Browse Quizzes',
      );
    }
    return RefreshIndicator(
      color: AppColors.primaryBlue,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Analytics(history: _history),
          const SizedBox(height: 20),
          Text('Recent Attempts', style: AppTextStyles.titleLarge),
          const SizedBox(height: 12),
          ..._history.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AttemptCard(result: r),
            ),
          ),
        ],
      ),
    );
  }
}

class _Analytics extends StatelessWidget {
  final List<QuizResultModel> history;

  const _Analytics({required this.history});

  @override
  Widget build(BuildContext context) {
    final totalQuizzes = history.length;
    final totalQuestions =
        history.fold<int>(0, (s, r) => s + r.total);
    final totalCorrect = history.fold<int>(0, (s, r) => s + r.correct);
    final totalPoints = history.fold<int>(0, (s, r) => s + r.pointsEarned);
    final avgAccuracy =
        totalQuestions == 0 ? 0 : (totalCorrect / totalQuestions * 100).round();
    final best = history.fold<int>(
        0, (m, r) => r.percentage > m ? r.percentage : m);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Performance', style: AppTextStyles.titleLarge),
        const SizedBox(height: 12),
        Row(
          children: [
            _AnalyticTile(
              label: 'Quizzes',
              value: '$totalQuizzes',
              icon: Icons.quiz_rounded,
              color: AppColors.primaryBlue,
            ),
            const SizedBox(width: 12),
            _AnalyticTile(
              label: 'Avg Score',
              value: '$avgAccuracy%',
              icon: Icons.insights_rounded,
              color: AppColors.accentPurple,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _AnalyticTile(
              label: 'Best Score',
              value: '$best%',
              icon: Icons.emoji_events_rounded,
              color: AppColors.accentOrange,
            ),
            const SizedBox(width: 12),
            _AnalyticTile(
              label: 'Points',
              value: '$totalPoints',
              icon: Icons.star_rounded,
              color: AppColors.secondaryGreen,
            ),
          ],
        ),
      ],
    );
  }
}

class _AnalyticTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _AnalyticTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppCard(
        color: color.withValues(alpha: 0.08),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style:
                        AppTextStyles.titleLarge.copyWith(color: color)),
                Text(label, style: AppTextStyles.labelMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AttemptCard extends StatelessWidget {
  final QuizResultModel result;

  const _AttemptCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final color = QuizUi.subjectColor(result.subject);
    return AppCard(
      onTap: () => context.push('/quizzes/review', extra: result),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppColors.gradientFor(color),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(QuizUi.subjectIcon(result.subject),
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${result.subject} • ${QuizUi.classLabel(result.classLevel)}',
                  style: AppTextStyles.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '${result.correct}/${result.total} correct • ${_formatDate(result.date)}',
                  style: AppTextStyles.labelMedium,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${result.percentage}%',
                style: AppTextStyles.titleLarge.copyWith(
                  color: result.percentage >= 50
                      ? AppColors.secondaryGreen
                      : AppColors.accentRed,
                ),
              ),
              Text('${result.pointsEarned} pts',
                  style: AppTextStyles.labelMedium),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final d = date.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
  }
}
