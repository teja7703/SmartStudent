import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Small presentation helpers shared across the quiz screens.
class QuizUi {
  QuizUi._();

  static String classLabel(String classLevel) {
    final n = int.tryParse(classLevel);
    if (n != null) return 'Class $classLevel';
    return classLevel;
  }

  static Color subjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'maths':
      case 'mathematics':
        return AppColors.primaryBlue;
      case 'science':
        return AppColors.secondaryGreen;
      case 'english':
        return AppColors.accentPurple;
      case 'social':
      case 'social studies':
        return AppColors.accentOrange;
      case 'telugu':
        return AppColors.accentRed;
      default:
        return AppColors.primaryBlue;
    }
  }

  static IconData subjectIcon(String subject) {
    switch (subject.toLowerCase()) {
      case 'maths':
      case 'mathematics':
        return Icons.calculate_rounded;
      case 'science':
        return Icons.science_rounded;
      case 'english':
        return Icons.menu_book_rounded;
      case 'social':
      case 'social studies':
        return Icons.public_rounded;
      case 'telugu':
        return Icons.translate_rounded;
      default:
        return Icons.quiz_rounded;
    }
  }

  static Color difficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return AppColors.secondaryGreen;
      case 'medium':
        return AppColors.accentOrange;
      case 'hard':
        return AppColors.accentRed;
      default:
        return AppColors.primaryBlue;
    }
  }

  static String formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
