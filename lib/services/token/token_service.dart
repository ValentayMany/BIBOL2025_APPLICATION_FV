import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:BIBOL/services/storage/secure_storage_service.dart';
import 'package:BIBOL/utils/logger.dart';

/// ⚠️ DEPRECATED: This service is kept for backward compatibility
/// Please use SecureStorageService instead for better security
class TokenService {
  static const String _studentIdKey = 'student_id';

  static bool _hasMigrated = false;

  /// Auto-migrate to SecureStorage on first use
  static Future<void> _ensureMigrated() async {
    if (!_hasMigrated) {
      await SecureStorageService.migrateFromOldService();
      _hasMigrated = true;
    }
  }

  // บันทึก Token และข้อมูล Student
  // ✅ Now using SecureStorageService for better security
  static Future<void> saveToken(String token) async {
    try {
      await _ensureMigrated();
      await SecureStorageService.saveToken(token);
      AppLogger.success('Token saved securely', tag: 'AUTH');
    } catch (e) {
      AppLogger.error('Error saving token', tag: 'AUTH', error: e);
      rethrow;
    }
  }

  // บันทึกข้อมูล Student (รองรับ Student Model)
  // ✅ Now using SecureStorageService for better security
  static Future<void> saveUserInfo(Map<String, dynamic> userInfo) async {
    try {
      await _ensureMigrated();

      // แปลง Student Model เป็นรูปแบบที่ HomePage/ProfilePage ต้องการ
      Map<String, dynamic> normalizedUserInfo = {
        'id': userInfo['id'],
        'student_id':
            userInfo['admission_no'] ??
            userInfo['roll_no'], // ใช้ admission_no เป็น student_id
        // 🔥 รองรับทั้ง firstname/first_name และ lastname/last_name
        'first_name': userInfo['firstname'] ?? userInfo['first_name'] ?? '',
        'last_name': userInfo['lastname'] ?? userInfo['last_name'] ?? '',
        'phone': userInfo['mobileno'] ?? userInfo['phone'] ?? '',
        'email': userInfo['email'] ?? '',
        'class': userInfo['class'] ?? 'N/A',
        'gender': userInfo['gender'] ?? '',
        'image': userInfo['image'],
        // เก็บข้อมูลเพิ่มเติม
        'middlename': userInfo['middlename'] ?? '',
        'admission_no': userInfo['admission_no'] ?? '',
        'roll_no': userInfo['roll_no'] ?? '',
        'admission_date': userInfo['admission_date'],
        'dob': userInfo['dob'],
        'religion': userInfo['religion'],
        'is_active': userInfo['is_active'] ?? 'yes',
      };

      await SecureStorageService.saveUserInfo(normalizedUserInfo);

      AppLogger.success(
        'User info saved: ${normalizedUserInfo['first_name']} ${normalizedUserInfo['last_name']}',
        tag: 'AUTH',
      );
    } catch (e) {
      AppLogger.error('Error saving user info', tag: 'AUTH', error: e);
      rethrow;
    }
  }

  // ดึง Token
  // ✅ Now using SecureStorageService
  static Future<String?> getToken() async {
    try {
      await _ensureMigrated();
      return await SecureStorageService.getToken();
    } catch (e) {
      AppLogger.error('Error getting token', tag: 'AUTH', error: e);
      return null;
    }
  }

  // ดึงข้อมูล User
  // ✅ Now using SecureStorageService
  static Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      await _ensureMigrated();
      return await SecureStorageService.getUserInfo();
    } catch (e) {
      AppLogger.error('Error getting user info', tag: 'AUTH', error: e);
      return null;
    }
  }

  // ดึง Student ID
  static Future<int?> getStudentId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_studentIdKey);
    } catch (e) {
      debugPrint('❌ Error getting student ID: $e');
      return null;
    }
  }

  // เช็คว่า Login แล้วหรือยัง
  static Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      final userInfo = await getUserInfo();

      final isLogged =
          token != null &&
          token.isNotEmpty &&
          userInfo != null &&
          userInfo['id'] != null;

      debugPrint('🔍 Login status: $isLogged');
      return isLogged;
    } catch (e) {
      debugPrint('❌ Error checking login status: $e');
      return false;
    }
  }

  // ล้างข้อมูลทั้งหมด (Logout)
  // ✅ Now using SecureStorageService
  static Future<void> clearAll() async {
    try {
      await SecureStorageService.clearAll();
      _hasMigrated = false; // Reset migration flag
      AppLogger.info('All auth data cleared (Logged out)', tag: 'AUTH');
    } catch (e) {
      AppLogger.error('Error clearing auth data', tag: 'AUTH', error: e);
      rethrow;
    }
  }

  // ล้างเฉพาะ Token
  // ✅ Now using SecureStorageService
  static Future<void> clearToken() async {
    try {
      await SecureStorageService.deleteToken();
      AppLogger.info('Token cleared', tag: 'AUTH');
    } catch (e) {
      AppLogger.error('Error clearing token', tag: 'AUTH', error: e);
      rethrow;
    }
  }

  // ล้างเฉพาะข้อมูล User
  // ✅ Now using SecureStorageService
  static Future<void> clearUserInfo() async {
    try {
      await SecureStorageService.deleteUserInfo();
      AppLogger.info('User info cleared', tag: 'AUTH');
    } catch (e) {
      AppLogger.error('Error clearing user info', tag: 'AUTH', error: e);
      rethrow;
    }
  }

  // อัปเดตข้อมูล User
  static Future<void> updateUserInfo(Map<String, dynamic> updates) async {
    try {
      final currentInfo = await getUserInfo();
      if (currentInfo != null) {
        currentInfo.addAll(updates);
        await saveUserInfo(currentInfo);
        debugPrint('✅ User info updated');
      }
    } catch (e) {
      debugPrint('❌ Error updating user info: $e');
    }
  }
}
