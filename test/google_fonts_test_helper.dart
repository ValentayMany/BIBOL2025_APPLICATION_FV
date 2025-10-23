import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

class GoogleFontsTestHelper {
  /// Initialize Google Fonts for testing
  static void initialize() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  }

  /// Create a test widget wrapped in MaterialApp
  static Widget createTestWidget(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  /// Create a test widget with custom theme
  static Widget createTestWidgetWithTheme(Widget child, {ThemeData? theme}) {
    return MaterialApp(
      theme: theme ?? ThemeData.light(),
      home: Scaffold(body: child),
    );
  }
}
