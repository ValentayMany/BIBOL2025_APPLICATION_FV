// lib/providers/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  
  ThemeMode _themeMode = ThemeMode.light;
  bool _isDarkMode = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  /// Load theme from SharedPreferences
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey) ?? 0;
      
      switch (themeIndex) {
        case 0:
          _themeMode = ThemeMode.light;
          _isDarkMode = false;
          break;
        case 1:
          _themeMode = ThemeMode.dark;
          _isDarkMode = true;
          break;
        case 2:
          _themeMode = ThemeMode.system;
          _isDarkMode = false; // Will be determined by system
          break;
        default:
          _themeMode = ThemeMode.light;
          _isDarkMode = false;
      }
      
      notifyListeners();
    } catch (e) {
      // If error, default to light theme
      _themeMode = ThemeMode.light;
      _isDarkMode = false;
      notifyListeners();
    }
  }

  /// Save theme to SharedPreferences
  Future<void> _saveTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int themeIndex;
      
      switch (_themeMode) {
        case ThemeMode.light:
          themeIndex = 0;
          break;
        case ThemeMode.dark:
          themeIndex = 1;
          break;
        case ThemeMode.system:
          themeIndex = 2;
          break;
      }
      
      await prefs.setInt(_themeKey, themeIndex);
    } catch (e) {
      // Handle error silently
    }
  }

  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
      _isDarkMode = true;
    } else {
      _themeMode = ThemeMode.light;
      _isDarkMode = false;
    }
    
    await _saveTheme();
    notifyListeners();
  }

  /// Set specific theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    
    switch (mode) {
      case ThemeMode.light:
        _isDarkMode = false;
        break;
      case ThemeMode.dark:
        _isDarkMode = true;
        break;
      case ThemeMode.system:
        // System theme will be determined by the system
        _isDarkMode = false;
        break;
    }
    
    await _saveTheme();
    notifyListeners();
  }

  /// Get theme name for display
  String get themeName {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'ທີມສະຫວ່າງ';
      case ThemeMode.dark:
        return 'ທີມມືດ';
      case ThemeMode.system:
        return 'ຕາມລະບົບ';
    }
  }

  /// Get theme description
  String get themeDescription {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'ສະບາຍຕາຕໍ່າວັນ';
      case ThemeMode.dark:
        return 'ສະບາຍຕາຕໍ່າຄືນ';
      case ThemeMode.system:
        return 'ຕາມການຕັ້ງຄ່າລະບົບ';
    }
  }

  /// Get theme icon
  IconData get themeIcon {
    switch (_themeMode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }
}
