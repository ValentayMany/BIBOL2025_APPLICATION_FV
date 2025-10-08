// lib/services/storage/secure_storage_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 🔐 Secure Storage Service
/// Handles secure storage of sensitive data like tokens and user credentials
class SecureStorageService {
  // Private constructor
  SecureStorageService._();

  /// Secure storage instance
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  // Storage Keys
  static const String _keyAuthToken = 'auth_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserInfo = 'user_info';
  static const String _keyLoginStatus = 'is_logged_in';
  static const String _keyTokenExpiry = 'token_expiry';

  /// ============================================
  /// TOKEN MANAGEMENT
  /// ============================================

  /// Save authentication token securely
  static Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(key: _keyAuthToken, value: token);
      // Also save expiry time (default 24 hours from now)
      final expiry = DateTime.now().add(const Duration(hours: 24));
      await _secureStorage.write(
        key: _keyTokenExpiry,
        value: expiry.toIso8601String(),
      );
      debugPrint('✅ Token saved securely');
    } catch (e) {
      debugPrint('❌ Error saving token: $e');
      rethrow;
    }
  }

  /// Get authentication token
  static Future<String?> getToken() async {
    try {
      final token = await _secureStorage.read(key: _keyAuthToken);
      if (token != null && await isTokenValid()) {
        return token;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting token: $e');
      return null;
    }
  }

  /// Save refresh token
  static Future<void> saveRefreshToken(String refreshToken) async {
    try {
      await _secureStorage.write(key: _keyRefreshToken, value: refreshToken);
      debugPrint('✅ Refresh token saved securely');
    } catch (e) {
      debugPrint('❌ Error saving refresh token: $e');
      rethrow;
    }
  }

  /// Get refresh token
  static Future<String?> getRefreshToken() async {
    try {
      return await _secureStorage.read(key: _keyRefreshToken);
    } catch (e) {
      debugPrint('❌ Error getting refresh token: $e');
      return null;
    }
  }

  /// Check if token is valid (not expired)
  static Future<bool> isTokenValid() async {
    try {
      final expiryStr = await _secureStorage.read(key: _keyTokenExpiry);
      if (expiryStr == null) return false;

      final expiry = DateTime.parse(expiryStr);
      final isValid = DateTime.now().isBefore(expiry);
      
      if (!isValid) {
        debugPrint('⚠️ Token expired');
      }
      
      return isValid;
    } catch (e) {
      debugPrint('❌ Error checking token validity: $e');
      return false;
    }
  }

  /// Delete authentication token
  static Future<void> deleteToken() async {
    try {
      await _secureStorage.delete(key: _keyAuthToken);
      await _secureStorage.delete(key: _keyRefreshToken);
      await _secureStorage.delete(key: _keyTokenExpiry);
      debugPrint('✅ Tokens deleted');
    } catch (e) {
      debugPrint('❌ Error deleting token: $e');
      rethrow;
    }
  }

  /// ============================================
  /// USER INFO MANAGEMENT
  /// ============================================

  /// Save user information securely
  static Future<void> saveUserInfo(Map<String, dynamic> userInfo) async {
    try {
      final jsonString = jsonEncode(userInfo);
      await _secureStorage.write(key: _keyUserInfo, value: jsonString);
      
      // Save login status
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyLoginStatus, true);
      
      debugPrint('✅ User info saved securely');
    } catch (e) {
      debugPrint('❌ Error saving user info: $e');
      rethrow;
    }
  }

  /// Get user information
  static Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      final jsonString = await _secureStorage.read(key: _keyUserInfo);
      if (jsonString == null) return null;

      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('❌ Error getting user info: $e');
      return null;
    }
  }

  /// Delete user information
  static Future<void> deleteUserInfo() async {
    try {
      await _secureStorage.delete(key: _keyUserInfo);
      
      // Clear login status
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyLoginStatus);
      
      debugPrint('✅ User info deleted');
    } catch (e) {
      debugPrint('❌ Error deleting user info: $e');
      rethrow;
    }
  }

  /// ============================================
  /// LOGIN STATUS
  /// ============================================

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_keyLoginStatus) ?? false;
      
      if (isLoggedIn) {
        // Double check if token exists and is valid
        final token = await getToken();
        return token != null && await isTokenValid();
      }
      
      return false;
    } catch (e) {
      debugPrint('❌ Error checking login status: $e');
      return false;
    }
  }

  /// ============================================
  /// CLEAR ALL DATA
  /// ============================================

  /// Clear all stored data (logout)
  static Future<void> clearAll() async {
    try {
      // Clear secure storage
      await _secureStorage.deleteAll();
      
      // Clear shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      debugPrint('✅ All data cleared');
    } catch (e) {
      debugPrint('❌ Error clearing data: $e');
      rethrow;
    }
  }

  /// ============================================
  /// MIGRATION FROM OLD TOKEN SERVICE
  /// ============================================

  /// Migrate data from old TokenService to SecureStorageService
  static Future<void> migrateFromOldService() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Migrate token
      final oldToken = prefs.getString('token');
      if (oldToken != null) {
        await saveToken(oldToken);
        await prefs.remove('token');
        debugPrint('✅ Token migrated to secure storage');
      }
      
      // Migrate user info
      final oldUserInfoJson = prefs.getString('user_info');
      if (oldUserInfoJson != null) {
        final userInfo = jsonDecode(oldUserInfoJson) as Map<String, dynamic>;
        await saveUserInfo(userInfo);
        await prefs.remove('user_info');
        debugPrint('✅ User info migrated to secure storage');
      }
      
      debugPrint('✅ Migration from old service completed');
    } catch (e) {
      debugPrint('❌ Error during migration: $e');
    }
  }

  /// ============================================
  /// UTILITY METHODS
  /// ============================================

  /// Check if secure storage is available
  static Future<bool> isSecureStorageAvailable() async {
    try {
      await _secureStorage.write(key: 'test', value: 'test');
      await _secureStorage.delete(key: 'test');
      return true;
    } catch (e) {
      debugPrint('❌ Secure storage not available: $e');
      return false;
    }
  }

  /// Get all keys (for debugging - only in development)
  static Future<List<String>> getAllKeys() async {
    try {
      final all = await _secureStorage.readAll();
      return all.keys.toList();
    } catch (e) {
      debugPrint('❌ Error getting all keys: $e');
      return [];
    }
  }

  /// Print all stored data (for debugging - only in development)
  static Future<void> debugPrintAll() async {
    if (kDebugMode) {
      try {
        debugPrint('🔍 ===== SECURE STORAGE DEBUG =====');
        final keys = await getAllKeys();
        debugPrint('Keys: $keys');
        debugPrint('Is Logged In: ${await isLoggedIn()}');
        debugPrint('Token Valid: ${await isTokenValid()}');
        debugPrint('====================================');
      } catch (e) {
        debugPrint('❌ Error in debug print: $e');
      }
    }
  }
}
