import 'dart:convert';
import 'package:flutter/foundation.dart'; // ✅ เพิ่มมา
import 'package:http/http.dart' as http;

class InforService {
  // ✅ สำหรับ Chrome / Desktop
  static const String _localHost = "http://localhost:8000/api/information/news";

  // ✅ สำหรับมือถือจริง (ผ่าน USB + adb reverse)
  static const String _mobileHost =
      "http://localhost:8000/api/information/news";

  // ✅ เลือก host ตาม platform
  static String get baseUrl {
    if (kIsWeb) {
      // ถ้าเป็น Flutter Web → ใช้ localhost ของเครื่อง PC
      return _localHost;
    } else {
      // ถ้าเป็น Android/iOS → ใช้ผ่าน adb reverse
      return _mobileHost;
    }
  }
  //every time you want to run in your mobile phone, you must run these commands in terminal:
  //adb devices
  //adb reverse tcp:8000 tcp:8000

  // ✅ Fetch news by ID
  static Future<Map<String, dynamic>> getNewsById(int id) async {
    final url = Uri.parse("$baseUrl/$id");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load news with ID $id");
    }
  }

  // ✅ Fetch all news
  static Future<List<Map<String, dynamic>>> getAllNews() async {
    final url = Uri.parse(baseUrl);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception("Failed to load news");
    }
  }
}
