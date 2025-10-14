import 'dart:convert';
import 'package:BIBOL/config/bibol_api.dart';
import 'package:BIBOL/models/students/student_model.dart';
import 'package:BIBOL/services/token/token_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class StudentAuthService {
  // 🔥 Base headers สำหรับทุก request - เพิ่ม ngrok header
  static Map<String, String> get _baseHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    // 🎯 สำคัญมาก! ข้าม ngrok warning page
    'ngrok-skip-browser-warning': 'true',
  };

  // Login with admission_no and email only
  Future<StudentLoginResponse?> login({
    required String admissionNo,
    required String email,
  }) async {
    try {
      debugPrint('🔐 Attempting login...');
      debugPrint('📧 Email: $email');
      debugPrint('🎫 Admission No: $admissionNo');

      final response = await http
          .post(
            Uri.parse(StudentsApiConfig.getStudentLoginUrl()),
            headers: _baseHeaders, // ใช้ headers ที่มี ngrok bypass
            body: jsonEncode({'admission_no': admissionNo, 'email': email}),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Connection timeout - กรุณาลองใหม่อีกครั้ง');
            },
          );

      debugPrint('📊 Response status: ${response.statusCode}');
      debugPrint('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        // ลบ quotes ซ้อนก่อน parse (ถ้ามี)
        String cleanBody = response.body.trim();
        if (cleanBody.startsWith('"') && cleanBody.endsWith('"')) {
          cleanBody = cleanBody.substring(1, cleanBody.length - 1);
          cleanBody = cleanBody.replaceAll(r'\"', '"'); // unescape quotes
          debugPrint('🧹 Cleaned body: $cleanBody');
        }

        final jsonData = jsonDecode(cleanBody);
        final loginResponse = StudentLoginResponse.fromJson(jsonData);

        if (loginResponse.success && loginResponse.data != null) {
          debugPrint('✅ Login successful!');
          debugPrint('👤 Student: ${loginResponse.data!.fullName}');
        } else {
          debugPrint('❌ Login failed: ${loginResponse.message}');
        }

        return loginResponse;
      } else {
        debugPrint('❌ Server error: ${response.statusCode}');
        return StudentLoginResponse(
          success: false,
          message: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('💥 Error during login: $e');
      debugPrint('Stack trace: $stackTrace');
      return StudentLoginResponse(success: false, message: 'Error: $e');
    }
  }

  // Get student by ID (optional)
  Future<Student?> getStudentById(int id) async {
    try {
      final response = await http
          .get(
            Uri.parse(StudentsApiConfig.getStudentByIdUrl(id)),
            headers: _baseHeaders, // เพิ่ม ngrok header
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('📊 Get student response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return Student.fromJson(jsonData['data']);
        }
        return null;
      } else {
        debugPrint('❌ Failed to fetch student: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('💥 Error fetching student: $e');
      return null;
    }
  }

  // Get full profile (รับข้อมูลเต็มจาก /profile endpoint)
  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final token = await TokenService.getToken();

      if (token == null || token.isEmpty) {
        debugPrint('❌ No token found');
        return null;
      }

      final response = await http
          .get(
            Uri.parse(StudentsApiConfig.getStudentProfileUrl()),
            headers: {
              ..._baseHeaders, // รวม base headers
              'Authorization': 'Bearer $token', // เพิ่ม token
            },
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('📊 Get profile response: ${response.statusCode}');
      debugPrint('📄 Profile body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          debugPrint('✅ Profile fetched successfully');
          return jsonData['data'] as Map<String, dynamic>;
        }
        return null;
      } else if (response.statusCode == 401) {
        debugPrint('❌ Token expired or invalid');
        return null;
      } else {
        debugPrint('❌ Failed to fetch profile: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('💥 Error fetching profile: $e');
      return null;
    }
  }

  // Update student email (and other profile fields)
  Future<Map<String, dynamic>> updateStudentEmail({
    required String email,
  }) async {
    try {
      debugPrint('📝 Attempting to update email...');
      debugPrint('📧 New Email: $email');

      // Get token for authentication (required by backend)
      final token = await TokenService.getToken();

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'ไม่พบ Token กรุณาเข้าสู่ระบบใหม่',
        };
      }

      final response = await http
          .put(
            Uri.parse(StudentsApiConfig.updateStudentProfileUrl()),
            headers: {
              ..._baseHeaders, // รวม base headers
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'email': email}),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('📊 Update response status: ${response.statusCode}');
      debugPrint('📄 Update response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData['success'] == true) {
          debugPrint('✅ Email updated successfully!');

          // Update local storage with new email
          await TokenService.updateUserInfo({'email': email});

          return {
            'success': true,
            'message': jsonData['message'] ?? 'อัพเดทอีเมวสำเร็จ',
            'data': jsonData['updated'],
          };
        } else {
          debugPrint('❌ Update failed: ${jsonData['message']}');
          return {
            'success': false,
            'message': jsonData['message'] ?? 'อัพเดทล้มเหลว',
          };
        }
      } else if (response.statusCode == 400) {
        // Bad request - validation error
        final jsonData = jsonDecode(response.body);
        return {
          'success': false,
          'message': jsonData['message'] ?? 'ข้อมูลไม่ถูกต้อง',
        };
      } else if (response.statusCode == 401) {
        // Unauthorized - token expired or invalid
        return {
          'success': false,
          'message': 'Token หมดอายุ กรุณาเข้าสู่ระบบใหม่',
        };
      } else {
        debugPrint('❌ Server error: ${response.statusCode}');
        return {
          'success': false,
          'message': 'เกิดข้อผิดพลาดจากเซิร์ฟเวอร์ (${response.statusCode})',
        };
      }
    } catch (e, stackTrace) {
      debugPrint('💥 Error updating email: $e');
      debugPrint('Stack trace: $stackTrace');
      return {'success': false, 'message': 'เกิดข้อผิดพลาด: $e'};
    }
  }

  // 🔓 Logout
  Future<bool> logout() async {
    try {
      final token = await TokenService.getToken();

      if (token != null && token.isNotEmpty) {
        try {
          await http
              .post(
                Uri.parse(StudentsApiConfig.getStudentLogoutUrl()),
                headers: {..._baseHeaders, 'Authorization': 'Bearer $token'},
              )
              .timeout(const Duration(seconds: 10));
        } catch (e) {
          debugPrint('⚠️ Logout API error (will clear local data anyway): $e');
        }
      }

      // ลบข้อมูลทั้งหมดไม่ว่า API จะสำเร็จหรือไม่
      await TokenService.clearAll();
      debugPrint('✅ Logged out and cleared local data');
      return true;
    } catch (e) {
      debugPrint('❌ Logout error: $e');
      // ลบข้อมูลแม้จะ error
      await TokenService.clearAll();
      return true;
    }
  }

  // ✅ Verify Token
  Future<bool> verifyToken() async {
    try {
      final token = await TokenService.getToken();
      if (token == null || token.isEmpty) return false;

      final response = await http
          .get(
            Uri.parse(StudentsApiConfig.getStudentVerifyUrl()),
            headers: {..._baseHeaders, 'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Verify Token Error: $e');
      return false;
    }
  }

  // 🔄 Refresh Token
  Future<String?> refreshToken() async {
    try {
      final token = await TokenService.getToken();
      if (token == null || token.isEmpty) return null;

      final response = await http
          .post(
            Uri.parse(StudentsApiConfig.refreshTokenUrl()),
            headers: {..._baseHeaders, 'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['token'] != null) {
          final newToken = data['token'] as String;
          await TokenService.saveToken(newToken);
          debugPrint('✅ Token refreshed successfully');
          return newToken;
        }
      }

      return null;
    } catch (e) {
      debugPrint('❌ Refresh Token Error: $e');
      return null;
    }
  }
}
