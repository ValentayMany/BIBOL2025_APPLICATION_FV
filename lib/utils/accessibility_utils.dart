// lib/utils/accessibility_utils.dart

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// ♿ Accessibility Utilities
/// Helper methods for improving app accessibility
class AccessibilityUtils {
  // Private constructor
  AccessibilityUtils._();

  /// ============================================
  /// SEMANTIC LABELS
  /// ============================================

  /// Create semantic label for button
  static String buttonLabel(String text, {bool isEnabled = true}) {
    if (!isEnabled) {
      return '$text, ປຸ່ມບໍ່ສາມາດໃຊ້ງານໄດ້';
    }
    return '$text, ປຸ່ມ';
  }

  /// Create semantic label for icon button
  static String iconButtonLabel(String action) {
    return '$action, ປຸ່ມ';
  }

  /// Create semantic label for text field
  static String textFieldLabel(String label, {bool isRequired = false}) {
    if (isRequired) {
      return '$label, ຊ່ອງປ້ອນຂໍ້ມູນ, ຕ້ອງການ';
    }
    return '$label, ຊ່ອງປ້ອນຂໍ້ມູນ';
  }

  /// Create semantic label for checkbox
  static String checkboxLabel(String label, bool isChecked) {
    if (isChecked) {
      return '$label, ເລືອກແລ້ວ';
    }
    return '$label, ຍັງບໍ່ໄດ້ເລືອກ';
  }

  /// Create semantic label for switch
  static String switchLabel(String label, bool isOn) {
    if (isOn) {
      return '$label, ເປີດ';
    }
    return '$label, ປິດ';
  }

  /// Create semantic label for image
  static String imageLabel(String description) {
    return '$description, ຮູບພາບ';
  }

  /// Create semantic label for loading indicator
  static String get loadingLabel => 'ກຳລັງໂຫຼດ';

  /// ============================================
  /// SEMANTIC WIDGETS
  /// ============================================

  /// Wrap widget with semantics for buttons
  static Widget semanticButton({
    required Widget child,
    required String label,
    required VoidCallback? onTap,
    String? hint,
  }) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: label,
      hint: hint,
      child: child,
    );
  }

  /// Wrap widget with semantics for text fields
  static Widget semanticTextField({
    required Widget child,
    required String label,
    String? hint,
    bool isObscured = false,
  }) {
    return Semantics(
      textField: true,
      label: label,
      hint: hint,
      obscured: isObscured,
      child: child,
    );
  }

  /// Wrap widget with semantics for images
  static Widget semanticImage({
    required Widget child,
    required String label,
    String? hint,
  }) {
    return Semantics(
      image: true,
      label: label,
      hint: hint,
      child: child,
    );
  }

  /// Wrap widget with semantics for headers
  static Widget semanticHeader({
    required Widget child,
    required String label,
  }) {
    return Semantics(
      header: true,
      label: label,
      child: child,
    );
  }

  /// Wrap widget with semantics for links
  static Widget semanticLink({
    required Widget child,
    required String label,
    required VoidCallback onTap,
    String? hint,
  }) {
    return Semantics(
      link: true,
      label: label,
      hint: hint,
      onTap: onTap,
      child: child,
    );
  }

  /// ============================================
  /// FOCUS MANAGEMENT
  /// ============================================

  /// Request focus on a field
  static void requestFocus(BuildContext context, FocusNode focusNode) {
    FocusScope.of(context).requestFocus(focusNode);
  }

  /// Clear focus (dismiss keyboard)
  static void clearFocus(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// Move to next field
  static void nextFocus(BuildContext context) {
    FocusScope.of(context).nextFocus();
  }

  /// Move to previous field
  static void previousFocus(BuildContext context) {
    FocusScope.of(context).previousFocus();
  }

  /// ============================================
  /// ANNOUNCEMENTS
  /// ============================================

  /// Announce message to screen reader
  static void announce(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// Announce tooltip
  static void announceTooltip(BuildContext context, String message) {
    SemanticsService.tooltip(message);
  }

  /// ============================================
  /// TEXT SCALING
  /// ============================================

  /// Get scaled font size based on accessibility settings
  static double getScaledFontSize(
    BuildContext context,
    double baseFontSize,
  ) {
    final mediaQuery = MediaQuery.of(context);
    return baseFontSize * mediaQuery.textScaleFactor;
  }

  /// Clamp text scale factor to reasonable range
  static double clampTextScaleFactor(double textScaleFactor) {
    return textScaleFactor.clamp(0.8, 2.0);
  }

  /// Check if large text is enabled
  static bool isLargeTextEnabled(BuildContext context) {
    return MediaQuery.of(context).textScaleFactor > 1.3;
  }

  /// ============================================
  /// CONTRAST & COLORS
  /// ============================================

  /// Check if high contrast is needed
  static bool needsHighContrast(BuildContext context) {
    return MediaQuery.of(context).highContrast;
  }

  /// Get color with better contrast if needed
  static Color getAccessibleColor(
    BuildContext context,
    Color normalColor,
    Color highContrastColor,
  ) {
    if (needsHighContrast(context)) {
      return highContrastColor;
    }
    return normalColor;
  }

  /// Calculate contrast ratio between two colors
  static double calculateContrastRatio(Color color1, Color2) {
    final luminance1 = color1.computeLuminance();
    final luminance2 = color2.computeLuminance();
    
    final lighter = luminance1 > luminance2 ? luminance1 : luminance2;
    final darker = luminance1 > luminance2 ? luminance2 : luminance1;
    
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Check if color combination meets WCAG AA standards (4.5:1)
  static bool meetsWCAGAA(Color foreground, Color background) {
    return calculateContrastRatio(foreground, background) >= 4.5;
  }

  /// Check if color combination meets WCAG AAA standards (7:1)
  static bool meetsWCAGAAA(Color foreground, Color background) {
    return calculateContrastRatio(foreground, background) >= 7.0;
  }

  /// ============================================
  /// GESTURES
  /// ============================================

  /// Get minimum tap target size (48x48 as per Material Design)
  static const double minTapTargetSize = 48.0;

  /// Check if widget meets minimum tap target size
  static bool meetsTapTargetSize(Size size) {
    return size.width >= minTapTargetSize && size.height >= minTapTargetSize;
  }

  /// Wrap widget to ensure minimum tap target size
  static Widget ensureTapTargetSize({
    required Widget child,
    double minWidth = minTapTargetSize,
    double minHeight = minTapTargetSize,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minWidth,
        minHeight: minHeight,
      ),
      child: child,
    );
  }

  /// ============================================
  /// UTILITIES
  /// ============================================

  /// Check if screen reader is enabled
  static bool isScreenReaderEnabled(BuildContext context) {
    return MediaQuery.of(context).accessibleNavigation;
  }

  /// Check if bold text is enabled
  static bool isBoldTextEnabled(BuildContext context) {
    return MediaQuery.of(context).boldText;
  }

  /// Check if reduce motion is enabled
  static bool isReduceMotionEnabled(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }

  /// Get safe duration for animations (respects reduce motion)
  static Duration getSafeDuration(
    BuildContext context,
    Duration normalDuration,
  ) {
    if (isReduceMotionEnabled(context)) {
      return Duration.zero;
    }
    return normalDuration;
  }
}
