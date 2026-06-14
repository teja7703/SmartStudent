import 'package:equatable/equatable.dart';
import '../models/career_model.dart';

abstract class CareerState extends Equatable {
  const CareerState();

  @override
  List<Object?> get props => [];
}

class CareerInitial extends CareerState {}

class CareerLoading extends CareerState {}

class CareerLoaded extends CareerState {
  final List<CareerModel> careers;
  final String searchQuery;

  const CareerLoaded({required this.careers, this.searchQuery = ''});

  @override
  List<Object?> get props => [careers, searchQuery];
}

class CareerEmpty extends CareerState {}

class CareerError extends CareerState {
  final String message;

  const CareerError(this.message);

  @override
  List<Object?> get props => [message];
}

class CareerDetailLoading extends CareerState {}

class CareerDetailLoaded extends CareerState {
  final CareerModel career;

  const CareerDetailLoaded(this.career);

  @override
  List<Object?> get props => [career];
}

class CareerDetailError extends CareerState {
  final String message;

  const CareerDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
