// lib/services/auth/token_refresh_service.dart

import 'dart:convert';
import 'package:BIBOL/config/bibol_api.dart';
import 'package:BIBOL/services/storage/secure_storage_service.dart';
import 'package:BIBOL/utils/logger.dart';
import 'package:http/http.dart' as http;

/// 🔄 Token Refresh Service
/// Handles automatic token refresh when the access token expires
/// 
/// Usage:
/// ```dart
/// final newToken = await TokenRefreshService.refreshToken();
/// if (newToken != null) {
///   // Token refreshed successfully
/// } else {
///   // Refresh failed, need to re-login
/// }
/// ```
class TokenRefreshService {
  // Private constructor
  TokenRefreshService._();

  /// Flag to prevent multiple simultaneous refresh requests
  static bool _isRefreshing = false;

  /// List of pending requests waiting for token refresh
  static final List<Function> _pendingCallbacks = [];

  /// Refresh the access token using the refresh token
  /// Returns the new access token if successful, null otherwise
  static Future<String?> refreshToken() async {
    try {
      // If already refreshing, wait for the result
      if (_isRefreshing) {
        AppLogger.debug('Token refresh already in progress, waiting...', tag: 'REFRESH');
        return await _waitForRefresh();
      }

      _isRefreshing = true;
      AppLogger.info('🔄 Starting token refresh...', tag: 'REFRESH');

      // Get current refresh token
      final refreshToken = await SecureStorageService.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        AppLogger.warning('No refresh token found, need to re-login', tag: 'REFRESH');
        _isRefreshing = false;
        return null;
      }

      // Call refresh token API
      final response = await http.post(
        Uri.parse(StudentsApiConfig.refreshTokenUrl()),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Token refresh timeout');
        },
      );

      AppLogger.debug('Refresh response: ${response.statusCode}', tag: 'REFRESH');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        
        // ตรวจสอบว่า API return format ไหน (ปรับตาม backend ของคุณ)
        String? newAccessToken;
        String? newRefreshToken;

        if (jsonData['success'] == true) {
          // Format 1: { "success": true, "data": { "token": "...", "refresh_token": "..." } }
          newAccessToken = jsonData['data']?['token'] ?? jsonData['data']?['access_token'];
          newRefreshToken = jsonData['data']?['refresh_token'];
        } else if (jsonData['access_token'] != null) {
          // Format 2: { "access_token": "...", "refresh_token": "..." }
          newAccessToken = jsonData['access_token'];
          newRefreshToken = jsonData['refresh_token'];
        } else if (jsonData['token'] != null) {
          // Format 3: { "token": "...", "refresh_token": "..." }
          newAccessToken = jsonData['token'];
          newRefreshToken = jsonData['refresh_token'];
        }

        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          // Save new tokens
          await SecureStorageService.saveToken(newAccessToken);
          
          if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
            await SecureStorageService.saveRefreshToken(newRefreshToken);
          }

          AppLogger.success('✅ Token refreshed successfully', tag: 'REFRESH');
          
          // Notify all pending callbacks
          _isRefreshing = false;
          _notifyPendingCallbacks(newAccessToken);
          
          return newAccessToken;
        } else {
          AppLogger.error('Invalid token format in response', tag: 'REFRESH');
          _isRefreshing = false;
          _notifyPendingCallbacks(null);
          return null;
        }
      } else if (response.statusCode == 401) {
        // Refresh token is also expired, need to re-login
        AppLogger.warning('Refresh token expired (401), need to re-login', tag: 'REFRESH');
        await SecureStorageService.clearAll();
        _isRefreshing = false;
        _notifyPendingCallbacks(null);
        return null;
      } else {
        AppLogger.error('Token refresh failed: ${response.statusCode}', tag: 'REFRESH');
        _isRefreshing = false;
        _notifyPendingCallbacks(null);
        return null;
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error refreshing token', tag: 'REFRESH', error: e);
      AppLogger.debug('Stack trace: $stackTrace', tag: 'REFRESH');
      _isRefreshing = false;
      _notifyPendingCallbacks(null);
      return null;
    }
  }

  /// Wait for ongoing refresh to complete
  static Future<String?> _waitForRefresh() async {
    final completer = <Function>[];
    String? result;
    
    _pendingCallbacks.add((String? token) {
      result = token;
    });

    // Wait for refresh to complete (max 15 seconds)
    int attempts = 0;
    while (_isRefreshing && attempts < 30) {
      await Future.delayed(const Duration(milliseconds: 500));
      attempts++;
    }

    return result;
  }

  /// Notify all pending callbacks with the result
  static void _notifyPendingCallbacks(String? token) {
    for (var callback in _pendingCallbacks) {
      callback(token);
    }
    _pendingCallbacks.clear();
  }

  /// Check if refresh token exists
  static Future<bool> hasRefreshToken() async {
    final refreshToken = await SecureStorageService.getRefreshToken();
    return refreshToken != null && refreshToken.isNotEmpty;
  }

  /// Check if token needs refresh (expired or about to expire)
  static Future<bool> needsRefresh() async {
    final isValid = await SecureStorageService.isTokenValid();
    return !isValid;
  }

  /// Clear refresh flag (for testing/debugging)
  static void resetRefreshFlag() {
    _isRefreshing = false;
    _pendingCallbacks.clear();
  }
}
