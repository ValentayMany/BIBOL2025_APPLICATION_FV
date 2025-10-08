// lib/utils/logger.dart

import 'package:flutter/foundation.dart';
import 'package:BIBOL/config/environment.dart';

/// 📝 App Logger
/// Centralized logging utility with different log levels
class AppLogger {
  // Private constructor
  AppLogger._();

  // ANSI color codes for terminal output
  static const String _reset = '\x1B[0m';
  static const String _red = '\x1B[31m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _blue = '\x1B[34m';
  static const String _magenta = '\x1B[35m';
  static const String _cyan = '\x1B[36m';
  static const String _white = '\x1B[37m';

  /// Log levels
  enum Level {
    debug,
    info,
    warning,
    error,
    critical,
  }

  /// Check if logging is enabled
  static bool get _isEnabled => EnvironmentConfig.enableLogging;

  /// ============================================
  /// MAIN LOGGING METHODS
  /// ============================================

  /// Debug log (detailed information for debugging)
  static void debug(String message, {String? tag}) {
    if (_isEnabled && kDebugMode) {
      _log(Level.debug, message, tag: tag, color: _cyan);
    }
  }

  /// Info log (general information)
  static void info(String message, {String? tag}) {
    if (_isEnabled) {
      _log(Level.info, message, tag: tag, color: _blue);
    }
  }

  /// Warning log (potential issues)
  static void warning(String message, {String? tag}) {
    if (_isEnabled) {
      _log(Level.warning, message, tag: tag, color: _yellow);
    }
  }

  /// Error log (errors that need attention)
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (_isEnabled) {
      _log(Level.error, message, tag: tag, color: _red);
      if (error != null) {
        debugPrint('$_red   Error: $error$_reset');
      }
      if (stackTrace != null) {
        debugPrint('$_red   StackTrace: $stackTrace$_reset');
      }
    }
  }

  /// Critical log (critical errors that need immediate attention)
  static void critical(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(Level.critical, message, tag: tag, color: _magenta);
    if (error != null) {
      debugPrint('$_magenta   Error: $error$_reset');
    }
    if (stackTrace != null) {
      debugPrint('$_magenta   StackTrace: $stackTrace$_reset');
    }
  }

  /// Success log (successful operations)
  static void success(String message, {String? tag}) {
    if (_isEnabled) {
      _log(Level.info, message, tag: tag, color: _green, prefix: '✅');
    }
  }

  /// ============================================
  /// SPECIALIZED LOGGING METHODS
  /// ============================================

  /// API request log
  static void apiRequest(String method, String url, {Map<String, dynamic>? params}) {
    if (_isEnabled) {
      debug('API Request: $method $url', tag: 'API');
      if (params != null && params.isNotEmpty) {
        debug('  Params: $params', tag: 'API');
      }
    }
  }

  /// API response log
  static void apiResponse(int statusCode, String url, {dynamic data}) {
    if (_isEnabled) {
      if (statusCode >= 200 && statusCode < 300) {
        success('API Response: $statusCode $url', tag: 'API');
      } else {
        error('API Response: $statusCode $url', tag: 'API');
      }
      if (data != null && kDebugMode) {
        debug('  Data: $data', tag: 'API');
      }
    }
  }

  /// Navigation log
  static void navigation(String from, String to) {
    if (_isEnabled) {
      info('Navigation: $from → $to', tag: 'NAV');
    }
  }

  /// State change log
  static void stateChange(String widget, String oldState, String newState) {
    if (_isEnabled && kDebugMode) {
      debug('State: $widget | $oldState → $newState', tag: 'STATE');
    }
  }

  /// Performance log
  static void performance(String operation, Duration duration) {
    if (_isEnabled) {
      final ms = duration.inMilliseconds;
      if (ms > 1000) {
        warning('Performance: $operation took ${ms}ms', tag: 'PERF');
      } else {
        debug('Performance: $operation took ${ms}ms', tag: 'PERF');
      }
    }
  }

  /// Database operation log
  static void database(String operation, {String? table}) {
    if (_isEnabled && kDebugMode) {
      final message = table != null ? '$operation on $table' : operation;
      debug('Database: $message', tag: 'DB');
    }
  }

  /// ============================================
  /// INTERNAL METHODS
  /// ============================================

  /// Internal log method
  static void _log(
    Level level,
    String message, {
    String? tag,
    String color = _white,
    String? prefix,
  }) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 23);
    final levelStr = level.name.toUpperCase().padRight(8);
    final tagStr = tag != null ? '[$tag]'.padRight(12) : '';
    final prefixStr = prefix ?? _getLevelPrefix(level);
    
    final logMessage = '$color$prefixStr $timestamp $levelStr $tagStr $message$_reset';
    debugPrint(logMessage);
  }

  /// Get emoji prefix for log level
  static String _getLevelPrefix(Level level) {
    switch (level) {
      case Level.debug:
        return '🐛';
      case Level.info:
        return 'ℹ️';
      case Level.warning:
        return '⚠️';
      case Level.error:
        return '❌';
      case Level.critical:
        return '🔥';
    }
  }

  /// ============================================
  /// UTILITY METHODS
  /// ============================================

  /// Start performance measurement
  static Stopwatch startPerformance(String operation) {
    final stopwatch = Stopwatch()..start();
    if (_isEnabled && kDebugMode) {
      debug('Started: $operation', tag: 'PERF');
    }
    return stopwatch;
  }

  /// End performance measurement
  static void endPerformance(String operation, Stopwatch stopwatch) {
    stopwatch.stop();
    performance(operation, stopwatch.elapsed);
  }

  /// Log section header (for organizing logs)
  static void section(String title) {
    if (_isEnabled) {
      debugPrint('');
      debugPrint('$_white═══════════════════════════════════════$_reset');
      debugPrint('$_white  $title$_reset');
      debugPrint('$_white═══════════════════════════════════════$_reset');
    }
  }

  /// Log divider
  static void divider() {
    if (_isEnabled) {
      debugPrint('$_white───────────────────────────────────────$_reset');
    }
  }
}
