import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/network_image_box.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../models/story_model.dart';
import '../cubit/story_cubit.dart';
import '../cubit/story_state.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<StoryCubit>().loadStories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Success Stories')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: AppSearchBar(
              controller: _searchController,
              hint: 'Search stories...',
              onChanged: (value) {
                context.read<StoryCubit>().loadStories(search: value);
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<StoryCubit, StoryState>(
              builder: (context, state) {
                if (state is StoryLoading) {
                  return const ShimmerLoading(height: 120);
                }
                if (state is StoryError) {
                  return ErrorStateWidget(
                    message: state.message,
                    onRetry: () => context.read<StoryCubit>().loadStories(),
                  );
                }
                if (state is StoryEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.auto_stories_outlined,
                    title: 'No stories found',
                    message: 'Try a different search term.',
                    onRetry: () => context.read<StoryCubit>().loadStories(),
                  );
                }
                if (state is StoryLoaded) {
                  return RefreshIndicator(
                    onRefresh: () => context
                        .read<StoryCubit>()
                        .loadStories(search: state.searchQuery),
                    color: AppColors.primaryBlue,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.stories.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 16),
                      itemBuilder: (context, index) =>
                          _StoryCard(story: state.stories[index]),
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

class _StoryCard extends StatelessWidget {
  final StoryModel story;

  const _StoryCard({required this.story});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () => context.push('/stories/${story.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: NetworkImageBox(
              url: story.imageUrl,
              height: 150,
              width: double.infinity,
              color: AppColors.accentRed,
              fallbackIcon: Icons.auto_stories_rounded,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accentRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        story.category,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.accentRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.timer_outlined,
                        size: 14, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Text('${story.readTime} min read',
                        style: AppTextStyles.labelMedium),
                  ],
                ),
                const SizedBox(height: 12),
                Text(story.title, style: AppTextStyles.titleLarge),
                const SizedBox(height: 6),
                Text(
                  story.summary,
                  style: AppTextStyles.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor:
                          AppColors.accentPurple.withValues(alpha: 0.15),
                      child: Text(
                        _initials(story.name),
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.accentPurple,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        story.name.isNotEmpty ? story.name : 'Smart Student',
                        style: AppTextStyles.labelLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    if (name.trim().isEmpty) return 'S';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
