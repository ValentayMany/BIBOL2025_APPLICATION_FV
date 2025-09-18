import 'package:flutter/foundation.dart';

abstract class ApiConfig {
  // Common configurations
  static const String newsWebsite = 'https://web2025.bibol.edu.la';
  static const String baseApiV1 = 'https://web2025.bibol.edu.la/api/v1';

  // Media URLs Configuration
  static const String imageBaseUrl = '$newsWebsite/uploads/images/';
  static const String mediaBaseUrl = '$newsWebsite/media/';

  static var baseUrl;

  static var connectionTimeout;

  static var defaultHeaders;

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
