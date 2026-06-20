import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/academic_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/stat_card.dart';

class StudyLevelsScreen extends StatelessWidget {
  final String language;

  const StudyLevelsScreen({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AcademicConstants.studyMaterialsTitle(language)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionHeader(
            title: AcademicConstants.selectLevelTitle(language),
          ),
          const SizedBox(height: 12),
          ...AcademicConstants.academicLevels.map((level) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: LevelListTile(
                title: AcademicConstants.formatLevel(level, language),
                subtitle: AcademicConstants.viewSubjects(language),
                icon: Icons.school_rounded,
                iconColor: AppColors.primaryBlue,
                onTap: () => context.push(
                  '/study-materials/$language/$level/subjects',
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
