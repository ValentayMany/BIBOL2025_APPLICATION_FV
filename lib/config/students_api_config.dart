import 'package:flutter/foundation.dart';

class StudentsApiConfig {
  static const String _webHost = "http://localhost:8000/api/students";
  static const String _androidEmulatorHost =
      "http://10.0.2.2:8000/api/students";
  static const String _iosSimulatorHost = "http://localhost:8000/api/students";
  static const String _deviceHost = "http://10.193.21.85:8000/api/students";

  static String get baseUrl {
    if (kIsWeb) {
      return _webHost;
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return kDebugMode ? _androidEmulatorHost : _deviceHost;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return kDebugMode ? _iosSimulatorHost : _deviceHost;
    }
    return _webHost;
  }

  // Debug helper
  static void printConfig() {
    debugPrint("=== 🎓 Students API Configuration ===");
    debugPrint("Current URL: $baseUrl");
    debugPrint("Web: $_webHost");
    debugPrint("Android Emulator: $_androidEmulatorHost");
    debugPrint("iOS Simulator: $_iosSimulatorHost");
    debugPrint("Device: $_deviceHost");
    debugPrint("=====================================");
  }
}
