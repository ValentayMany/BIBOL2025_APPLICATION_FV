// ignore_for_file: file_names

import 'dart:convert';
import 'package:BIBOL/config/bibol_api.dart';
import 'package:BIBOL/models/course/course_response.dart';
import 'package:http/http.dart' as http;

class CourseService {
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
