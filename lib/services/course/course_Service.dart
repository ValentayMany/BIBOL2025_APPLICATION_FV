// ignore_for_file: file_names

import 'dart:convert';
import 'package:BIBOL/config/bibol_api.dart';
import 'package:BIBOL/models/course/course_response.dart';
import 'package:http/http.dart' as http;

/// 📚 CourseService - Service สำหรับจัดการหลักสูตรทั้งหมด
///
/// Service นี้ใช้สำหรับดึงข้อมูลหลักสูตรจาก API
///
/// **ฟีเจอร์หลัก:**
/// - ดึงรายการหลักสูตรทั้งหมด
/// - จัดการข้อผิดพลาดจาก API
///
/// **ตัวอย่างการใช้งาน:**
/// ```dart
/// try {
///   final courses = await CourseService.fetchCourses();
///   print('มีหลักสูตร ${courses.courses.length} หลักสูตร');
/// } catch (e) {
///   print('ดึงหลักสูตรไม่สำเร็จ: $e');
/// }
/// ```
class CourseService {
  /// ดึงรายการหลักสูตรทั้งหมด
  ///
  /// **Returns:**
  /// - [CourseResponse] - ข้อมูลหลักสูตรทั้งหมด
  ///
  /// **Throws:**
  /// - [Exception] - เมื่อไม่สามารถดึงข้อมูลได้ (status code ไม่ใช่ 200)
  static Future<CourseResponse> fetchCourses() async {
    final url = CourseApiConfig.getCoursesUrl();
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return CourseResponse.fromJson(data);
    } else {
      throw Exception(
        'Failed to load courses (status: ${response.statusCode})',
      );
    }
  }
}
