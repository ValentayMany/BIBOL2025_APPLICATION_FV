// lib/providers/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:BIBOL/theme/app_theme.dart';
import 'package:BIBOL/utils/logger.dart';

/// 🌙 Theme Provider
/// Manages theme state (light/dark mode) with persistence
/// 
/// Usage:
/// ```dart
/// // In main.dart
/// runApp(
///   ChangeNotifierProvider(
///     create: (_) => ThemeProvider(),
///     child: MyApp(),
///   ),
/// );
/// 
/// // In widget
/// final themeProvider = Provider.of<ThemeProvider>(context);
/// themeProvider.toggleTheme();
/// ```
class ThemeProvider with ChangeNotifier {
  // Private variables
  ThemeMode _themeMode = ThemeMode.light;
  bool _isLoading = true;

  // SharedPreferences key
  static const String _themeModeKey = 'theme_mode';

  /// Constructor - loads saved theme mode
  ThemeProvider() {
    _loadThemeMode();
  }

  // ============================================
  // GETTERS
  // ============================================

  /// Get current theme mode
  ThemeMode get themeMode => _themeMode;

  /// Check if dark mode is enabled
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Check if theme is loading
  bool get isLoading => _isLoading;

  /// Get light theme data
  ThemeData get lightTheme => AppTheme.lightTheme;

  /// Get dark theme data
  ThemeData get darkTheme => AppTheme.darkTheme;

  /// Get current theme data
  ThemeData get currentTheme => isDarkMode ? darkTheme : lightTheme;

  // ============================================
  // THEME MANAGEMENT
  // ============================================

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setDarkMode();
    } else {
      await setLightMode();
    }
  }

  /// Set light mode
  Future<void> setLightMode() async {
    _themeMode = ThemeMode.light;
    await _saveThemeMode();
    notifyListeners();
    AppLogger.info('Theme changed to light mode', tag: 'THEME');
  }

  /// Set dark mode
  Future<void> setDarkMode() async {
    _themeMode = ThemeMode.dark;
    await _saveThemeMode();
    notifyListeners();
    AppLogger.info('Theme changed to dark mode', tag: 'THEME');
  }

  /// Set system theme (follow system preference)
  Future<void> setSystemTheme() async {
    _themeMode = ThemeMode.system;
    await _saveThemeMode();
    notifyListeners();
    AppLogger.info('Theme changed to system default', tag: 'THEME');
  }

  // ============================================
  // PERSISTENCE
  // ============================================

  /// Load theme mode from SharedPreferences
  Future<void> _loadThemeMode() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final themeModeString = prefs.getString(_themeModeKey);

      if (themeModeString != null) {
        _themeMode = ThemeMode.values.firstWhere(
          (mode) => mode.toString() == themeModeString,
          orElse: () => ThemeMode.light,
        );
        AppLogger.success('Theme mode loaded: $_themeMode', tag: 'THEME');
      } else {
        AppLogger.info('No saved theme mode, using light mode', tag: 'THEME');
      }
    } catch (e) {
      AppLogger.error('Error loading theme mode', tag: 'THEME', error: e);
      _themeMode = ThemeMode.light;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save theme mode to SharedPreferences
  Future<void> _saveThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, _themeMode.toString());
      AppLogger.success('Theme mode saved: $_themeMode', tag: 'THEME');
    } catch (e) {
      AppLogger.error('Error saving theme mode', tag: 'THEME', error: e);
    }
  }

  // ============================================
  // HELPERS
  // ============================================

  /// Get theme mode as string
  String get themeModeString {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  /// Get theme mode icon
  IconData get themeModeIcon {
    switch (_themeMode) {
      case ThemeMode.light:
        return Icons.light_mode_rounded;
      case ThemeMode.dark:
        return Icons.dark_mode_rounded;
      case ThemeMode.system:
        return Icons.brightness_auto_rounded;
    }
  }

  /// Get theme mode display name (in Lao)
  String get themeModeDisplayName {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'ສະຫວ່າງ'; // Light
      case ThemeMode.dark:
        return 'ມືດ'; // Dark
      case ThemeMode.system:
        return 'ອັດຕະໂນມັດ'; // Auto
    }
  }
}
