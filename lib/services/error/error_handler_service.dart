import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// 🛡️ Error Handler Service
///
/// Comprehensive error handling for BIBOL App
/// - Network errors
/// - API errors
/// - Timeout errors
/// - Retry mechanism
/// - Error logging
class ErrorHandlerService {
  static ErrorHandlerService? _instance;
  static ErrorHandlerService get instance =>
      _instance ??= ErrorHandlerService._();

  ErrorHandlerService._();

  // Error types
  static const String networkError = 'NETWORK_ERROR';
  static const String timeoutError = 'TIMEOUT_ERROR';
  static const String apiError = 'API_ERROR';
  static const String parsingError = 'PARSING_ERROR';
  static const String unknownError = 'UNKNOWN_ERROR';
  static const String authError = 'AUTH_ERROR';
  static const String serverError = 'SERVER_ERROR';

  // Retry configuration
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  static const Duration timeout = Duration(seconds: 30);

  /// 🔄 Execute with retry mechanism
  static Future<T> executeWithRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = maxRetries,
    Duration retryDelay = retryDelay,
    String? operationName,
  }) async {
    int attempts = 0;
    Exception? lastException;

    while (attempts < maxRetries) {
      try {
        attempts++;
        debugPrint(
          '🔄 Attempting $operationName (attempt $attempts/$maxRetries)',
        );

        final result = await operation().timeout(timeout);

        if (attempts > 1) {
          debugPrint('✅ $operationName succeeded on attempt $attempts');
        }

        return result;
      } on TimeoutException catch (e) {
        lastException = e;
        debugPrint('⏰ Timeout on attempt $attempts: $e');

        if (attempts >= maxRetries) {
          throw AppError(
            type: timeoutError,
            message: 'Request timed out after $maxRetries attempts',
            originalException: e,
            operationName: operationName,
          );
        }
      } on SocketException catch (e) {
        lastException = e;
        debugPrint('🌐 Network error on attempt $attempts: $e');

        if (attempts >= maxRetries) {
          throw AppError(
            type: networkError,
            message: 'No internet connection. Please check your network.',
            originalException: e,
            operationName: operationName,
          );
        }
      } on http.ClientException catch (e) {
        lastException = e;
        debugPrint('📡 HTTP client error on attempt $attempts: $e');

        if (attempts >= maxRetries) {
          throw AppError(
            type: networkError,
            message: 'Connection failed. Please try again.',
            originalException: e,
            operationName: operationName,
          );
        }
      } on AppError catch (e) {
        // Don't retry AppErrors unless they're network related
        if (e.type == networkError || e.type == timeoutError) {
          lastException = e;
          debugPrint('🔄 AppError (retryable) on attempt $attempts: $e');

          if (attempts >= maxRetries) {
            rethrow;
          }
        } else {
          rethrow;
        }
      } catch (e) {
        lastException = e as Exception;
        debugPrint('❌ Unexpected error on attempt $attempts: $e');

        if (attempts >= maxRetries) {
          throw AppError(
            type: unknownError,
            message: 'An unexpected error occurred',
            originalException: e,
            operationName: operationName,
          );
        }
      }

      // Wait before retry
      if (attempts < maxRetries) {
        debugPrint('⏳ Waiting ${retryDelay.inSeconds}s before retry...');
        await Future.delayed(retryDelay);
      }
    }

    throw lastException ??
        AppError(
          type: unknownError,
          message: 'Operation failed after $maxRetries attempts',
          operationName: operationName,
        );
  }

  /// 📡 Handle HTTP response
  static void handleHttpResponse(
    http.Response response, {
    String? operationName,
  }) {
    switch (response.statusCode) {
      case 200:
      case 201:
        // Success
        break;
      case 400:
        throw AppError(
          type: apiError,
          message: 'Invalid request. Please check your input.',
          statusCode: response.statusCode,
          responseBody: response.body,
          operationName: operationName,
        );
      case 401:
        throw AppError(
          type: authError,
          message: 'Authentication required. Please login again.',
          statusCode: response.statusCode,
          operationName: operationName,
        );
      case 403:
        throw AppError(
          type: authError,
          message: 'Access denied. You don\'t have permission.',
          statusCode: response.statusCode,
          operationName: operationName,
        );
      case 404:
        throw AppError(
          type: apiError,
          message: 'Resource not found.',
          statusCode: response.statusCode,
          operationName: operationName,
        );
      case 429:
        throw AppError(
          type: apiError,
          message: 'Too many requests. Please wait and try again.',
          statusCode: response.statusCode,
          operationName: operationName,
        );
      case 500:
      case 502:
      case 503:
      case 504:
        throw AppError(
          type: serverError,
          message: 'Server error. Please try again later.',
          statusCode: response.statusCode,
          operationName: operationName,
        );
      default:
        throw AppError(
          type: apiError,
          message: 'Request failed with status ${response.statusCode}',
          statusCode: response.statusCode,
          responseBody: response.body,
          operationName: operationName,
        );
    }
  }

  /// 🔍 Check network connectivity
  static Future<bool> checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      debugPrint('🌐 Connectivity check failed: $e');
      return false;
    }
  }

  /// 📝 Log error
  static void logError(AppError error) {
    debugPrint('❌ Error Logged:');
    debugPrint('   Type: ${error.type}');
    debugPrint('   Message: ${error.message}');
    debugPrint('   Operation: ${error.operationName ?? 'Unknown'}');
    debugPrint('   Status Code: ${error.statusCode ?? 'N/A'}');
    debugPrint('   Timestamp: ${DateTime.now()}');

    if (error.originalException != null) {
      debugPrint('   Original Exception: ${error.originalException}');
    }

    if (error.responseBody != null) {
      debugPrint('   Response Body: ${error.responseBody}');
    }
  }

  /// 🚨 Get user-friendly error message
  static String getUserFriendlyMessage(AppError error) {
    switch (error.type) {
      case networkError:
        return 'ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้ กรุณาตรวจสอบการเชื่อมต่อของคุณ';
      case timeoutError:
        return 'การเชื่อมต่อใช้เวลานานเกินไป กรุณาลองใหม่อีกครั้ง';
      case apiError:
        return 'เกิดข้อผิดพลาดในการดึงข้อมูล กรุณาลองใหม่อีกครั้ง';
      case parsingError:
        return 'เกิดข้อผิดพลาดในการประมวลผลข้อมูล';
      case authError:
        return 'กรุณาเข้าสู่ระบบอีกครั้ง';
      case serverError:
        return 'เซิร์ฟเวอร์กำลังมีปัญหา กรุณาลองใหม่อีกครั้ง';
      default:
        return 'เกิดข้อผิดพลาดที่ไม่คาดคิด กรุณาลองใหม่อีกครั้ง';
    }
  }

  /// 🎯 Get error icon
  static String getErrorIcon(AppError error) {
    switch (error.type) {
      case networkError:
        return '🌐';
      case timeoutError:
        return '⏰';
      case apiError:
        return '📡';
      case parsingError:
        return '📄';
      case authError:
        return '🔐';
      case serverError:
        return '🖥️';
      default:
        return '❌';
    }
  }

  /// 🔄 Should retry error
  static bool shouldRetry(AppError error) {
    return error.type == networkError ||
        error.type == timeoutError ||
        (error.type == serverError &&
            error.statusCode != null &&
            error.statusCode! >= 500);
  }
}

/// 🚨 Custom App Error Class
class AppError implements Exception {
  final String type;
  final String message;
  final int? statusCode;
  final String? responseBody;
  final String? operationName;
  final dynamic originalException;
  final DateTime timestamp;

  AppError({
    required this.type,
    required this.message,
    this.statusCode,
    this.responseBody,
    this.operationName,
    this.originalException,
  }) : timestamp = DateTime.now();

  @override
  String toString() {
    return 'AppError(type: $type, message: $message, statusCode: $statusCode, operation: $operationName)';
  }

  /// 📱 Get user-friendly message
  String get userFriendlyMessage =>
      ErrorHandlerService.getUserFriendlyMessage(this);

  /// 🎯 Get error icon
  String get icon => ErrorHandlerService.getErrorIcon(this);

  /// 🔄 Check if should retry
  bool get shouldRetry => ErrorHandlerService.shouldRetry(this);
}

/// 🔄 Network Error Handler
class NetworkErrorHandler {
  static Future<T> handleNetworkCall<T>(
    Future<T> Function() networkCall, {
    String? operationName,
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
  }) async {
    return ErrorHandlerService.executeWithRetry(
      networkCall,
      maxRetries: maxRetries,
      retryDelay: retryDelay,
      operationName: operationName,
    );
  }
}
