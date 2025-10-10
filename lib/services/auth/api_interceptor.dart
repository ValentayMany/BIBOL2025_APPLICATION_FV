// lib/services/auth/api_interceptor.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:BIBOL/services/auth/token_refresh_service.dart';
import 'package:BIBOL/utils/logger.dart';

/// 🔒 API Interceptor
/// Handles automatic token injection and refresh for HTTP requests
class ApiInterceptor {
  // Private constructor
  ApiInterceptor._();

  /// Make HTTP GET request with auto token refresh
  static Future<http.Response> get(
    String url, {
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    return await _makeRequest(
      () async {
        // Get valid token
        final token = await TokenRefreshService.getValidToken();

        // Prepare headers
        final requestHeaders = <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          ...?headers,
          if (token != null) 'Authorization': 'Bearer $token',
        };

        AppLogger.debug('GET: $url', tag: 'API');

        return await http.get(
          Uri.parse(url),
          headers: requestHeaders,
        );
      },
      timeout: timeout,
    );
  }

  /// Make HTTP POST request with auto token refresh
  static Future<http.Response> post(
    String url, {
    Map<String, String>? headers,
    Object? body,
    Duration? timeout,
  }) async {
    return await _makeRequest(
      () async {
        // Get valid token
        final token = await TokenRefreshService.getValidToken();

        // Prepare headers
        final requestHeaders = <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          ...?headers,
          if (token != null) 'Authorization': 'Bearer $token',
        };

        AppLogger.debug('POST: $url', tag: 'API');

        return await http.post(
          Uri.parse(url),
          headers: requestHeaders,
          body: body != null ? jsonEncode(body) : null,
        );
      },
      timeout: timeout,
    );
  }

  /// Make HTTP PUT request with auto token refresh
  static Future<http.Response> put(
    String url, {
    Map<String, String>? headers,
    Object? body,
    Duration? timeout,
  }) async {
    return await _makeRequest(
      () async {
        // Get valid token
        final token = await TokenRefreshService.getValidToken();

        // Prepare headers
        final requestHeaders = <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          ...?headers,
          if (token != null) 'Authorization': 'Bearer $token',
        };

        AppLogger.debug('PUT: $url', tag: 'API');

        return await http.put(
          Uri.parse(url),
          headers: requestHeaders,
          body: body != null ? jsonEncode(body) : null,
        );
      },
      timeout: timeout,
    );
  }

  /// Make HTTP DELETE request with auto token refresh
  static Future<http.Response> delete(
    String url, {
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    return await _makeRequest(
      () async {
        // Get valid token
        final token = await TokenRefreshService.getValidToken();

        // Prepare headers
        final requestHeaders = <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          ...?headers,
          if (token != null) 'Authorization': 'Bearer $token',
        };

        AppLogger.debug('DELETE: $url', tag: 'API');

        return await http.delete(
          Uri.parse(url),
          headers: requestHeaders,
        );
      },
      timeout: timeout,
    );
  }

  /// ============================================
  /// INTERNAL REQUEST HANDLER
  /// ============================================

  /// Make request with auto-retry on 401
  static Future<http.Response> _makeRequest(
    Future<http.Response> Function() requestFn, {
    Duration? timeout,
    int maxRetries = 1,
  }) async {
    int attempts = 0;

    while (attempts <= maxRetries) {
      try {
        // Make the request
        final response = timeout != null
            ? await requestFn().timeout(timeout)
            : await requestFn();

        AppLogger.debug('Response: ${response.statusCode}', tag: 'API');

        // Handle 401 Unauthorized - try to refresh token
        if (response.statusCode == 401 && attempts < maxRetries) {
          AppLogger.warning(
            '401 Unauthorized, attempting token refresh',
            tag: 'API',
          );

          // Try to refresh token
          final refreshed = await TokenRefreshService.refreshToken();

          if (refreshed) {
            AppLogger.success('Token refreshed, retrying request', tag: 'API');
            attempts++;
            continue; // Retry the request
          } else {
            AppLogger.error('Token refresh failed, aborting request', tag: 'API');
            // Return the 401 response
            return response;
          }
        }

        // Return successful or non-401 response
        return response;
      } catch (e) {
        AppLogger.error('API request error', tag: 'API', error: e);

        // If we've exhausted retries, rethrow
        if (attempts >= maxRetries) {
          rethrow;
        }

        attempts++;
      }
    }

    // Should not reach here, but just in case
    throw Exception('Max retries exceeded');
  }

  /// ============================================
  /// UTILITY METHODS
  /// ============================================

  /// Make request without authentication
  static Future<http.Response> getPublic(
    String url, {
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?headers,
    };

    AppLogger.debug('GET (Public): $url', tag: 'API');

    final request = http.get(
      Uri.parse(url),
      headers: requestHeaders,
    );

    return timeout != null ? await request.timeout(timeout) : await request;
  }

  /// Make POST request without authentication
  static Future<http.Response> postPublic(
    String url, {
    Map<String, String>? headers,
    Object? body,
    Duration? timeout,
  }) async {
    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?headers,
    };

    AppLogger.debug('POST (Public): $url', tag: 'API');

    final request = http.post(
      Uri.parse(url),
      headers: requestHeaders,
      body: body != null ? jsonEncode(body) : null,
    );

    return timeout != null ? await request.timeout(timeout) : await request;
  }

  /// Parse JSON response
  static dynamic parseResponse(http.Response response) {
    try {
      if (response.body.isEmpty) {
        return null;
      }
      return jsonDecode(response.body);
    } catch (e) {
      AppLogger.error('Error parsing response', tag: 'API', error: e);
      return null;
    }
  }

  /// Check if response is successful (2xx)
  static bool isSuccess(http.Response response) {
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  /// Get error message from response
  static String getErrorMessage(http.Response response) {
    try {
      final data = parseResponse(response);
      if (data != null && data is Map) {
        return data['message'] ?? data['error'] ?? 'Unknown error';
      }
      return 'Request failed with status ${response.statusCode}';
    } catch (e) {
      return 'Request failed with status ${response.statusCode}';
    }
  }
}
