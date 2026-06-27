import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/result.dart';
import 'auth_state.dart';
import 'auth_providers.dart';

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState.initial();

  Future<bool> authenticateNewInterviewer(String email, String lastFourDigits) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await ref.read(authenticateNewInterviewerProvider).call(email, lastFourDigits);
    switch (result) {
      case Success(:final data):
        state = state.copyWith(isLoading: false, isAuthenticated: true, user: data);
        return true;
      case Err(:final failure):
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
    }
  }

  Future<bool> authenticateExistingInterviewer(String username, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await ref.read(authenticateExistingInterviewerProvider).call(username, password);
    switch (result) {
      case Success(:final data):
        state = state.copyWith(isLoading: false, isAuthenticated: true, user: data);
        return true;
      case Err(:final failure):
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
    }
  }

  void logout() => state = const AuthState.initial();
}

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
