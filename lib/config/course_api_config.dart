import 'dart:convert' show jsonDecode;
import 'package:BIBOL/models/course_response.dart' show CourseResponse;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http show get;

class CourseApiConfig {
  // Base API configuration
  static const String baseUrl = 'https://web2025.bibol.edu.la/api/v1';
  static const String coursesUrl = '$baseUrl/banners/2';

  static String getCoursesUrl() => coursesUrl;

  // Fetch Courses
  static Future<CourseResponse> fetchCourses() async {
    final response = await http.get(Uri.parse(coursesUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return CourseResponse.fromJson(data);
    } else {
      throw Exception('Failed to load courses');
    }
  }

  // Debug helper
  static void printConfig() {
    debugPrint("=== 📘 Course API Configuration ===");
    debugPrint("Base URL: $baseUrl");
    debugPrint("Courses URL: $coursesUrl");
    debugPrint("===================================");
  }
}
