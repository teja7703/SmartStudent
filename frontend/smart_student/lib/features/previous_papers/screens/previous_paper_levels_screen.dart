import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/academic_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/stat_card.dart';

class PreviousPaperLevelsScreen extends StatelessWidget {
  const PreviousPaperLevelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Previous Papers')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader(title: 'Select Academic Level'),
          const SizedBox(height: 12),
          ...AcademicConstants.academicLevels.map((level) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: LevelListTile(
                title: AcademicConstants.formatLevel(level),
                subtitle: 'View exam papers',
                icon: Icons.description_rounded,
                iconColor: AppColors.accentOrange,
                onTap: () => context.push('/previous-papers/$level/subjects'),
              ),
            );
          }),
        ],
      ),
    );
  }
}
