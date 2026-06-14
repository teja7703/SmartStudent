import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/previous_paper_repository.dart';
import 'previous_paper_state.dart';

class PreviousPaperCubit extends Cubit<PreviousPaperState> {
  final PreviousPaperRepository _repository;
  final String academicLevel;
  final String subject;

  PreviousPaperCubit({
    required PreviousPaperRepository repository,
    required this.academicLevel,
    required this.subject,
  })  : _repository = repository,
        super(PreviousPaperInitial());

  Future<void> loadPapers({int? year}) async {
    emit(PreviousPaperLoading());
    try {
      final papers = await _repository.getPapers(
        academicLevel: academicLevel,
        subject: subject,
        year: year,
      );
      if (papers.isEmpty) {
        emit(PreviousPaperEmpty());
      } else {
        emit(PreviousPaperLoaded(papers: papers, selectedYear: year));
      }
    } catch (e) {
      emit(PreviousPaperError(e.toString()));
    }
  }
}
