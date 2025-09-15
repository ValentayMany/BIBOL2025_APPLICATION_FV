import 'package:flutter/foundation.dart';

class ApiConfig {
  // Students API (เดิม)
  static const String webHost = "http://localhost:8000/api/students";
  static const String androidEmulatorHost = "http://10.0.2.2:8000/api/students";
  static const String iosSimulatorHost = "http://localhost:8000/api/students";
  static const String deviceHost = "http://10.193.21.85:8000/api/students";

  static String get studentsBaseUrl {
    if (kIsWeb) {
      return webHost;
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return kDebugMode ? androidEmulatorHost : deviceHost;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return kDebugMode ? iosSimulatorHost : deviceHost;
    }
    return webHost;
  }

  // News API - แก้ไข
  static const String baseNewsApi = 'https://web2025.bibol.edu.la/api/v1';
  static const int defaultTopicId = 7;

  // ✅ แก้ไข: เพิ่ม baseUrl ที่ขาดหายไป
  static String get baseUrl => baseNewsApi;

  // ✅ แก้ไข URL functions
  static String getNewsUrl({int page = 1, int count = 10, String lang = 'ar'}) {
    return '$baseNewsApi/topics/$defaultTopicId/page/$page/count/$count/$lang';
  }

  static String getNewsByIdUrl(String id) {
    return '$baseNewsApi/topics/$id'; // แก้จาก /news/ เป็น /topics/
  }

  static const String newsSearchUrl = '$baseNewsApi/search';
  static const String websiteInfoUrl = '$baseNewsApi/website-info';

  static void printConfig() {
    print("📡 Current Students API: $studentsBaseUrl");
    print("📰 Default News URL: ${getNewsUrl()}");
    print("🔎 Search URL: $newsSearchUrl");
    print("🌐 Website Info URL: $websiteInfoUrl");
    print("🆔 News by ID (ex): ${getNewsByIdUrl('123')}");
  }
}
