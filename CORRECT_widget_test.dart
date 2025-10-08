// BIBOL App - Basic Widget Tests
// These tests verify that the app initializes correctly

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:BIBOL/main.dart';

void main() {
  // Disable HTTP requests during tests
  TestWidgetsFlutterBinding.ensureInitialized();

  group('App Initialization Tests', () {
    testWidgets('App initializes without crashing', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(const MyApp());
      await tester.pump();

      // Verify app builds successfully
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App has correct title', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pump();

      // Check MaterialApp configuration
      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.title, equals('Banking Institute App'));
      expect(app.debugShowCheckedModeBanner, isFalse);
    });
  });
}
