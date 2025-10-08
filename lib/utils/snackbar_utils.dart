// lib/utils/snackbar_utils.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 🎨 Snackbar Utility
/// Centralized snackbar management with consistent styling
class SnackBarUtils {
  // Private constructor
  SnackBarUtils._();

  /// Default snackbar duration
  static const Duration _defaultDuration = Duration(seconds: 3);

  /// ============================================
  /// MAIN SNACKBAR METHODS
  /// ============================================

  /// Show success snackbar
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    _showSnackBar(
      context,
      message: message,
      icon: Icons.check_circle,
      backgroundColor: Colors.green,
      duration: duration,
    );
  }

  /// Show error snackbar
  static void showError(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    _showSnackBar(
      context,
      message: message,
      icon: Icons.error_outline,
      backgroundColor: Colors.red,
      duration: duration ?? const Duration(seconds: 4),
    );
  }

  /// Show warning snackbar
  static void showWarning(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    _showSnackBar(
      context,
      message: message,
      icon: Icons.warning_amber_rounded,
      backgroundColor: Colors.orange,
      duration: duration,
    );
  }

  /// Show info snackbar
  static void showInfo(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    _showSnackBar(
      context,
      message: message,
      icon: Icons.info_outline,
      backgroundColor: Colors.blue,
      duration: duration,
    );
  }

  /// Show loading snackbar (with progress indicator)
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showLoading(
    BuildContext context,
    String message,
  ) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.notoSansLao(fontSize: 12),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF07325D),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 10), // Long duration for loading
      ),
    );
  }

  /// Show custom snackbar with action button
  static void showWithAction(
    BuildContext context, {
    required String message,
    required String actionLabel,
    required VoidCallback onActionPressed,
    IconData? icon,
    Color? backgroundColor,
    Duration? duration,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.notoSansLao(fontSize: 12),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor ?? const Color(0xFF07325D),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: duration ?? _defaultDuration,
        action: SnackBarAction(
          label: actionLabel,
          textColor: Colors.white,
          onPressed: onActionPressed,
        ),
      ),
    );
  }

  /// ============================================
  /// INTERNAL METHODS
  /// ============================================

  /// Internal method to show snackbar
  static void _showSnackBar(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color backgroundColor,
    Duration? duration,
  }) {
    // Clear any existing snackbars first
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.notoSansLao(fontSize: 12),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: duration ?? _defaultDuration,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// ============================================
  /// UTILITY METHODS
  /// ============================================

  /// Hide current snackbar
  static void hide(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  /// Clear all snackbars
  static void clearAll(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
  }
}
