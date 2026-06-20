import 'package:equatable/equatable.dart';

/// A single entry in the "recent activity" feed on the home screen.
class ActivityItem extends Equatable {
  final String type; // quiz | material | story
  final String title;
  final String subtitle;
  final String route;
  final DateTime date;

  const ActivityItem({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.route,
    required this.date,
  });

  @override
  List<Object?> get props => [type, title, subtitle, route, date];
}

/// Aggregated, locally-computed learning progress for the signed-in student.
class ProgressStats extends Equatable {
  final int quizzesCompleted;
  final int pointsEarned;
  final int avgScore;
  final int bestScore;
  final int streak;
  final int materialsViewed;
  final int storiesRead;
  final List<ActivityItem> recent;

  const ProgressStats({
    this.quizzesCompleted = 0,
    this.pointsEarned = 0,
    this.avgScore = 0,
    this.bestScore = 0,
    this.streak = 0,
    this.materialsViewed = 0,
    this.storiesRead = 0,
    this.recent = const [],
  });

  bool get isEmpty =>
      quizzesCompleted == 0 && materialsViewed == 0 && storiesRead == 0;

  @override
  List<Object?> get props => [
        quizzesCompleted,
        pointsEarned,
        avgScore,
        bestScore,
        streak,
        materialsViewed,
        storiesRead,
        recent,
      ];
}
