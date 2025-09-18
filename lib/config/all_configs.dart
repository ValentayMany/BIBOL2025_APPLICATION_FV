export 'api_config.dart';
export 'students_api_config.dart';
export 'banner_api_config.dart';
export 'course_api_config.dart';

import 'package:BIBOL/config/course_api_config.dart';
import 'package:flutter/foundation.dart';
import 'students_api_config.dart';
import 'banner_api_config.dart';
import 'course_api_config.dart';

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
