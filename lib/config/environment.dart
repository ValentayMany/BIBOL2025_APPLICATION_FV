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

  /// Get base API URL based on current environment
  static String get apiBaseUrl {
    switch (current) {
      case Environment.development:
        return 'https://scalpless-sarai-fractural.ngrok-free.dev/api';
      case Environment.staging:
        return 'https://staging-api.bibol.edu.la/api';
      case Environment.production:
        return 'https://api.bibol.edu.la/api';
    }
  }

  /// Get web base URL
  static String get webBaseUrl {
    switch (current) {
      case Environment.development:
        return 'https://scalpless-sarai-fractural.ngrok-free.dev';
      case Environment.staging:
        return 'https://staging.bibol.edu.la';
      case Environment.production:
        return 'https://web2025.bibol.edu.la';
    }
  }

  /// Check if running in production
  static bool get isProduction => current == Environment.production;

  /// Check if running in development
  static bool get isDevelopment => current == Environment.development;

  /// Check if running in staging
  static bool get isStaging => current == Environment.staging;

  /// Enable debug logging in non-production environments
  static bool get enableLogging => !isProduction;

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

  /// Print current configuration (for debugging)
  static void printConfig() {
    if (enableLogging) {
      print('🌍 ===== ENVIRONMENT CONFIGURATION =====');
      print('Environment: ${current.name}');
      print('API Base URL: $apiBaseUrl');
      print('Web Base URL: $webBaseUrl');
      print('API Timeout: ${apiTimeout.inSeconds}s');
      print('Max Retries: $maxRetries');
      print('Logging Enabled: $enableLogging');
      print('========================================');
    }
  }
}
