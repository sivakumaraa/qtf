import 'package:flutter/foundation.dart';

/// Simple logging utility for the application
class AppLogger {
  static const String _tag = 'QuarryForce';
  static bool _debugMode = true;

  /// Set debug mode for logging
  static void setDebugMode(bool enabled) {
    _debugMode = enabled;
  }

  /// Log info level message
  static void info(String message) {
    if (_debugMode) {
      debugPrint('[$_tag] INFO: $message');
    }
  }

  /// Log debug level message
  static void debug(String message) {
    if (_debugMode) {
      debugPrint('[$_tag] DEBUG: $message');
    }
  }

  /// Log warning level message
  static void warning(String message) {
    if (_debugMode) {
      debugPrint('[$_tag] WARNING: $message');
    }
  }

  /// Log error level message
  static void error(String message,
      [dynamic exception, StackTrace? stackTrace]) {
    debugPrint('[$_tag] ERROR: $message');
    if (exception != null) {
      debugPrint('Exception: $exception');
    }
    if (stackTrace != null) {
      debugPrint('StackTrace: $stackTrace');
    }
  }

  /// Log divider for section breaks
  static void divider(String title) {
    if (_debugMode) {
      final padding = (40 - title.length) ~/ 2;
      final divider = '=' * 40;
      debugPrint(
          '[$_tag] ${divider.substring(0, padding)}$title${divider.substring(padding + title.length)}');
    }
  }
}
