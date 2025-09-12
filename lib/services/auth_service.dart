import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class AuthService {
  // ✅ Register Student
  static Future<Map<String, dynamic>> registerStudent({
    required String studentId,
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final url = "${ApiConfig.baseUrl}/register";
      final response = await http
          .post(
            Uri.parse(url),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "student_id": studentId,
              "first_name": firstName,
              "last_name": lastName,
              "phone": phone,
              "password": password,
              "confirm_password": confirmPassword,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
          'data': response.body,
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // ✅ Login Student
  static Future<Map<String, dynamic>> loginStudent({
    required String studentId,
    required String password,
  }) async {
    try {
      final url = "${ApiConfig.baseUrl}/login";
      final response = await http
          .post(
            Uri.parse(url),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"student_id": studentId, "password": password}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Login failed: ${response.statusCode}',
          'data': response.body,
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // ✅ Logout
  static Future<Map<String, dynamic>> logout(String token) async {
    try {
      final url = "${ApiConfig.baseUrl}/logout";
      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
            body: jsonEncode({"token": token}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Logout failed: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
}
