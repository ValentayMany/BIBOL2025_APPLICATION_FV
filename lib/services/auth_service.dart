import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = "http://localhost:8000/api/auth";
  // static const String baseUrl = "http://10.193.21.85:8000/api/auth";

  //static const String baseUrl = "http://192.168.4.4:8000/api/auth";
  // หรือถ้าใช้ Wi-Fi ก็
  // static const String baseUrl = "http://10.193.21.85:8000/api/auth";

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

  static Future<Map<String, dynamic>> logout() async {
    final response = await http.post(
      Uri.parse("$baseUrl/logout"),
      headers: {"Content-Type": "application/json"},
    );
    return jsonDecode(response.body);
  }
}
