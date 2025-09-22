// เพิ่มเมธอดเหล่านี้ใน TokenService class
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TokenService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_info';

  // บันทึก token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // ดึง token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // 🔹 ลบ token
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // บันทึกข้อมูล user
  static Future<void> saveUserInfo(Map<String, dynamic> userInfo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(userInfo));
  }

  // ดึงข้อมูล user
  static Future<Map<String, dynamic>?> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);
    if (userString != null) {
      return json.decode(userString);
    }
    return null;
  }

  // 🔹 ลบข้อมูล user
  static Future<void> clearUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // 🔹 ล้างข้อมูลทั้งหมด (สำหรับล็อกเอาท์)
  static Future<void> clearAll() async {
    await clearToken();
    await clearUserInfo();
  }

  // ตรวจสอบว่าล็อกอินอยู่หรือไม่
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    final user = await getUserInfo();
    return token != null && user != null;
  }
}
