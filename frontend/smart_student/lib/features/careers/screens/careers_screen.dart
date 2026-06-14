import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../cubit/career_cubit.dart';
import '../cubit/career_state.dart';

class CareersScreen extends StatefulWidget {
  const CareersScreen({super.key});

  @override
  State<CareersScreen> createState() => _CareersScreenState();
}

class _CareersScreenState extends State<CareersScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CareerCubit>().loadCareers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Career Paths')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: AppSearchBar(
              controller: _searchController,
              hint: 'Search careers...',
              onChanged: (value) {
                context.read<CareerCubit>().loadCareers(search: value);
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<CareerCubit, CareerState>(
              builder: (context, state) {
                if (state is CareerLoading) {
                  return const ShimmerLoading(height: 100);
                }
                if (state is CareerError) {
                  return ErrorStateWidget(
                    message: state.message,
                    onRetry: () => context.read<CareerCubit>().loadCareers(),
                  );
                }
                if (state is CareerEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.work_outline,
                    title: 'No careers found',
                    message: 'Try a different search term.',
                    onRetry: () => context.read<CareerCubit>().loadCareers(),
                  );
                }
                if (state is CareerLoaded) {
                  return RefreshIndicator(
                    onRefresh: () => context
                        .read<CareerCubit>()
                        .loadCareers(search: state.searchQuery),
                    color: AppColors.primaryBlue,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.careers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final career = state.careers[index];
                        return AppCard(
                          onTap: () => context.push('/careers/${career.id}'),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.accentPurple.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.work_rounded,
                                  color: AppColors.accentPurple,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      career.careerName,
                                      style: AppTextStyles.titleMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      career.description,
                                      style: AppTextStyles.bodyMedium,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
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
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
