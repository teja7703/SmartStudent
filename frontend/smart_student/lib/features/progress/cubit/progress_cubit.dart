import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/storage_service.dart';
import '../../quizzes/models/quiz_result_model.dart';
import '../models/progress_stats.dart';

/// Computes the student's learning progress from locally stored quiz history
/// and recently visited items. Held as a singleton so the home and profile
/// screens stay in sync and refresh after a quiz is completed.
class ProgressCubit extends Cubit<ProgressStats> {
  final StorageService _storage;

  ProgressCubit(this._storage) : super(const ProgressStats());

  Future<void> load() async {
    try {
      final historyRaw = await _storage.getQuizHistory();
      final activityRaw = await _storage.getRecentActivity();

      final history =
          historyRaw.map((e) => QuizResultModel.fromJson(e)).toList();

      final quizzesCompleted = history.length;
      final pointsEarned =
          history.fold<int>(0, (sum, r) => sum + r.pointsEarned);
      final avgScore = quizzesCompleted == 0
          ? 0
          : (history.fold<int>(0, (sum, r) => sum + r.percentage) /
                  quizzesCompleted)
              .round();
      final bestScore = history.fold<int>(
          0, (best, r) => r.percentage > best ? r.percentage : best);

      var materialsViewed = 0;
      var storiesRead = 0;
      for (final a in activityRaw) {
        if (a['type'] == 'material') materialsViewed++;
        if (a['type'] == 'story') storiesRead++;
      }

      final recent = _buildRecent(history, activityRaw);
      final streak = _computeStreak(history, activityRaw);

      emit(ProgressStats(
        quizzesCompleted: quizzesCompleted,
        pointsEarned: pointsEarned,
        avgScore: avgScore,
        bestScore: bestScore,
        streak: streak,
        materialsViewed: materialsViewed,
        storiesRead: storiesRead,
        recent: recent,
      ));
    } catch (_) {
      emit(const ProgressStats());
    }
  }

  List<ActivityItem> _buildRecent(
    List<QuizResultModel> history,
    List<Map<String, dynamic>> activity,
  ) {
    final items = <ActivityItem>[];

    for (final r in history) {
      items.add(ActivityItem(
        type: 'quiz',
        title: '${r.subject} Quiz',
        subtitle: '${r.percentage}% • ${r.correct}/${r.total} correct',
        route: '/quizzes/history',
        date: r.date,
      ));
    }

    for (final a in activity) {
      final type = a['type']?.toString() ?? '';
      if (type != 'material' && type != 'story') continue;
      final id = a['id']?.toString() ?? '';
      items.add(ActivityItem(
        type: type,
        title: a['title']?.toString() ?? '',
        subtitle: a['subtitle']?.toString() ?? '',
        route: type == 'story' ? '/stories/$id' : '/study-materials',
        date: DateTime.tryParse(a['ts']?.toString() ?? '') ?? DateTime.now(),
      ));
    }

    items.sort((a, b) => b.date.compareTo(a.date));
    return items.take(8).toList();
  }

  int _computeStreak(
    List<QuizResultModel> history,
    List<Map<String, dynamic>> activity,
  ) {
    final days = <DateTime>{};
    void add(DateTime d) => days.add(DateTime(d.year, d.month, d.day));

    for (final r in history) {
      add(r.date);
    }
    for (final a in activity) {
      final ts = DateTime.tryParse(a['ts']?.toString() ?? '');
      if (ts != null) add(ts);
    }
    if (days.isEmpty) return 0;

    final now = DateTime.now();
    var cursor = DateTime(now.year, now.month, now.day);

    // Allow the streak to "start" today or yesterday.
    if (!days.contains(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
      if (!days.contains(cursor)) return 0;
    }

    var streak = 0;
    while (days.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }
}
