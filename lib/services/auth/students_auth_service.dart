import 'dart:convert';
import 'package:BIBOL/config/bibol_api.dart';
import 'package:BIBOL/models/students/student_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class StudentAuthService {
  // Login with admission_no and email only
  Future<StudentLoginResponse?> login({
    required String admissionNo,
    required String email,
  }) async {
    try {
      debugPrint('🔐 Attempting login...');
      debugPrint('📧 Email: $email');
      debugPrint('🎫 Admission No: $admissionNo');

      final response = await http.post(
        Uri.parse(StudentsApiConfig.getStudentLoginUrl()),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'admission_no': admissionNo, 'email': email}),
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
      final response = await http.get(
        Uri.parse(StudentsApiConfig.getStudentByIdUrl(id)),
        headers: {'Content-Type': 'application/json'},
      );

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
}
