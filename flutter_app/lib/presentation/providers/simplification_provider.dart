import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_config.dart';
import '../../data/api/api_client.dart';

/// Simplification state class
class SimplificationState {
  final bool isLoading;
  final String? originalText;
  final String? simplifiedText;
  final double? inferenceTimeMs;
  final String? error;

  SimplificationState({
    required this.isLoading,
    this.originalText,
    this.simplifiedText,
    this.inferenceTimeMs,
    this.error,
  });

  SimplificationState copyWith({
    bool? isLoading,
    String? originalText,
    String? simplifiedText,
    double? inferenceTimeMs,
    String? error,
  }) {
    return SimplificationState(
      isLoading: isLoading ?? this.isLoading,
      originalText: originalText ?? this.originalText,
      simplifiedText: simplifiedText ?? this.simplifiedText,
      inferenceTimeMs: inferenceTimeMs ?? this.inferenceTimeMs,
      error: error ?? this.error,
    );
  }

  bool get hasContent => originalText != null && simplifiedText != null;
}

/// Simplification notifier
class SimplificationNotifier extends Notifier<SimplificationState> {
  late final ApiClient apiClient;

  @override
  SimplificationState build() {
    apiClient = ref.watch(apiClientProvider);
    return SimplificationState(isLoading: false);
  }

  /// Simplify text with debouncing
  Future<void> simplifyText(String text) async {
    if (text.isEmpty) {
      state = state.copyWith(error: 'Text cannot be empty');
      return;
    }

    if (text.length > AppConfig.maxTextLength) {
      state = state.copyWith(
        error: 'Text is too long. Maximum ${AppConfig.maxTextLength} characters allowed.',
      );
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await apiClient.simplifyText(text);

      state = state.copyWith(
        isLoading: false,
        originalText: response.original,
        simplifiedText: response.simplified,
        inferenceTimeMs: response.inferenceTimeMs,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Clear results
  void clearResults() {
    state = SimplificationState(isLoading: false);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Simplification provider
final simplificationProvider =
    NotifierProvider<SimplificationNotifier, SimplificationState>(SimplificationNotifier.new);
