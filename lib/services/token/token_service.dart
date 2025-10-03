import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class TokenService {
  static const String _tokenKey = 'auth_token';
  static const String _userInfoKey = 'user_info';
  static const String _studentIdKey = 'student_id';

  // บันทึก Token และข้อมูล Student
  static Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      debugPrint('✅ Token saved successfully');
    } catch (e) {
      debugPrint('❌ Error saving token: $e');
    }
  }

  // บันทึกข้อมูล Student (รองรับ Student Model)
  static Future<void> saveUserInfo(Map<String, dynamic> userInfo) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // แปลง Student Model เป็นรูปแบบที่ HomePage/ProfilePage ต้องการ
      Map<String, dynamic> normalizedUserInfo = {
        'id': userInfo['id'],
        'student_id':
            userInfo['admission_no'] ??
            userInfo['roll_no'], // ใช้ admission_no เป็น student_id
        'first_name': userInfo['firstname'] ?? '',
        'last_name': userInfo['lastname'] ?? '',
        'phone': userInfo['mobileno'] ?? '',
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

      await prefs.setString(_userInfoKey, jsonEncode(normalizedUserInfo));

      // บันทึก student ID แยกไว้ด้วย
      if (userInfo['id'] != null) {
        await prefs.setInt(_studentIdKey, userInfo['id']);
      }

      debugPrint('✅ User info saved successfully');
      debugPrint(
        '👤 Student: ${normalizedUserInfo['first_name']} ${normalizedUserInfo['last_name']}',
      );
      debugPrint('🎫 Student ID: ${normalizedUserInfo['student_id']}');
    } catch (e) {
      debugPrint('❌ Error saving user info: $e');
    }
  }

  // ดึง Token
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      debugPrint('❌ Error getting token: $e');
      return null;
    }
  }

  // ดึงข้อมูล User
  static Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userInfoString = prefs.getString(_userInfoKey);

      if (userInfoString != null && userInfoString.isNotEmpty) {
        final userInfo = jsonDecode(userInfoString) as Map<String, dynamic>;
        debugPrint(
          '✅ User info retrieved: ${userInfo['first_name']} ${userInfo['last_name']}',
        );
        return userInfo;
      }

      debugPrint('⚠️ No user info found');
      return null;
    } catch (e) {
      debugPrint('❌ Error getting user info: $e');
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
  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userInfoKey);
      await prefs.remove(_studentIdKey);
      debugPrint('✅ All auth data cleared (Logged out)');
    } catch (e) {
      debugPrint('❌ Error clearing auth data: $e');
    }
  }

  // ล้างเฉพาะ Token
  static Future<void> clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      debugPrint('✅ Token cleared');
    } catch (e) {
      debugPrint('❌ Error clearing token: $e');
    }
  }

  // ล้างเฉพาะข้อมูล User
  static Future<void> clearUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userInfoKey);
      await prefs.remove(_studentIdKey);
      debugPrint('✅ User info cleared');
    } catch (e) {
      debugPrint('❌ Error clearing user info: $e');
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
