// lib/config/environment.dart

/// Environment configuration for different build environments
enum Environment { development, staging, production }

/// Configuration class for managing environment-specific settings
class EnvironmentConfig {
  // Private constructor
  EnvironmentConfig._();

  /// Current environment - change this based on your build
  /// For development, set to Environment.development
  /// For production builds, set to Environment.production
  static Environment current = Environment.development;

  /// Get base API URL based on current environment (สำหรับ Students API - Login/Profile)
  static String get apiBaseUrl {
    switch (current) {
      case Environment.development:
        return 'https://scalpless-sarai-fractural.ngrok-free.dev/api'; // Students API (ngrok)
      case Environment.staging:
        return 'https://staging-api.bibol.edu.la/api';
      case Environment.production:
        return 'https://api.bibol.edu.la/api';
    }
  }

  /// Get web base URL (สำหรับ News, Course, Gallery)
  static String get webBaseUrl {
    switch (current) {
      case Environment.development:
        return 'https://bibol.edu.la'; // ใช้ production URL สำหรับ Content
      case Environment.staging:
        return 'https://staging.bibol.edu.la';
      case Environment.production:
        return 'https://bibol.edu.la';
    }
  }

  /// ============================================
  /// 🌐 Centralized API URLs (ใช้ร่วมกัน)
  /// ============================================

  /// Base API V1 URL - ใช้ร่วมกันสำหรับ News, Course, Gallery
  static String get baseApiV1 => '$webBaseUrl/api/v1';

  /// Image Base URL
  static String get imageBaseUrl => '$webBaseUrl/uploads/images/';

  /// Media Base URL
  static String get mediaBaseUrl => '$webBaseUrl/media/';

  /// Default Topic ID สำหรับ News
  static const int defaultNewsTopicId = 7;

  /// Banner ID สำหรับ Course
  static const int defaultCourseBannerId = 2;

  /// ============================================
  /// 🔧 Environment Checks
  /// ============================================

  /// Check if running in production
  static bool get isProduction => current == Environment.production;

  /// Check if running in development
  static bool get isDevelopment => current == Environment.development;

  /// Check if running in staging
  static bool get isStaging => current == Environment.staging;

  /// Enable debug logging in non-production environments
  static bool get enableLogging => !isProduction;

  /// ============================================
  /// ⚙️ API Configuration Settings
  /// ============================================

  /// API timeout duration
  static Duration get apiTimeout {
    switch (current) {
      case Environment.development:
        return const Duration(seconds: 60); // Longer timeout for dev
      case Environment.staging:
        return const Duration(seconds: 45);
      case Environment.production:
        return const Duration(seconds: 30);
    }
  }

  /// Max retry attempts for API calls
  static int get maxRetries {
    return isProduction ? 3 : 2;
  }

  /// ============================================
  /// 🐛 Debug Helper
  /// ============================================

  /// Print current configuration (for debugging)
  static void printConfig() {
    if (enableLogging) {
      print('🌍 ===== ENVIRONMENT CONFIGURATION =====');
      print('Environment: ${current.name}');
      print('------- API URLs -------');
      print('Students API URL: $apiBaseUrl');
      print('Web Base URL: $webBaseUrl');
      print('API V1 Base URL: $baseApiV1');
      print('Image Base URL: $imageBaseUrl');
      print('Media Base URL: $mediaBaseUrl');
      print('------- Constants -------');
      print('Default News Topic ID: $defaultNewsTopicId');
      print('Default Course Banner ID: $defaultCourseBannerId');
      print('------- Settings -------');
      print('API Timeout: ${apiTimeout.inSeconds}s');
      print('Max Retries: $maxRetries');
      print('Logging Enabled: $enableLogging');
      print('========================================');
    }
  }
}
/// ============================================