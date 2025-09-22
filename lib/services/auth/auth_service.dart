// services/auth_service.dart - Updated
import 'dart:convert';
import 'dart:io';
import 'package:BIBOL/config/all_configs.dart' as StudentsApiConfig;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class AuthService {
  static const Duration _defaultTimeout = Duration(seconds: 30);
  static const int _maxRetries = 3;

  // Register Student with error handling
  static Future<Map<String, dynamic>> registerStudent({
    required String studentId,
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    int retries = 0;

    while (retries < _maxRetries) {
      try {
        final url = "${StudentsApiConfig.baseUrl}/register";
        debugPrint('🔍 Registering student: $url (attempt ${retries + 1})');

        final response = await http
            .post(
              Uri.parse(url),
              headers: _getHeaders(),
              body: jsonEncode({
                "student_id": studentId,
                "first_name": firstName,
                "last_name": lastName,
                "phone": phone,
                "password": password,
                "confirm_password": confirmPassword,
              }),
            )
            .timeout(_defaultTimeout);

        debugPrint('📡 Register API Response Status: ${response.statusCode}');
        _logResponse(response);

        if (response.statusCode == 200 || response.statusCode == 201) {
          return jsonDecode(response.body);
        } else if (response.statusCode >= 500 && retries < _maxRetries - 1) {
          retries++;
          await Future.delayed(Duration(seconds: retries * 2));
          continue;
        } else {
          return {
            'success': false,
            'message': 'Server error: ${response.statusCode}',
            'data': response.body,
          };
        }
      } catch (e) {
        debugPrint('❌ Error registering student (attempt ${retries + 1}): $e');

        if (retries == _maxRetries - 1) {
          return {'success': false, 'message': _getErrorMessage(e)};
        }

        retries++;
        await Future.delayed(Duration(seconds: retries));
      }
    }

    return {
      'success': false,
      'message': 'ไม่สามารถลงทะเบียนได้หลังจากพยายาม $_maxRetries ครั้ง',
    };
  }

  // Login Student with error handling
  static Future<Map<String, dynamic>> loginStudent({
    required String studentId,
    required String password,
  }) async {
    int retries = 0;

    while (retries < _maxRetries) {
      try {
        final url = "${StudentsApiConfig.baseUrl}/login";
        debugPrint('🔍 Login student: $url (attempt ${retries + 1})');

        final response = await http
            .post(
              Uri.parse(url),
              headers: _getHeaders(),
              body: jsonEncode({"student_id": studentId, "password": password}),
            )
            .timeout(_defaultTimeout);

        debugPrint('📡 Login API Response Status: ${response.statusCode}');
        _logResponse(response);

        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        } else if (response.statusCode >= 500 && retries < _maxRetries - 1) {
          retries++;
          await Future.delayed(Duration(seconds: retries * 2));
          continue;
        } else {
          return {
            'success': false,
            'message': 'Login failed: ${response.statusCode}',
            'data': response.body,
          };
        }
      } catch (e) {
        debugPrint('❌ Error logging in (attempt ${retries + 1}): $e');

        if (retries == _maxRetries - 1) {
          return {'success': false, 'message': _getErrorMessage(e)};
        }

        retries++;
        await Future.delayed(Duration(seconds: retries));
      }
    }

    return {
      'success': false,
      'message': 'ไม่สามารถเข้าสู่ระบบได้หลังจากพยายาม $_maxRetries ครั้ง',
    };
  }

  // Logout with error handling
  static Future<Map<String, dynamic>> logout(String token) async {
    try {
      final url = "${StudentsApiConfig.baseUrl}/logout";
      debugPrint('🔍 Logout: $url');

      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
            body: jsonEncode({"token": token}),
          )
          .timeout(_defaultTimeout);

      debugPrint('📡 Logout API Response Status: ${response.statusCode}');
      _logResponse(response);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Logout failed: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('❌ Error logging out: $e');
      return {'success': false, 'message': _getErrorMessage(e)};
    }
  }

  // Helper methods
  static Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'Flutter App/1.0',
    };
  }

  static void _logResponse(http.Response response) {
    if (kDebugMode) {
      if (response.body.length > 500) {
        debugPrint('📄 Response Body: ${response.body.substring(0, 500)}...');
      } else {
        debugPrint('📄 Response Body: ${response.body}');
      }
    }
  }

  static String _getErrorMessage(dynamic error) {
    if (error is SocketException) {
      return 'ไม่สามารถเชื่อมต่อกับอินเทอร์เน็ตได้';
    } else if (error is HttpException) {
      return 'เซิร์ฟเวอร์ไม่สามารถตอบสนองได้';
    } else if (error is FormatException) {
      return 'ข้อมูลที่ได้รับไม่ถูกต้อง';
    } else if (error.toString().contains('TimeoutException')) {
      return 'หมดเวลาในการเชื่อมต่อ';
    }
    return 'เกิดข้อผิดพลาดที่ไม่คาดคิด: ${error.toString()}';
  }

  // Utility methods
  static Future<bool> testConnection() async {
    try {
      final url = StudentsApiConfig.baseUrl;
      debugPrint('🔍 Testing Students API connection: $url');

      final response = await http
          .get(Uri.parse(url), headers: _getHeaders())
          .timeout(const Duration(seconds: 10));

      debugPrint(
        '📡 Students API connection test result: ${response.statusCode}',
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Students API connection error: $e');
      return false;
    }
  }
}
