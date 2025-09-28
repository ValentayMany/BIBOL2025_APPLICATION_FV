// utils/responsive_helper.dart
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

class ResponsiveHelper {
  final BuildContext context;
  late final MediaQueryData _mediaQuery;
  late final double screenWidth;
  late final double screenHeight;
  late final double devicePixelRatio;
  late final bool isAndroid;
  late final bool isIOS;

  ResponsiveHelper(this.context) {
    _mediaQuery = MediaQuery.of(context);
    screenWidth = _mediaQuery.size.width;
    screenHeight = _mediaQuery.size.height;
    devicePixelRatio = _mediaQuery.devicePixelRatio;
    isAndroid = Platform.isAndroid;
    isIOS = Platform.isIOS;
  }

  // Screen size categories
  bool get isExtraSmallScreen => screenWidth < 320;
  bool get isSmallScreen => screenWidth >= 320 && screenWidth < 375;
  bool get isMediumScreen => screenWidth >= 375 && screenWidth < 414;
  bool get isLargeScreen => screenWidth >= 414 && screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 900;
  bool get isDesktop => screenWidth >= 900;

  // Height categories
  bool get isShortScreen => screenHeight < 667; // iPhone SE
  bool get isMediumHeight => screenHeight >= 667 && screenHeight < 812;
  bool get isTallScreen => screenHeight >= 812; // iPhone X and above

  // Device type detection
  bool get isPhone => screenWidth < 600;
  bool get isLandscape => screenWidth > screenHeight;

  // Safe responsive values
  double get basePadding {
    if (isExtraSmallScreen) return 8.0;
    if (isSmallScreen) return 10.0;
    if (isMediumScreen) return 12.0;
    if (isLargeScreen) return 16.0;
    if (isTablet) return 20.0;
    return 24.0; // Desktop
  }

  double get smallPadding => basePadding * 0.75;

  // Typography scaling
  double get titleFontSize {
    if (isExtraSmallScreen) return 14.0;
    if (isSmallScreen) return 16.0;
    if (isMediumScreen) return 18.0;
    if (isLargeScreen) return 20.0;
    if (isTablet) return 24.0;
    return 28.0; // Desktop
  }

  double get bodyFontSize {
    if (isExtraSmallScreen) return 11.0;
    if (isSmallScreen) return 12.0;
    if (isMediumScreen) return 13.0;
    if (isLargeScreen) return 14.0;
    if (isTablet) return 15.0;
    return 16.0; // Desktop
  }

  double get captionFontSize {
    if (isExtraSmallScreen) return 9.0;
    if (isSmallScreen) return 10.0;
    if (isMediumScreen) return 11.0;
    if (isLargeScreen) return 12.0;
    if (isTablet) return 13.0;
    return 14.0; // Desktop
  }

  // Button sizes
  double get buttonHeight {
    if (isExtraSmallScreen) return 36.0;
    if (isSmallScreen) return 40.0;
    if (isMediumScreen) return 44.0;
    if (isLargeScreen) return 48.0;
    if (isTablet) return 52.0;
    return 56.0; // Desktop
  }

  // Icon sizes
  double get iconSize {
    if (isExtraSmallScreen) return 16.0;
    if (isSmallScreen) return 18.0;
    if (isMediumScreen) return 20.0;
    if (isLargeScreen) return 22.0;
    if (isTablet) return 24.0;
    return 28.0; // Desktop
  }

  // Card dimensions
  double get cardHeight {
    if (isExtraSmallScreen) return 120.0;
    if (isSmallScreen) return 140.0;
    if (isMediumScreen) return 160.0;
    if (isLargeScreen) return 180.0;
    if (isTablet) return 200.0;
    return 220.0; // Desktop
  }

  // Content constraints
  double get maxContentWidth {
    if (isPhone) return screenWidth;
    if (isTablet) return 600.0;
    return 800.0; // Desktop
  }

  // Grid columns
  int get gridColumns {
    if (isExtraSmallScreen) return 1;
    if (isSmallScreen) return 1;
    if (isMediumScreen) return 1;
    if (isLargeScreen) return 2;
    if (isTablet) return 2;
    return 3; // Desktop
  }

  // Animation duration based on device performance
  Duration get animationDuration {
    // Slower devices get shorter animations
    if (devicePixelRatio > 3) return const Duration(milliseconds: 200);
    return const Duration(milliseconds: 300);
  }

  // Platform-specific adjustments
  EdgeInsets get platformPadding {
    final base = EdgeInsets.all(basePadding);
    if (isIOS && isTallScreen) {
      // Add extra bottom padding for iPhone X+ home indicator
      return base.copyWith(bottom: basePadding + 8);
    }
    return base;
  }

  // Get scaled value based on screen size
  double scale(double baseValue) {
    if (isExtraSmallScreen) return baseValue * 0.8;
    if (isSmallScreen) return baseValue * 0.9;
    if (isMediumScreen) return baseValue;
    if (isLargeScreen) return baseValue * 1.1;
    if (isTablet) return baseValue * 1.2;
    return baseValue * 1.4; // Desktop
  }
}

// Extension for easy access
extension ResponsiveContext on BuildContext {
  ResponsiveHelper get responsive => ResponsiveHelper(this);
}
