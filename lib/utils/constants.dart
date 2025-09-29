// lib/utils/constants.dart
import 'dart:ui';

class AppColors {
  static const primaryColor = Color(0xFF07325D);
  static const secondaryColor = Color(0xFF0A4A7F);
  static const backgroundColor = Color(0xFFF8FAFF);
}

class AppSizes {
  static double getBasePadding(double screenWidth) {
    if (screenWidth < 320) return 8.0;
    if (screenWidth < 360) return 12.0;
    if (screenWidth < 400) return 16.0;
    if (screenWidth < 480) return 18.0;
    return 20.0;
  }
}
