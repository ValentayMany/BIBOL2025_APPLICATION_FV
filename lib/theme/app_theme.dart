// lib/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// 🎨 App Theme Configuration
class AppTheme {
  // Private constructor
  AppTheme._();

  // ============================================
  // THEME COLORS
  // ============================================
  static const Color primaryColor = Color(0xFF07325D);
  static const Color secondaryColor = Color(0xFF0A4A85);
  static const Color accentColor = Color(0xFF10B981);
  static const Color backgroundColor = Colors.white;
  static const Color cardColor = Color(0xFFFAFBFF);
  static const Color textPrimary = Color(0xFF07325D);
  static const Color textSecondary = Color(0xFF6B7280);

  // ============================================
  // LIGHT THEME
  // ============================================
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      primaryColorLight: secondaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      useMaterial3: true,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: cardColor,
        background: backgroundColor,
        error: Color(0xFFEF4444),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onBackground: textPrimary,
        onError: Colors.white,
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: GoogleFonts.notoSansLao(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentColor, width: 2),
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(color: textPrimary),

      // Text Theme
      textTheme: GoogleFonts.notoSansLaoTextTheme(
        const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
          headlineSmall: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          bodyLarge: TextStyle(fontSize: 16, color: textPrimary),
          bodyMedium: TextStyle(fontSize: 14, color: textSecondary),
          labelLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(color: Colors.grey.shade300, thickness: 1),
    );
  }

  // ============================================
  // DARK THEME
  // ============================================
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF0A4A85),
      primaryColorLight: const Color(0xFF1E5A9A),
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardColor: const Color(0xFF2C2C2C),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      useMaterial3: true,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF0A4A85),
        secondary: Color(0xFF1E5A9A),
        surface: Color(0xFF2C2C2C),
        background: Color(0xFF121212),
        error: Color(0xFFEF4444),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFFE5E7EB),
        onBackground: Color(0xFFE5E7EB),
        onError: Colors.white,
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF0A4A85),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: GoogleFonts.notoSansLao(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: const Color(0xFF2C2C2C),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0A4A85),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF10B981),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade600),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade600),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(color: Color(0xFFE5E7EB)),

      // Text Theme
      textTheme: GoogleFonts.notoSansLaoTextTheme(
        const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE5E7EB),
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE5E7EB),
          ),
          headlineSmall: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFFE5E7EB),
          ),
          bodyLarge: TextStyle(fontSize: 16, color: Color(0xFFE5E7EB)),
          bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
          labelLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFFE5E7EB),
          ),
        ),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(color: Colors.grey.shade600, thickness: 1),
    );
  }

  // ============================================
  // THEME GETTER (for backward compatibility)
  // ============================================
  static ThemeData get theme => lightTheme;

  // ============================================
  // SYSTEM UI OVERLAY STYLE
  // ============================================

  /// Set system UI overlay style
  static void setSystemUIOverlayStyle() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }
}
