// config/banner_api_config.dart
import 'package:flutter/foundation.dart';

class BannerApiConfig {
  // Base API configuration ที่ใช้ได้จริง
  static const String baseUrl = 'https://web2025.bibol.edu.la/api/v1';
  static const String baseWebsite = 'https://web2025.bibol.edu.la';

  // Banner specific endpoints
  static const String bannersUrl = '$baseUrl/banners';

  // Media URLs Configuration
  static const String imageBaseUrl = '$baseWebsite/uploads/banners/';
  static const String mediaBaseUrl = '$baseWebsite/media/';

  // Helper methods for banner URLs
  static String getBannerByIdUrl(int id) {
    return '$bannersUrl/$id';
  }

  static String getBannersUrl({int? limit}) {
    // ใช้ endpoint แบบคงที่ตามที่ API รองรับ
    return '$bannersUrl/1';
  }

  // Helper methods for media URLs
  static String getImageUrl(String imagePath) {
    if (imagePath.isEmpty) return '';

    if (imagePath.startsWith('http')) {
      return imagePath;
    }

    if (imagePath.startsWith('/')) {
      return '$baseWebsite$imagePath';
    }

    return '$imageBaseUrl$imagePath';
  }

  static String getMediaUrl(String mediaPath) {
    if (mediaPath.isEmpty) return '';

    if (mediaPath.startsWith('http')) {
      return mediaPath;
    }

    if (mediaPath.startsWith('/')) {
      return '$baseWebsite$mediaPath';
    }

    return '$mediaBaseUrl$mediaPath';
  }

  // Debug helper
  static void printConfig() {
    debugPrint("=== 🎯 Banner API Configuration ===");
    debugPrint("Base Website: $baseWebsite");
    debugPrint("Base URL: $baseUrl");
    debugPrint("Banners URL: $bannersUrl");
    debugPrint("Working endpoint: $bannersUrl/1");
    debugPrint("Image Base URL: $imageBaseUrl");
    debugPrint("Media Base URL: $mediaBaseUrl");
    debugPrint("===================================");
  }
}
