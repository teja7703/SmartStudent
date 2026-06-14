import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/academic_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/stat_card.dart';

class PreviousPaperSubjectsScreen extends StatelessWidget {
  final String academicLevel;

  const PreviousPaperSubjectsScreen({
    super.key,
    required this.academicLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AcademicConstants.formatLevel(academicLevel)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: AcademicConstants.subjects.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final subject = AcademicConstants.subjects[index];
          return LevelListTile(
            title: subject,
            subtitle: 'Previous exam papers',
            icon: Icons.subject_rounded,
            iconColor: AppColors.accentOrange,
            onTap: () => context.push(
              '/previous-papers/$academicLevel/$subject',
            ),
          );
        },
      ),
    );
  }
}
