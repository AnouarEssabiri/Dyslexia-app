import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/app_config.dart';

/// Authentication state class
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final User? user;
  final String? error;

  AuthState({
    required this.isLoading,
    required this.isAuthenticated,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    User? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}

/// Auth provider class
class AuthNotifier extends Notifier<AuthState> {
  late final SupabaseClient supabaseClient;

  @override
  AuthState build() {
    supabaseClient = Supabase.instance.client;
    return AuthState(
      isLoading: false,
      isAuthenticated: supabaseClient.auth.currentSession != null,
      user: supabaseClient.auth.currentUser,
      error: null,
    );
  }

  /// Sign up with email and password
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {'display_name': name},
      );

      if (response.user != null) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: response.user,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Sign up failed',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Sign in with email and password
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: response.user,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Sign in failed',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);

    try {
      await supabaseClient.auth.signOut();
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        user: null,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Auth provider
final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

/// User provider (for easy access to current user)
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});
