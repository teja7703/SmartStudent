import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../cubit/previous_paper_cubit.dart';
import '../cubit/previous_paper_state.dart';

class PreviousPaperListScreen extends StatefulWidget {
  final String academicLevel;
  final String subject;

  const PreviousPaperListScreen({
    super.key,
    required this.academicLevel,
    required this.subject,
  });

  @override
  State<PreviousPaperListScreen> createState() => _PreviousPaperListScreenState();
}

class _PreviousPaperListScreenState extends State<PreviousPaperListScreen> {
  int? _selectedYear;

  @override
  void initState() {
    super.initState();
    context.read<PreviousPaperCubit>().loadPapers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.subject)),
      body: BlocBuilder<PreviousPaperCubit, PreviousPaperState>(
        builder: (context, state) {
          if (state is PreviousPaperLoading) {
            return const ShimmerLoading();
          }
          if (state is PreviousPaperError) {
            return ErrorStateWidget(
              message: state.message,
              onRetry: () => context.read<PreviousPaperCubit>().loadPapers(),
            );
          }
          if (state is PreviousPaperEmpty) {
            return EmptyStateWidget(
              icon: Icons.description_outlined,
              title: 'No papers found',
              message: 'Try a different year filter or check back later.',
              onRetry: () => context.read<PreviousPaperCubit>().loadPapers(),
            );
          }
          if (state is PreviousPaperLoaded) {
            final years = state.papers.map((p) => p.year).toSet().toList()
              ..sort((a, b) => b.compareTo(a));

            return Column(
              children: [
                if (years.isNotEmpty)
                  SizedBox(
                    height: 48,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: const Text('All'),
                            selected: _selectedYear == null,
                            onSelected: (_) {
                              setState(() => _selectedYear = null);
                              context.read<PreviousPaperCubit>().loadPapers();
                            },
                          ),
                        ),
                        ...years.map((year) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text('$year'),
                              selected: _selectedYear == year,
                              onSelected: (_) {
                                setState(() => _selectedYear = year);
                                context
                                    .read<PreviousPaperCubit>()
                                    .loadPapers(year: year);
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => context
                        .read<PreviousPaperCubit>()
                        .loadPapers(year: _selectedYear),
                    color: AppColors.primaryBlue,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.papers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final paper = state.papers[index];
                        return AppCard(
                          onTap: () => context.push(
                            '/previous-papers/detail/${paper.id}',
                            extra: paper,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.accentOrange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.picture_as_pdf_rounded,
                                  color: AppColors.accentOrange,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${paper.year} - ${paper.paperType}',
                                      style: AppTextStyles.titleMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      paper.subject,
                                      style: AppTextStyles.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: AppColors.textHint),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
