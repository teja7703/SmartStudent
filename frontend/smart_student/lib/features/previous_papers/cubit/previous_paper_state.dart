import 'package:equatable/equatable.dart';
import '../models/previous_paper_model.dart';

abstract class PreviousPaperState extends Equatable {
  const PreviousPaperState();

  @override
  List<Object?> get props => [];
}

class PreviousPaperInitial extends PreviousPaperState {}

class PreviousPaperLoading extends PreviousPaperState {}

class PreviousPaperLoaded extends PreviousPaperState {
  final List<PreviousPaperModel> papers;
  final int? selectedYear;

  const PreviousPaperLoaded({required this.papers, this.selectedYear});

  @override
  List<Object?> get props => [papers, selectedYear];
}

class PreviousPaperEmpty extends PreviousPaperState {}

class PreviousPaperError extends PreviousPaperState {
  final String message;

  const PreviousPaperError(this.message);

  @override
  List<Object?> get props => [message];
}
