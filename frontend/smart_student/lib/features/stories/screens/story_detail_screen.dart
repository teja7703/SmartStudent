import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../cubit/story_cubit.dart';
import '../cubit/story_state.dart';

class StoryDetailScreen extends StatefulWidget {
  final String storyId;

  const StoryDetailScreen({super.key, required this.storyId});

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<StoryCubit>().loadStoryDetail(widget.storyId);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) return;
    final progress = (_scrollController.offset / maxScroll).clamp(0.0, 1.0);
    context.read<StoryCubit>().updateReadProgress(widget.storyId, progress);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoryCubit, StoryState>(
      builder: (context, state) {
        if (state is StoryDetailLoading) {
          return Scaffold(
            appBar: AppBar(),
            body: const LoadingWidget(),
          );
        }
        if (state is StoryDetailError) {
          return Scaffold(
            appBar: AppBar(),
            body: ErrorStateWidget(
              message: state.message,
              onRetry: () =>
                  context.read<StoryCubit>().loadStoryDetail(widget.storyId),
            ),
          );
        }
        if (state is StoryDetailLoaded) {
          final story = state.story;
          return Scaffold(
            appBar: AppBar(
              title: Text(story.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              actions: [
                IconButton(
                  icon: Icon(
                    state.isBookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_outline_rounded,
                    color: state.isBookmarked ? AppColors.accentOrange : null,
                  ),
                  onPressed: () =>
                      context.read<StoryCubit>().toggleBookmark(story.id),
                ),
              ],
            ),
            body: Column(
              children: [
                LinearProgressIndicator(
                  value: state.readProgress,
                  backgroundColor: AppColors.divider,
                  color: AppColors.secondaryGreen,
                  minHeight: 3,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(story.title, style: AppTextStyles.headlineMedium),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Chip(label: Text(story.category)),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${story.readTime} min read',
                                    style: AppTextStyles.labelMedium,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(story.description, style: AppTextStyles.bodyLarge),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
