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
import '../career_ui.dart';
import '../cubit/career_cubit.dart';
import '../cubit/career_state.dart';
import '../models/career_model.dart';

class CareersScreen extends StatefulWidget {
  const CareersScreen({super.key});

  @override
  State<CareersScreen> createState() => _CareersScreenState();
}

class _CareersScreenState extends State<CareersScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    context.read<CareerCubit>().loadCatalog();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Career Guidance')),
      body: BlocBuilder<CareerCubit, CareerState>(
        builder: (context, state) {
          if (state is CareerLoading || state is CareerInitial) {
            return const ShimmerLoading(height: 100);
          }
          if (state is CareerError) {
            return ErrorStateWidget(
              message: state.message,
              onRetry: () => context.read<CareerCubit>().loadCatalog(),
            );
          }
          if (state is CareerEmpty) {
            return EmptyStateWidget(
              icon: Icons.work_outline,
              title: 'No careers yet',
              message: 'Career paths will appear here once added.',
              onRetry: () => context.read<CareerCubit>().loadCatalog(),
            );
          }
          if (state is CareerCatalogLoaded) {
            return _CatalogView(
              state: state,
              controller: _searchController,
              query: _query,
              onQueryChanged: (v) => setState(() => _query = v),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _CatalogView extends StatelessWidget {
  final CareerCatalogLoaded state;
  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onQueryChanged;

  const _CatalogView({
    required this.state,
    required this.controller,
    required this.query,
    required this.onQueryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final searching = query.trim().isNotEmpty;
    final results = searching
        ? state.all
            .where((c) =>
                c.careerName.toLowerCase().contains(query.toLowerCase()) ||
                c.category.toLowerCase().contains(query.toLowerCase()))
            .toList()
        : const <CareerModel>[];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: AppSearchBar(
            controller: controller,
            hint: 'Search careers...',
            onChanged: onQueryChanged,
          ),
        ),
        Expanded(
          child: searching
              ? _SearchResults(results: results)
              : _CategoryGrid(state: state),
        ),
      ],
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  final CareerCatalogLoaded state;

  const _CategoryGrid({required this.state});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primaryBlue,
      onRefresh: () => context.read<CareerCubit>().loadCatalog(),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.95,
        ),
        itemCount: state.categories.length,
        itemBuilder: (context, index) {
          final category = state.categories[index];
          final count = state.byCategory[category]?.length ?? 0;
          return _CategoryCard(category: category, count: count);
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String category;
  final int count;

  const _CategoryCard({required this.category, required this.count});

  @override
  Widget build(BuildContext context) {
    final color = CareerUi.categoryColor(category);
    return AppCard(
      onTap: () => context.push(
          '/careers/category/${Uri.encodeComponent(category)}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppColors.gradientFor(color),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(CareerUi.categoryIcon(category), color: Colors.white),
          ),
          const Spacer(),
          Text(
            category,
            style: AppTextStyles.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text('$count option${count == 1 ? '' : 's'}',
              style: AppTextStyles.labelMedium),
        ],
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  final List<CareerModel> results;

  const _SearchResults({required this.results});

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.search_off_rounded,
        title: 'No matches',
        message: 'Try a different search term.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) =>
          CareerListTile(career: results[index]),
    );
  }
}

class CareerListTile extends StatelessWidget {
  final CareerModel career;

  const CareerListTile({super.key, required this.career});

  @override
  Widget build(BuildContext context) {
    final color = CareerUi.categoryColor(career.category);
    return AppCard(
      onTap: () => context.push('/careers/${career.id}'),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(CareerUi.categoryIcon(career.category), color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(career.careerName, style: AppTextStyles.titleMedium),
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
  }
}
