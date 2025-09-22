import 'package:flutter/foundation.dart';

class NewsApiConfig {
  // News API Base URL
  static const String baseNewsApi = 'https://web2025.bibol.edu.la/api/v1';
  static const int defaultTopicId = 7;

  // Base URL getter
  static String get baseUrl => baseNewsApi;

  // News URLs
  static String getNewsUrl({int page = 1, int count = 10, String lang = 'ar'}) {
    return '$baseNewsApi/topics/$defaultTopicId/page/$page/count/$count/$lang';
  }

  static String getNewsByIdUrl(String id) {
    return '$baseNewsApi/topics/$id';
  }

  // Search & Info URLs
  static const String newsSearchUrl = '$baseNewsApi/search';
  static const String websiteInfoUrl = '$baseNewsApi/website/info';

  // Debug method
  static void printConfig() {
    if (kDebugMode) {
      print("📰 Default News URL: ${getNewsUrl()}");
      print("🔎 Search URL: $newsSearchUrl");
      print("🌐 Website Info URL: $websiteInfoUrl");
      print("🆔 News by ID (example): ${getNewsByIdUrl('123')}");
    }
  }

  // Validation methods
  static bool isValidTopicId(String? id) {
    if (id == null || id.isEmpty) return false;
    return int.tryParse(id) != null;
  }

  static bool isValidPage(int? page) {
    return page != null && page > 0;
  }

  static bool isValidCount(int? count) {
    return count != null && count > 0 && count <= 100; // จำกัดไม่เกิน 100
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
}
