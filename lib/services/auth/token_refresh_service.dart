// lib/services/auth/token_refresh_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:BIBOL/config/environment.dart';
import 'package:BIBOL/services/storage/secure_storage_service.dart';
import 'package:BIBOL/utils/logger.dart';

/// 🔄 Token Refresh Service
/// Handles automatic token refresh and authentication state
class TokenRefreshService {
  // Private constructor for singleton
  TokenRefreshService._();

  // Singleton instance
  static final TokenRefreshService _instance = TokenRefreshService._();
  static TokenRefreshService get instance => _instance;

  // Refresh endpoint
  static String get _refreshEndpoint =>
      '${EnvironmentConfig.apiBaseUrl}/students/refresh';

  // Flag to prevent multiple simultaneous refresh attempts
  static bool _isRefreshing = false;

  // Queue for pending requests during refresh
  static final List<Function> _pendingRequests = [];

  /// ============================================
  /// TOKEN VALIDATION
  /// ============================================

  /// Check if token needs refresh (within 5 minutes of expiry)
  static Future<bool> needsRefresh() async {
    try {
      final expiryStr =
          await SecureStorageService.getToken(); // Get from secure storage
      if (expiryStr == null) return true;

      // Check if token is close to expiry (within 5 minutes)
      final isValid = await SecureStorageService.isTokenValid();
      if (!isValid) {
        AppLogger.warning('Token expired or invalid', tag: 'TOKEN');
        return true;
      }

      return false;
    } catch (e) {
      AppLogger.error('Error checking token expiry', tag: 'TOKEN', error: e);
      return true;
    }
  }

  /// Validate token before making API call
  static Future<bool> validateToken() async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) {
        AppLogger.warning('No token found', tag: 'TOKEN');
        return false;
      }

      final isValid = await SecureStorageService.isTokenValid();
      if (!isValid) {
        AppLogger.warning('Token is invalid or expired', tag: 'TOKEN');
        return false;
      }

      return true;
    } catch (e) {
      AppLogger.error('Error validating token', tag: 'TOKEN', error: e);
      return false;
    }
  }

  /// ============================================
  /// TOKEN REFRESH
  /// ============================================

  /// Refresh the authentication token
  static Future<bool> refreshToken() async {
    // Prevent multiple simultaneous refresh attempts
    if (_isRefreshing) {
      AppLogger.debug('Token refresh already in progress', tag: 'TOKEN');
      return await _waitForRefresh();
    }

    _isRefreshing = true;
    AppLogger.info('Starting token refresh...', tag: 'TOKEN');

    try {
      // Get current refresh token
      final refreshToken = await SecureStorageService.getRefreshToken();
      if (refreshToken == null) {
        AppLogger.error('No refresh token available', tag: 'TOKEN');
        await _handleRefreshFailure();
        return false;
      }

      // Get current auth token for request
      final currentToken = await SecureStorageService.getToken();

      // Make refresh request
      final response = await http
          .post(
            Uri.parse(_refreshEndpoint),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              if (currentToken != null) 'Authorization': 'Bearer $currentToken',
            },
            body: jsonEncode({
              'refresh_token': refreshToken,
            }),
          )
          .timeout(
            EnvironmentConfig.apiTimeout,
          );

      AppLogger.debug('Refresh response: ${response.statusCode}', tag: 'TOKEN');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Extract new tokens
        final newToken = data['token'] ?? data['access_token'];
        final newRefreshToken =
            data['refresh_token'] ?? data['refreshToken'] ?? refreshToken;

        if (newToken != null) {
          // Save new tokens
          await SecureStorageService.saveToken(newToken);
          await SecureStorageService.saveRefreshToken(newRefreshToken);

          AppLogger.success('Token refreshed successfully', tag: 'TOKEN');
          _isRefreshing = false;

          // Process pending requests
          _processPendingRequests(success: true);

          return true;
        } else {
          AppLogger.error('No token in refresh response', tag: 'TOKEN');
          await _handleRefreshFailure();
          return false;
        }
      } else if (response.statusCode == 401) {
        // Refresh token is invalid or expired
        AppLogger.error('Refresh token expired or invalid', tag: 'TOKEN');
        await _handleRefreshFailure();
        return false;
      } else {
        AppLogger.error(
          'Token refresh failed: ${response.statusCode}',
          tag: 'TOKEN',
        );
        await _handleRefreshFailure();
        return false;
      }
    } catch (e) {
      AppLogger.error('Token refresh error', tag: 'TOKEN', error: e);
      await _handleRefreshFailure();
      return false;
    }
  }

  /// ============================================
  /// AUTO REFRESH BEFORE API CALLS
  /// ============================================

  /// Ensure token is valid before API call, refresh if needed
  static Future<bool> ensureValidToken() async {
    try {
      // Check if we have a token
      final hasToken = await validateToken();
      if (!hasToken) {
        AppLogger.warning('No valid token, attempting refresh', tag: 'TOKEN');

        // Try to refresh
        final refreshed = await refreshToken();
        if (!refreshed) {
          AppLogger.error('Failed to refresh token', tag: 'TOKEN');
          return false;
        }
      }

      // Check if token needs refresh (within 5 minutes of expiry)
      if (await needsRefresh()) {
        AppLogger.info('Token needs refresh, refreshing...', tag: 'TOKEN');
        final refreshed = await refreshToken();
        if (!refreshed) {
          AppLogger.error('Failed to refresh token', tag: 'TOKEN');
          return false;
        }
      }

      return true;
    } catch (e) {
      AppLogger.error('Error ensuring valid token', tag: 'TOKEN', error: e);
      return false;
    }
  }

  /// ============================================
  /// HELPER METHODS
  /// ============================================

  /// Handle refresh failure - logout user
  static Future<void> _handleRefreshFailure() async {
    try {
      _isRefreshing = false;
      _processPendingRequests(success: false);

      // Clear all authentication data
      await SecureStorageService.clearAll();

      AppLogger.warning('User logged out due to token refresh failure', tag: 'TOKEN');
    } catch (e) {
      AppLogger.error('Error handling refresh failure', tag: 'TOKEN', error: e);
    }
  }

  /// Wait for ongoing refresh to complete
  static Future<bool> _waitForRefresh() async {
    bool result = false;

    // Add callback to pending requests
    _pendingRequests.add(() {
      result = true;
    });

    // Wait for refresh to complete (max 10 seconds)
    int attempts = 0;
    while (_isRefreshing && attempts < 100) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }

    return result;
  }

  /// Process pending requests after refresh completes
  static void _processPendingRequests({required bool success}) {
    try {
      for (final request in _pendingRequests) {
        request();
      }
      _pendingRequests.clear();
    } catch (e) {
      AppLogger.error('Error processing pending requests', tag: 'TOKEN', error: e);
    }
  }

  /// ============================================
  /// UTILITY METHODS
  /// ============================================

  /// Get current token (after ensuring it's valid)
  static Future<String?> getValidToken() async {
    final isValid = await ensureValidToken();
    if (!isValid) {
      return null;
    }

    return await SecureStorageService.getToken();
  }

  /// Check if user is authenticated with valid token
  static Future<bool> isAuthenticated() async {
    try {
      final isLoggedIn = await SecureStorageService.isLoggedIn();
      if (!isLoggedIn) {
        return false;
      }

      final hasValidToken = await validateToken();
      if (!hasValidToken) {
        // Try to refresh
        final refreshed = await refreshToken();
        return refreshed;
      }

      return true;
    } catch (e) {
      AppLogger.error('Error checking authentication', tag: 'TOKEN', error: e);
      return false;
    }
  }

  /// Force logout (clear all tokens)
  static Future<void> logout() async {
    try {
      AppLogger.info('Logging out user...', tag: 'TOKEN');
      await SecureStorageService.clearAll();
      _isRefreshing = false;
      _pendingRequests.clear();
      AppLogger.success('User logged out successfully', tag: 'TOKEN');
    } catch (e) {
      AppLogger.error('Error during logout', tag: 'TOKEN', error: e);
    }
  }

  /// Debug: Print token status
  static Future<void> debugPrintStatus() async {
    if (kDebugMode) {
      try {
        AppLogger.section('TOKEN STATUS');
        final token = await SecureStorageService.getToken();
        final refreshToken = await SecureStorageService.getRefreshToken();
        final isValid = await SecureStorageService.isTokenValid();
        final isLoggedIn = await SecureStorageService.isLoggedIn();

        AppLogger.debug('Has Token: ${token != null}', tag: 'TOKEN');
        AppLogger.debug('Has Refresh Token: ${refreshToken != null}', tag: 'TOKEN');
        AppLogger.debug('Token Valid: $isValid', tag: 'TOKEN');
        AppLogger.debug('Is Logged In: $isLoggedIn', tag: 'TOKEN');
        AppLogger.debug('Is Refreshing: $_isRefreshing', tag: 'TOKEN');
        AppLogger.debug('Pending Requests: ${_pendingRequests.length}', tag: 'TOKEN');
        AppLogger.divider();
      } catch (e) {
        AppLogger.error('Error printing token status', tag: 'TOKEN', error: e);
      }
    }
  }
}
