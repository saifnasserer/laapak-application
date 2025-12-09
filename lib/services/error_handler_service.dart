import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../services/laapak_api_service.dart';
import '../utils/constants.dart';

/// Error Handler Service
///
/// Centralized error handling service that provides user-friendly error messages
/// and handles different types of errors consistently across the app.
class ErrorHandlerService {
  ErrorHandlerService._();
  static final ErrorHandlerService instance = ErrorHandlerService._();

  /// Get user-friendly error message from exception
  String getErrorMessage(dynamic error, {String? defaultMessage}) {
    if (error is LaapakApiException) {
      return _getApiErrorMessage(error);
    }

    final errorString = error.toString().toLowerCase();

    // Network errors
    if (errorString.contains('socketexception') ||
        errorString.contains('failed host lookup') ||
        errorString.contains('network is unreachable') ||
        errorString.contains('connection refused')) {
      return AppConstants.errorNetwork;
    }

    // Timeout errors
    if (errorString.contains('timeout') ||
        errorString.contains('timed out')) {
      return AppConstants.errorTimeout;
    }

    // Format errors
    if (errorString.contains('format') ||
        errorString.contains('codec') ||
        errorString.contains('invalid')) {
      return AppConstants.errorInvalidResponse;
    }

    // Return default or original error message
    return defaultMessage ?? AppConstants.errorGeneric;
  }

  /// Get API-specific error message
  String _getApiErrorMessage(LaapakApiException error) {
    switch (error.statusCode) {
      case 400:
        return error.message.isNotEmpty
            ? error.message
            : AppConstants.errorInvalidResponse;
      case 401:
        return AppConstants.errorUnauthorized;
      case 403:
        return error.message.isNotEmpty
            ? error.message
            : AppConstants.errorUnauthorized;
      case 404:
        return AppConstants.errorNotFound;
      case 408:
        return AppConstants.errorTimeout;
      case 429:
        return 'تم تجاوز الحد المسموح. يرجى المحاولة لاحقاً';
      case 500:
      case 502:
      case 503:
      case 504:
        return AppConstants.errorServer;
      default:
        return error.message.isNotEmpty
            ? error.message
            : AppConstants.errorGeneric;
    }
  }

  /// Show error snackbar
  void showErrorSnackBar(
    BuildContext context,
    dynamic error, {
    String? defaultMessage,
    Duration? duration,
  }) {
    if (!context.mounted) return;

    final message = getErrorMessage(error, defaultMessage: defaultMessage);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        duration: duration ?? AppConstants.snackbarDuration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show success snackbar
  void showSuccessSnackBar(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade700,
        duration: duration ?? AppConstants.snackbarDuration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show info snackbar
  void showInfoSnackBar(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue.shade700,
        duration: duration ?? AppConstants.snackbarDuration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Log error for debugging
  void logError(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
    Map<String, dynamic>? additionalInfo,
  }) {
    developer.log(
      'Error${context != null ? ' in $context' : ''}: ${error.toString()}',
      name: 'ErrorHandler',
      error: error,
      stackTrace: stackTrace,
    );

    if (additionalInfo != null && additionalInfo.isNotEmpty) {
      developer.log(
        'Additional info: $additionalInfo',
        name: 'ErrorHandler',
      );
    }
  }

  /// Handle error with logging and user notification
  void handleError(
    BuildContext buildContext,
    dynamic error,
    StackTrace? stackTrace, {
    String? errorContext,
    String? defaultMessage,
    bool showToUser = true,
    Map<String, dynamic>? additionalInfo,
  }) {
    // Log error
    logError(
      error,
      stackTrace,
      context: errorContext,
      additionalInfo: additionalInfo,
    );

    // Show to user if requested
    if (showToUser) {
      showErrorSnackBar(
        buildContext,
        error,
        defaultMessage: defaultMessage,
      );
    }
  }

  /// Check if error is retryable
  bool isRetryable(dynamic error) {
    if (error is LaapakApiException) {
      // Retry on server errors and timeouts
      return error.statusCode >= 500 ||
          error.statusCode == 408 ||
          error.statusCode == 429;
    }

    final errorString = error.toString().toLowerCase();
    return errorString.contains('timeout') ||
        errorString.contains('socketexception') ||
        errorString.contains('connection') ||
        errorString.contains('network');
  }

  /// Get retry delay based on attempt number
  Duration getRetryDelay(int attempt) {
    final delay = AppConstants.initialRetryDelay.inSeconds * (1 << (attempt - 1));
    final maxDelay = AppConstants.maxRetryDelay.inSeconds;
    return Duration(seconds: delay > maxDelay ? maxDelay : delay);
  }
}

