export 'api_config.dart';
export 'students/students_api_config.dart';
export 'banner/banner_api_config.dart';

import 'package:BIBOL/config/banner/banner_api_config.dart';
import 'package:BIBOL/config/course/course_api_config.dart';
import 'package:BIBOL/config/students/students_api_config.dart';
import 'package:flutter/foundation.dart';

var baseUrl;

class AllConfigsDebugHelper {
  static void printAllConfigs() {
    debugPrint("🚀 ===== ALL API CONFIGURATIONS =====");
    StudentsApiConfig.printConfig();
    BannerApiConfig.printConfig();
    CourseApiConfig.printConfig();
    debugPrint("🚀 ====================================");
  }
}
