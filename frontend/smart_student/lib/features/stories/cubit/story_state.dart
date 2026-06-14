import 'package:equatable/equatable.dart';
import '../models/story_model.dart';

abstract class StoryState extends Equatable {
  const StoryState();

  @override
  List<Object?> get props => [];
}

class StoryInitial extends StoryState {}

class StoryLoading extends StoryState {}

class StoryLoaded extends StoryState {
  final List<StoryModel> stories;
  final String searchQuery;

  const StoryLoaded({required this.stories, this.searchQuery = ''});

  @override
  List<Object?> get props => [stories, searchQuery];
}

class StoryEmpty extends StoryState {}

class StoryError extends StoryState {
  final String message;

  const StoryError(this.message);

  @override
  List<Object?> get props => [message];
}

class StoryDetailLoading extends StoryState {}

class StoryDetailLoaded extends StoryState {
  final StoryModel story;
  final bool isBookmarked;
  final double readProgress;

  const StoryDetailLoaded({
    required this.story,
    this.isBookmarked = false,
    this.readProgress = 0,
  });

  @override
  List<Object?> get props => [story, isBookmarked, readProgress];
}

class StoryDetailError extends StoryState {
  final String message;

  const StoryDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
