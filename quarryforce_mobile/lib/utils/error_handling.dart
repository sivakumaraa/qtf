import 'package:flutter/material.dart';
import 'dart:async';
import '../utils/logger.dart';

/// Represents an API error with user-friendly messaging
class AppException implements Exception {
  final String message;
  final String? userMessage;
  final int? statusCode;
  final dynamic originalException;
  final StackTrace? stackTrace;
  final String? errorCode;

  AppException({
    required this.message,
    this.userMessage,
    this.statusCode,
    this.originalException,
    this.stackTrace,
    this.errorCode,
  });

  @override
  String toString() => 'AppException: $message (Code: $errorCode)';
}

/// Service for handling and managing errors across the app
class ErrorHandlingService {
  static final ErrorHandlingService _instance =
      ErrorHandlingService._internal();

  factory ErrorHandlingService() {
    return _instance;
  }

  ErrorHandlingService._internal();

  /// Parse and handle errors
  AppException handleError(dynamic error, [StackTrace? stackTrace]) {
    AppLogger.error('Error occurred', error, stackTrace);

    // Check if it's already an AppException
    if (error is AppException) {
      return error;
    }

    // Handle different error types
    if (error is FormatException) {
      return AppException(
        message: error.message,
        userMessage: 'Invalid data format. Please try again.',
        errorCode: 'FORMAT_ERROR',
        originalException: error,
        stackTrace: stackTrace,
      );
    }

    if (error is TimeoutException) {
      return AppException(
        message: 'Request timeout',
        userMessage: 'The request took too long. Please check your connection.',
        errorCode: 'TIMEOUT_ERROR',
        originalException: error,
        stackTrace: stackTrace,
      );
    }

    // Generic error handler
    return AppException(
      message: error.toString(),
      userMessage: 'An unexpected error occurred. Please try again.',
      errorCode: 'UNKNOWN_ERROR',
      originalException: error,
      stackTrace: stackTrace,
    );
  }

  /// Handle HTTP error responses
  AppException handleHttpError(int statusCode, String responseBody) {
    String userMessage;
    String errorCode;

    switch (statusCode) {
      case 400:
        userMessage = 'Invalid request. Please check your input.';
        errorCode = 'BAD_REQUEST';
        break;
      case 401:
        userMessage = 'Unauthorized. Please login again.';
        errorCode = 'UNAUTHORIZED';
        break;
      case 403:
        userMessage = 'Access forbidden. You don\'t have permission.';
        errorCode = 'FORBIDDEN';
        break;
      case 404:
        userMessage = 'The requested resource was not found.';
        errorCode = 'NOT_FOUND';
        break;
      case 409:
        userMessage = 'This resource already exists.';
        errorCode = 'CONFLICT';
        break;
      case 422:
        userMessage = 'Validation failed. Please check your data.';
        errorCode = 'VALIDATION_ERROR';
        break;
      case 429:
        userMessage = 'Too many requests. Please wait a moment.';
        errorCode = 'RATE_LIMIT';
        break;
      case 500:
        userMessage = 'Server error. Please try again later.';
        errorCode = 'SERVER_ERROR';
        break;
      case 503:
        userMessage = 'Service unavailable. Please try again later.';
        errorCode = 'SERVICE_UNAVAILABLE';
        break;
      default:
        userMessage = 'An error occurred. Please try again.';
        errorCode = 'HTTP_ERROR_$statusCode';
    }

    return AppException(
      message: 'HTTP Error $statusCode: $responseBody',
      userMessage: userMessage,
      statusCode: statusCode,
      errorCode: errorCode,
    );
  }

  /// Handle network errors
  AppException handleNetworkError(dynamic error) {
    AppLogger.warning('Network error: $error');

    return AppException(
      message: 'Network error: $error',
      userMessage: 'Network connection failed. Check your internet connection.',
      errorCode: 'NETWORK_ERROR',
      originalException: error,
    );
  }

  /// Get user-friendly error message
  String getUserMessage(AppException exception) {
    return exception.userMessage ?? exception.message;
  }

  /// Log error with context
  void logError(
    String context,
    dynamic error, [
    StackTrace? stackTrace,
  ]) {
    AppLogger.error('[$context] $error', error, stackTrace);
  }

  /// Show error dialog
  void showErrorDialog(
    BuildContext context,
    AppException exception, {
    VoidCallback? onRetry,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Error'),
        content: Text(getUserMessage(exception)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                onRetry();
              },
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }

  /// Show error snackbar
  void showErrorSnackbar(
    ScaffoldMessengerState scaffoldMessenger,
    AppException exception, {
    Duration duration = const Duration(seconds: 4),
  }) {
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(getUserMessage(exception)),
        backgroundColor: Colors.red[400],
        duration: duration,
      ),
    );
  }

  /// Log exception with breadcrumbs
  void logErrorWithContext(
    String feature,
    String action,
    dynamic error, [
    StackTrace? stackTrace,
  ]) {
    final context = 'Feature: $feature | Action: $action';
    logError(context, error, stackTrace);
  }
}

/// Extension for easier error handling
extension ErrorHandling on Exception {
  AppException toAppException([StackTrace? stackTrace]) {
    return ErrorHandlingService().handleError(this, stackTrace);
  }
}

/// Custom exceptions
class NetworkException extends AppException {
  NetworkException({String message = 'Network error'})
      : super(
          message: message,
          userMessage: 'Network connection failed. Check your internet.',
          errorCode: 'NETWORK_ERROR',
        );
}

class ServerException extends AppException {
  ServerException({String message = 'Server error'})
      : super(
          message: message,
          userMessage: 'Server error. Please try again later.',
          errorCode: 'SERVER_ERROR',
        );
}

class ValidationException extends AppException {
  ValidationException({required String message})
      : super(
          message: message,
          userMessage: 'Validation failed. Please check your input.',
          errorCode: 'VALIDATION_ERROR',
        );
}

class AuthException extends AppException {
  AuthException({String message = 'Authentication failed'})
      : super(
          message: message,
          userMessage: 'Authentication failed. Please login again.',
          errorCode: 'AUTH_ERROR',
        );
}
