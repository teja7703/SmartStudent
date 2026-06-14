import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/storage_service.dart';
import '../repositories/story_repository.dart';
import 'story_state.dart';

class StoryCubit extends Cubit<StoryState> {
  final StoryRepository _repository;
  final StorageService _storageService;

  StoryCubit(this._repository, this._storageService) : super(StoryInitial());

  Future<void> loadStories({String? search}) async {
    emit(StoryLoading());
    try {
      final stories = await _repository.getStories(search: search);
      if (stories.isEmpty) {
        emit(StoryEmpty());
      } else {
        emit(StoryLoaded(stories: stories, searchQuery: search ?? ''));
      }
    } catch (e) {
      emit(StoryError(e.toString()));
    }
  }

  Future<void> loadStoryDetail(String id) async {
    emit(StoryDetailLoading());
    try {
      final story = await _repository.getStoryById(id);
      final isBookmarked = await _storageService.isBookmarked(id);
      final progress = await _storageService.getReadProgress(id);
      emit(StoryDetailLoaded(
        story: story,
        isBookmarked: isBookmarked,
        readProgress: progress,
      ));
    } catch (e) {
      emit(StoryDetailError(e.toString()));
    }
  }

  Future<void> toggleBookmark(String storyId) async {
    await _storageService.toggleBookmark(storyId);
    if (state is StoryDetailLoaded) {
      final current = state as StoryDetailLoaded;
      final isBookmarked = await _storageService.isBookmarked(storyId);
      emit(StoryDetailLoaded(
        story: current.story,
        isBookmarked: isBookmarked,
        readProgress: current.readProgress,
      ));
    }
  }

  Future<void> updateReadProgress(String storyId, double progress) async {
    await _storageService.saveReadProgress(storyId, progress);
    if (state is StoryDetailLoaded) {
      final current = state as StoryDetailLoaded;
      emit(StoryDetailLoaded(
        story: current.story,
        isBookmarked: current.isBookmarked,
        readProgress: progress,
      ));
    }
  }
}
