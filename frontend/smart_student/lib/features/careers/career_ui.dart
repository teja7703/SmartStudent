import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Presentation helpers shared across the career guidance screens.
class CareerUi {
  CareerUi._();

  static Color categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'after 10th':
        return AppColors.primaryBlue;
      case 'after intermediate':
        return AppColors.accentPurple;
      case 'government jobs':
        return AppColors.secondaryGreen;
      case 'engineering':
        return AppColors.primaryBlueLight;
      case 'medical':
        return AppColors.accentRed;
      case 'degree courses':
        return AppColors.accentOrange;
      case 'polytechnic':
        return AppColors.secondaryGreenDark;
      case 'iti':
        return AppColors.primaryBlueDark;
      case 'civil services':
        return AppColors.accentPurple;
      case 'software careers':
        return AppColors.primaryBlue;
      default:
        return AppColors.accentPurple;
    }
  }

  static IconData categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'after 10th':
        return Icons.school_rounded;
      case 'after intermediate':
        return Icons.menu_book_rounded;
      case 'government jobs':
        return Icons.account_balance_rounded;
      case 'engineering':
        return Icons.engineering_rounded;
      case 'medical':
        return Icons.medical_services_rounded;
      case 'degree courses':
        return Icons.workspace_premium_rounded;
      case 'polytechnic':
        return Icons.architecture_rounded;
      case 'iti':
        return Icons.build_rounded;
      case 'civil services':
        return Icons.gavel_rounded;
      case 'software careers':
        return Icons.computer_rounded;
      default:
        return Icons.work_rounded;
    }
  }
}
