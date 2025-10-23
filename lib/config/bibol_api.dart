// lib/config/api_config.dart

// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:BIBOL/config/environment.dart';
import 'package:BIBOL/models/course/course_response.dart';

/// ============================================
/// 🌐 Main API Configuration
/// ============================================
class ApiConfig {
  // Private constructor
  ApiConfig._();

  // ✅ ใช้ค่าจาก EnvironmentConfig (ไม่ต้อง hardcode)
  static String get newsWebsite => EnvironmentConfig.webBaseUrl;
  static String get baseApiV1 => EnvironmentConfig.baseApiV1;
  static String get imageBaseUrl => EnvironmentConfig.imageBaseUrl;
  static String get mediaBaseUrl => EnvironmentConfig.mediaBaseUrl;

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

  // ✅ ใช้ค่าจาก EnvironmentConfig (bibol.edu.la/api/v1)
  static String get baseNewsApi => EnvironmentConfig.baseApiV1;
  static int get defaultTopicId => EnvironmentConfig.defaultNewsTopicId;

  // Base URL getter
  static String get baseUrl => baseNewsApi;

  // News URLs
  static String getNewsUrl({
    int page = 1,
    int count = 10,
    String lang = 'ar',
    String? search,
  }) {
    String url =
        '$baseNewsApi/topics/$defaultTopicId/page/$page/count/$count/$lang';

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
  static String get newsSearchUrl => '$baseNewsApi/search';
  static String get websiteInfoUrl => '$baseNewsApi/website/info';

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
    debugPrint("Base News API: $baseNewsApi");
    debugPrint("Default Topic ID: $defaultTopicId");
    debugPrint("Default News URL: ${getNewsUrl()}");
    debugPrint("Search URL: $newsSearchUrl");
    debugPrint("Website Info URL: $websiteInfoUrl");
    debugPrint("=================================");
  }
}

/// ============================================
/// 📘 Course API Configuration
/// ============================================
class CourseApiConfig {
  // Private constructor
  CourseApiConfig._();

  // ✅ ใช้ค่าจาก EnvironmentConfig (bibol.edu.la/api/v1)
  static String get baseUrl => EnvironmentConfig.baseApiV1;
  static int get bannerId => EnvironmentConfig.defaultCourseBannerId;
  static String get coursesUrl => '$baseUrl/banners/$bannerId';

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
    debugPrint("Banner ID: $bannerId");
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

  // ✅ ใช้ค่าจาก EnvironmentConfig (bibol.edu.la/api/v1)
  static String get baseUrl => EnvironmentConfig.baseApiV1;

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
  StudentsApiConfig._();

  // ✅ ใช้ค่าจาก EnvironmentConfig (ngrok ใน Dev)
  static String get baseUrl => EnvironmentConfig.apiBaseUrl;

  static String getStudentsUrl() => '$baseUrl/students/all';
  static String getStudentLoginUrl() => '$baseUrl/students/login';
  static String getStudentByIdUrl(int id) => '$baseUrl/students/$id';
  static String getStudentProfileUrl() => '$baseUrl/students/profile';
  static String updateStudentProfileUrl() => '$baseUrl/students/profile';
  static String getStudentLogoutUrl() => '$baseUrl/students/logout';
  static String getStudentVerifyUrl() => '$baseUrl/students/verify';
  static String refreshTokenUrl() => '$baseUrl/students/refresh-token';

  static void printConfig() {
    debugPrint("=== 🎓 Students API Configuration ===");
    debugPrint("Base URL: $baseUrl");
    debugPrint("Login URL: ${getStudentLoginUrl()}");
    debugPrint("Profile URL: ${getStudentProfileUrl()}");
    debugPrint("Refresh Token URL: ${refreshTokenUrl()}");
    debugPrint("======================================");
  }
}

/// ============================================
/// 🌐 Website API Configuration
/// ============================================
class WebsiteApiConfig {
  // Private constructor
  WebsiteApiConfig._();

  // ✅ ใช้ค่าจาก EnvironmentConfig ผ่าน ApiConfig
  static String get baseUrl => ApiConfig.baseApiV1;

  // Website endpoints
  static String get contactsUrl => '$baseUrl/website/contacts';

  // Debug helper
  static void printConfig() {
    debugPrint("=== 🌐 Website API Configuration ===");
    debugPrint("Base URL: $baseUrl");
    debugPrint("Contacts URL: $contactsUrl");
    debugPrint("====================================");
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
    EnvironmentConfig.printConfig();
    debugPrint("");
    ApiConfig.printConfig();
    NewsApiConfig.printConfig();
    CourseApiConfig.printConfig();
    GalleryApiConfig.printConfig();
    StudentsApiConfig.printConfig();
    WebsiteApiConfig.printConfig();
    debugPrint("🚀 ====================================");
  }
}
