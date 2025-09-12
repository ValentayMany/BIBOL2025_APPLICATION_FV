import 'package:flutter/foundation.dart';

class ApiConfig {
  // สำหรับ Web/Desktop
  static const String _webHost = "http://localhost:8000/api/students";

  // สำหรับ Android Emulator
  static const String _androidEmulatorHost =
      "http://localhost:8000/api/students";

  // สำหรับ iOS Simulator
  static const String _iosSimulatorHost = "http:/localhost:8000/api/students";

  // สำหรับอุปกรณ์จริง - ใส่ IP Address ของคอมพิวเตอร์ที่รัน server
  static const String _deviceHost =
      "http://10.193.21.85:8000/api/students"; // เปลี่ยน XXX เป็น IP จริง

  static String get baseUrl {
    if (kIsWeb) {
      return _webHost;
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      // สำหรับ Android
      return kDebugMode ? _androidEmulatorHost : _deviceHost;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      // สำหรับ iOS
      return kDebugMode ? _iosSimulatorHost : _deviceHost;
    }
    return _webHost; // fallback
  }

  // ฟังก์ชันช่วยหา IP Address ของเครื่อง
  static void printNetworkGuide() {
    print("📡 Network Configuration Guide:");
    print("1. หา IP Address ของคอมพิวเตอร์:");
    print("   Windows: ipconfig");
    print("   Mac/Linux: ifconfig หรือ ip addr");
    print("2. เปลี่ยน _deviceHost ให้ตรงกับ IP ที่หาได้");
    print("3. ตรวจสอบว่า Firewall ไม่ได้บล็อก port 8000");
    print("📱 Current config: $baseUrl");
  }
}
