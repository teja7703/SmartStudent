import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../career_ui.dart';
import '../cubit/career_cubit.dart';
import '../cubit/career_state.dart';
import '../models/career_model.dart';

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
      body: BlocBuilder<CareerCubit, CareerState>(
        builder: (context, state) {
          if (state is CareerDetailLoading ||
              state is CareerInitial ||
              state is CareerLoading) {
            return const Scaffold(body: LoadingWidget());
          }
          if (state is CareerDetailError) {
            return Scaffold(
              appBar: AppBar(),
              body: ErrorStateWidget(
                message: state.message,
                onRetry: () => context
                    .read<CareerCubit>()
                    .loadCareerDetail(widget.careerId),
              ),
            );
          }
          if (state is CareerDetailLoaded) {
            return _Detail(career: state.career);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  final CareerModel career;

  const _Detail({required this.career});

  @override
  Widget build(BuildContext context) {
    final color = CareerUi.categoryColor(career.category);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 200,
          foregroundColor: Colors.white,
          backgroundColor: color,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(gradient: AppColors.gradientFor(color)),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(CareerUi.categoryIcon(career.category),
                            color: Colors.white, size: 28),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        career.careerName,
                        style: AppTextStyles.headlineLarge
                            .copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          career.category,
                          style: AppTextStyles.labelMedium
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TextSection(
                  title: 'Overview',
                  icon: Icons.info_outline_rounded,
                  color: color,
                  content: career.overviewOrDescription,
                ),
                _TextSection(
                  title: 'Eligibility',
                  icon: Icons.checklist_rounded,
                  color: color,
                  content: career.eligibilityOrEducation,
                ),
                if (career.skills.isNotEmpty)
                  _ChipSection(
                    title: 'Required Skills',
                    icon: Icons.psychology_rounded,
                    color: AppColors.secondaryGreen,
                    items: career.skills,
                  ),
                if (career.salaryRange.isNotEmpty)
                  _HighlightSection(
                    title: 'Salary Range',
                    icon: Icons.payments_rounded,
                    color: AppColors.secondaryGreen,
                    value: career.salaryRange,
                  ),
                if (career.careerGrowth.isNotEmpty)
                  _TextSection(
                    title: 'Career Growth',
                    icon: Icons.trending_up_rounded,
                    color: AppColors.accentOrange,
                    content: career.careerGrowth,
                  ),
                if (career.recommendedCourses.isNotEmpty)
                  _ListSection(
                    title: 'Recommended Courses',
                    icon: Icons.menu_book_rounded,
                    color: AppColors.accentPurple,
                    items: career.recommendedCourses,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Text(title, style: AppTextStyles.titleLarge),
      ],
    );
  }
}

class _TextSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String content;

  const _TextSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(title: title, icon: icon, color: color),
            const SizedBox(height: 12),
            Text(
              content,
              style: AppTextStyles.bodyLarge.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _HighlightSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String value;

  const _HighlightSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.labelMedium),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: AppTextStyles.titleLarge.copyWith(color: color),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;

  const _ChipSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(title: title, icon: icon, color: color),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items
                  .map((item) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item,
                          style: AppTextStyles.labelMedium
                              .copyWith(color: color),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;

  const _ListSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(title: title, icon: icon, color: color),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_rounded,
                          size: 18, color: color),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(item, style: AppTextStyles.bodyLarge),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
