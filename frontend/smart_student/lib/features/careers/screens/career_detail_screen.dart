import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../cubit/career_cubit.dart';
import '../cubit/career_state.dart';

class CareerDetailScreen extends StatefulWidget {
  final String careerId;

  const CareerDetailScreen({super.key, required this.careerId});

  @override
  State<CareerDetailScreen> createState() => _CareerDetailScreenState();
}

class _CareerDetailScreenState extends State<CareerDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CareerCubit>().loadCareerDetail(widget.careerId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Career Details')),
      body: BlocBuilder<CareerCubit, CareerState>(
        builder: (context, state) {
          if (state is CareerDetailLoading) {
            return const LoadingWidget();
          }
          if (state is CareerDetailError) {
            return ErrorStateWidget(
              message: state.message,
              onRetry: () =>
                  context.read<CareerCubit>().loadCareerDetail(widget.careerId),
            );
          }
          if (state is CareerDetailLoaded) {
            final career = state.career;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(career.careerName, style: AppTextStyles.headlineMedium),
                        const SizedBox(height: 8),
                        Text(career.description, style: AppTextStyles.bodyLarge),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _section('Education Path', career.requiredEducation, Icons.school_rounded),
                  const SizedBox(height: 12),
                  if (career.salaryRange.isNotEmpty)
                    _section('Salary Range', career.salaryRange, Icons.payments_rounded),
                  if (career.salaryRange.isNotEmpty) const SizedBox(height: 12),
                  if (career.skills.isNotEmpty) ...[
                    Text('Required Skills', style: AppTextStyles.titleLarge),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: career.skills.map((skill) {
                        return Chip(
                          label: Text(skill),
                          backgroundColor:
                              AppColors.secondaryGreen.withValues(alpha: 0.1),
                          labelStyle: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.secondaryGreenDark,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _section(
                    'Future Opportunities',
                    'Explore growth paths, specializations, and emerging roles in ${career.careerName}. Stay updated with industry trends and continue learning.',
                    Icons.trending_up_rounded,
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _section(String title, String content, IconData icon) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryBlue, size: 22),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.titleMedium),
            ],
          ),
          const SizedBox(height: 8),
          Text(content, style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          )),
        ],
      ),
    );
  }
}
