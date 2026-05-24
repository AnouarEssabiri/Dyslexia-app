import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_config.dart';

/// Simplification response model
class SimplificationResponse {

  SimplificationResponse({
    required this.original,
    required this.simplified,
    required this.inferenceTimeMs,
  });

  factory SimplificationResponse.fromJson(Map<String, dynamic> json) {
    return SimplificationResponse(
      original: json['original'] as String,
      simplified: json['simplified'] as String,
      inferenceTimeMs: (json['inference_time_ms'] as num).toDouble(),
    );
  }
  final String original;
  final String simplified;
  final double inferenceTimeMs;
}

/// API client for backend communication
class ApiClient {

  ApiClient({Dio? dio}) : dio = dio ?? Dio() {
    // Configure Dio
    this.dio.options = BaseOptions(
      baseUrl: AppConfig.backendUrl,
      connectTimeout: AppConfig.apiTimeout,
      receiveTimeout: AppConfig.apiTimeout,
      contentType: 'application/json',
    );

    // Add logging interceptor
    this.dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
      ),
    );
  }
  final Dio dio;

  /// Simplify text using backend AI model
  Future<SimplificationResponse> simplifyText(
    String text, {
    String language = 'en',
    int maxLength = 512,
  }) async {
    try {
      final response = await dio.post(
        '${AppConfig.apiPrefix}/simplify',
        data: {
          'text': text,
          'language': language,
          'max_length': maxLength,
        },
      );

      return SimplificationResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Check backend health
  Future<Map<String, dynamic>> getHealth() async {
    try {
      final response = await dio.get('/health');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get AI service status
  Future<Map<String, dynamic>> getAiStatus() async {
    try {
      final response = await dio.get('/ai/status');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Handle DIO errors
  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Request timeout. Please try again.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 422) {
          return 'Invalid input. Please check your text.';
        } else if (statusCode == 429) {
          return 'Too many requests. Please wait a moment.';
        } else if (statusCode == 503) {
          return 'AI service temporarily unavailable. Please try again later.';
        }
        return 'Server error: $statusCode';
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return 'Network error. Please check your connection.';
        }
        return error.message ?? 'Unknown error';
      default:
        return error.message ?? 'An error occurred';
    }
  }
}

/// API client provider
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
