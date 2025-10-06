// lib/config/api_config.dart

// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:BIBOL/models/course/course_response.dart';

/// ============================================
/// 🌐 Main API Configuration
/// ============================================
class ApiConfig {
  // Private constructor
  ApiConfig._();

  // Common configurations
  static const String newsWebsite = 'https://web2025.bibol.edu.la';
  static const String baseApiV1 = 'https://web2025.bibol.edu.la/api/v1';

  // Media URLs Configuration
  static const String imageBaseUrl = '$newsWebsite/uploads/images/';
  static const String mediaBaseUrl = '$newsWebsite/media/';

  static var baseUrl;

  // Helper methods for media URLs
  static String getImageUrl(String imagePath) {
    if (imagePath.isEmpty) return '';

    if (imagePath.startsWith('http')) {
      return imagePath;
    }

    if (imagePath.startsWith('/')) {
      return '$newsWebsite$imagePath';
    }

    return '$imageBaseUrl$imagePath';
  }

  static String getMediaUrl(String mediaPath) {
    if (mediaPath.isEmpty) return '';

    if (mediaPath.startsWith('http')) {
      return mediaPath;
    }

    if (mediaPath.startsWith('/')) {
      return '$newsWebsite$mediaPath';
    }

    return '$mediaBaseUrl$mediaPath';
  }

  // Debug helper for base config
  static void printConfig() {
    debugPrint("=== 🌐 Base API Configuration ===");
    debugPrint("News Website: $newsWebsite");
    debugPrint("Base API V1: $baseApiV1");
    debugPrint("Image Base URL: $imageBaseUrl");
    debugPrint("Media Base URL: $mediaBaseUrl");
    debugPrint("=================================");
  }
}

/// ============================================
/// 📰 News API Configuration
/// ============================================
class NewsApiConfig {
  // Private constructor
  NewsApiConfig._();

  // News API Base URL
  static const String baseNewsApi = 'https://web2025.bibol.edu.la/api/v1';
  static const int defaultTopicId = 7;

  // Base URL getter
  static String get baseUrl => baseNewsApi;

  // News URLs
  static String getNewsUrl({
    int page = 1,
    int count = 10,
    String lang = 'ar',
    String? search, // เพิ่ม parameter search
  }) {
    String url =
        '$baseNewsApi/topics/$defaultTopicId/page/$page/count/$count/$lang';

    // เพิ่ม search query ถ้ามี
    if (search != null && search.isNotEmpty) {
      url += '?search=$search';
    }

    return url;
  }

  // Get news by ID
  static String getNewsByIdUrl(String id) {
    return '$baseNewsApi/topics/$defaultTopicId/page/1/count/100/ar';
  }

  // Search & Info URLs
  static const String newsSearchUrl = '$baseNewsApi/search';
  static const String websiteInfoUrl = '$baseNewsApi/website/info';

  // Validation methods
  static bool isValidTopicId(String? id) {
    if (id == null || id.isEmpty) return false;
    return int.tryParse(id) != null;
  }

  static bool isValidPage(int? page) {
    return page != null && page > 0;
  }

  static bool isValidCount(int? count) {
    return count != null && count > 0 && count <= 100;
  }

  // URL builder with validation
  static String buildNewsUrl({
    int? topicId,
    int? page,
    int? count,
    String? lang,
  }) {
    final validTopicId = topicId ?? defaultTopicId;
    final validPage = isValidPage(page) ? page! : 1;
    final validCount = isValidCount(count) ? count! : 10;
    final validLang = lang?.isNotEmpty == true ? lang! : 'ar';

    return '$baseNewsApi/topics/$validTopicId/page/$validPage/count/$validCount/$validLang';
  }

  // Debug method
  static void printConfig() {
    debugPrint("=== 📰 News API Configuration ===");
    debugPrint("Default News URL: ${getNewsUrl()}");
    debugPrint("Search URL: $newsSearchUrl");
    debugPrint("Website Info URL: $websiteInfoUrl");
    debugPrint("News by ID (example): ${getNewsByIdUrl('123')}");
    debugPrint("=================================");
  }
}

/// ============================================
/// 📘 Course API Configuration
/// ============================================
class CourseApiConfig {
  // Private constructor
  CourseApiConfig._();

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
    debugPrint("====================================");
  }
}

/// ============================================
/// 🖼️ Gallery API Configuration
/// ============================================
class GalleryApiConfig {
  // Private constructor
  GalleryApiConfig._();

  static const String baseUrl = 'https://web2025.bibol.edu.la/api/v1';

  // Gallery endpoints
  static String getUserTopics(String userId, int page, int count) {
    return '$baseUrl/user/$userId/topics/page/$page/count/$count';
  }

  static String getTopicById(String userId, int topicId) {
    return '$baseUrl/user/$userId/topic/$topicId';
  }

  // Debug helper
  static void printConfig() {
    debugPrint("=== 🖼️ Gallery API Configuration ===");
    debugPrint("Base URL: $baseUrl");
    debugPrint("User Topics (example): ${getUserTopics('1', 1, 10)}");
    debugPrint("Topic by ID (example): ${getTopicById('1', 123)}");
    debugPrint("=====================================");
  }
}

/// ============================================
/// 🎓 Students API Configuration
/// ============================================
class StudentsApiConfig {
  // Private constructor
  StudentsApiConfig._();

  static const String baseUrl = 'http://localhost:8000/api';

  // Students endpoints
  static String getStudentsUrl() => '$baseUrl/students';
  static String getStudentLoginUrl() => '$baseUrl/students/login';
  static String getStudentByIdUrl(int id) => '$baseUrl/students/$id';
  static String updateStudentUrl(int id) => '$baseUrl/students/$id';

  // Debug helper
  static void printConfig() {
    debugPrint("=== 🎓 Students API Configuration ===");
    debugPrint("Base URL: $baseUrl");
    debugPrint("Students URL: ${getStudentsUrl()}");
    debugPrint("Login URL: ${getStudentLoginUrl()}");
    debugPrint("======================================");
  }
}

/// ============================================
/// 🚀 All Configs Debug Helper
/// ============================================
class AllConfigsDebugHelper {
  // Private constructor
  AllConfigsDebugHelper._();

  static void printAllConfigs() {
    debugPrint("🚀 ===== ALL API CONFIGURATIONS =====");
    ApiConfig.printConfig();
    NewsApiConfig.printConfig();
    CourseApiConfig.printConfig();
    GalleryApiConfig.printConfig();
    StudentsApiConfig.printConfig();
    debugPrint("🚀 ====================================");
  }
}
