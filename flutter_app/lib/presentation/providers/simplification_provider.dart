import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_config.dart';
import '../../data/api/api_client.dart';
import 'history_provider.dart';
import 'language_provider.dart';

/// Simplification state class
class SimplificationState {

  SimplificationState({
    this.isLoading = false,
    this.originalText,
    this.simplifiedText,
    this.inferenceTimeMs,
    this.error,
  });
  final bool isLoading;
  final String? originalText;
  final String? simplifiedText;
  final double? inferenceTimeMs;
  final String? error;

  SimplificationState copyWith({
    bool? isLoading,
    String? originalText,
    String? simplifiedText,
    double? inferenceTimeMs,
    String? error,
  }) => SimplificationState(
      isLoading: isLoading ?? this.isLoading,
      originalText: originalText ?? this.originalText,
      simplifiedText: simplifiedText ?? this.simplifiedText,
      inferenceTimeMs: inferenceTimeMs ?? this.inferenceTimeMs,
      error: error ?? this.error,
    );

  bool get hasContent => simplifiedText != null;
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

    final language = ref.read(languageProvider).locale.languageCode;

    try {
      final response = await apiClient.simplifyText(text, language: language);

      state = state.copyWith(
        isLoading: false,
        originalText: response.original,
        simplifiedText: response.simplified,
        inferenceTimeMs: response.inferenceTimeMs,
        error: null,
      );

      // Save to history
      final title = text.length > 30 ? '${text.substring(0, 30)}...' : text;
      ref.read(historyProvider.notifier).addItem(
        title,
        response.simplified,
        HistoryType.simplification,
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
