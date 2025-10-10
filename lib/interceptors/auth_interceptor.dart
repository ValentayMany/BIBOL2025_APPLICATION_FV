// lib/interceptors/auth_interceptor.dart

import 'dart:convert';
import 'package:BIBOL/services/auth/token_refresh_service.dart';
import 'package:BIBOL/services/storage/secure_storage_service.dart';
import 'package:BIBOL/utils/logger.dart';
import 'package:http/http.dart' as http;

/// 🛡️ HTTP Interceptor for automatic token refresh
/// 
/// This class intercepts HTTP requests and responses to:
/// 1. Automatically add Authorization header to requests
/// 2. Detect 401 (Unauthorized) responses
/// 3. Automatically refresh expired tokens
/// 4. Retry failed requests with new token
/// 
/// Usage:
/// ```dart
/// // Instead of:
/// final response = await http.get(url, headers: headers);
/// 
/// // Use:
/// final response = await AuthInterceptor.get(url);
/// ```
class AuthInterceptor {
  // Private constructor
  AuthInterceptor._();

  /// Make a GET request with automatic token refresh
  static Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    return _makeRequest(
      () => http.get(url, headers: await _buildHeaders(headers))
          .timeout(timeout ?? const Duration(seconds: 30)),
      url,
      'GET',
      headers,
    );
  }

  /// Make a POST request with automatic token refresh
  static Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    Duration? timeout,
  }) async {
    return _makeRequest(
      () async {
        return http.post(
          url,
          headers: await _buildHeaders(headers),
          body: body,
          encoding: encoding,
        ).timeout(timeout ?? const Duration(seconds: 30));
      },
      url,
      'POST',
      headers,
      body: body,
      encoding: encoding,
    );
  }

  /// Make a PUT request with automatic token refresh
  static Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    Duration? timeout,
  }) async {
    return _makeRequest(
      () async {
        return http.put(
          url,
          headers: await _buildHeaders(headers),
          body: body,
          encoding: encoding,
        ).timeout(timeout ?? const Duration(seconds: 30));
      },
      url,
      'PUT',
      headers,
      body: body,
      encoding: encoding,
    );
  }

  /// Make a DELETE request with automatic token refresh
  static Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    Duration? timeout,
  }) async {
    return _makeRequest(
      () async {
        return http.delete(
          url,
          headers: await _buildHeaders(headers),
          body: body,
          encoding: encoding,
        ).timeout(timeout ?? const Duration(seconds: 30));
      },
      url,
      'DELETE',
      headers,
      body: body,
      encoding: encoding,
    );
  }

  /// Core method to make request with retry logic
  static Future<http.Response> _makeRequest(
    Future<http.Response> Function() requestFunction,
    Uri url,
    String method, [
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  ]) async {
    try {
      AppLogger.debug('$method ${url.path}', tag: 'HTTP');

      // Make the initial request
      var response = await requestFunction();

      // Check if response is 401 (Unauthorized)
      if (response.statusCode == 401) {
        AppLogger.warning('Got 401, attempting token refresh...', tag: 'HTTP');

        // Try to refresh token
        final newToken = await TokenRefreshService.refreshToken();

        if (newToken != null) {
          // Retry the request with new token
          AppLogger.info('Retrying request with new token', tag: 'HTTP');

          // Rebuild headers with new token
          final newHeaders = await _buildHeaders(headers);

          // Retry the request based on method
          switch (method) {
            case 'GET':
              response = await http.get(url, headers: newHeaders);
              break;
            case 'POST':
              response = await http.post(
                url,
                headers: newHeaders,
                body: body,
                encoding: encoding,
              );
              break;
            case 'PUT':
              response = await http.put(
                url,
                headers: newHeaders,
                body: body,
                encoding: encoding,
              );
              break;
            case 'DELETE':
              response = await http.delete(
                url,
                headers: newHeaders,
                body: body,
                encoding: encoding,
              );
              break;
          }

          if (response.statusCode == 200 || response.statusCode == 201) {
            AppLogger.success('Request succeeded after token refresh', tag: 'HTTP');
          }
        } else {
          // Token refresh failed, user needs to login again
          AppLogger.error('Token refresh failed, need re-login', tag: 'HTTP');
          // You can emit an event here to trigger logout/login screen
        }
      }

      return response;
    } catch (e, stackTrace) {
      AppLogger.error('Request failed: $method ${url.path}', tag: 'HTTP', error: e);
      AppLogger.debug('Stack trace: $stackTrace', tag: 'HTTP');
      rethrow;
    }
  }

  /// Build headers with Authorization token
  static Future<Map<String, String>> _buildHeaders([Map<String, String>? customHeaders]) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      ...?customHeaders,
    };

    // Add Authorization header if token exists
    final token = await SecureStorageService.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// Get headers without making a request (utility method)
  static Future<Map<String, String>> buildHeaders([Map<String, String>? customHeaders]) async {
    return _buildHeaders(customHeaders);
  }
}
