import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class AuthService {
  // ✅ สำหรับ Chrome/PC ผ่าน ngrok
  static const String _localHost =
      "https://632b91295535.ngrok-free.app/api/auth";

  // ✅ สำหรับมือถือ Android ผ่าน USB + adb reverse
  static const String _mobileHost =
      "http://localhost:8000/api/auth"; // <-- เปลี่ยนตรงนี้

  // ✅ เลือก host ตาม platform
  static String get baseUrl {
    if (Platform.isAndroid || Platform.isIOS) {
      return _mobileHost;
    } else {
      return _localHost;
    }
  }

  // ✅ Register
  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "email": email, "password": password}),
    );

    return jsonDecode(response.body);
  }

  // ✅ Login
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    return jsonDecode(response.body);
  }

  // ✅ Logout
  static Future<Map<String, dynamic>> logout() async {
    final response = await http.post(
      Uri.parse("$baseUrl/logout"),
      headers: {"Content-Type": "application/json"},
    );

    return jsonDecode(response.body);
  }
}
