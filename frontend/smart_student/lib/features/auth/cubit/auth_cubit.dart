import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    try {
      final user = await _repository.getStoredUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    try {
      final user = await _repository.signInWithGoogle();
      emit(AuthAuthenticated(user));
    } catch (e) {
      final message = e.toString().contains('cancelled')
          ? 'Sign in was cancelled'
          : 'Failed to sign in. Please try again.';
      emit(AuthError(message));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    emit(AuthUnauthenticated());
  }
}
