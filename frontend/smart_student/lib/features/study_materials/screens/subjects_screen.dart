import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/academic_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/stat_card.dart';

class SubjectsScreen extends StatelessWidget {
  final String academicLevel;
  final String language;

  const SubjectsScreen({
    super.key,
    required this.academicLevel,
    required this.language,
  });

  static const _subjectIcons = {
    'Mathematics': Icons.calculate_rounded,
    'Science': Icons.science_rounded,
    'Social': Icons.public_rounded,
    'English': Icons.translate_rounded,
    'Telugu': Icons.language_rounded,
    'Hindi': Icons.menu_book_rounded,
  };

  static const _subjectColors = {
    'Mathematics': AppColors.primaryBlue,
    'Science': AppColors.secondaryGreen,
    'Social': AppColors.accentOrange,
    'English': AppColors.accentPurple,
    'Telugu': AppColors.accentRed,
    'Hindi': AppColors.primaryBlueLight,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AcademicConstants.formatLevel(academicLevel, language),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: AcademicConstants.subjects.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final subject = AcademicConstants.subjects[index];
          return LevelListTile(
            title: AcademicConstants.formatSubject(subject, language),
            subtitle: AcademicConstants.browseMaterials(language),
            icon: _subjectIcons[subject] ?? Icons.book_rounded,
            iconColor: _subjectColors[subject] ?? AppColors.primaryBlue,
            onTap: () => context.push(
              '/study-materials/$language/$academicLevel/$subject',
            ),
          );
        },
      ),
    );
  }
}
