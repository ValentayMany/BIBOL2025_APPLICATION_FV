// test/flutter_test_config.dart
// This file is automatically loaded by the Flutter test harness before tests.
// Use it to set up platform channel mocks (path_provider, etc.) used across tests.

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void _setupMockPathProvider() {
  const channel = MethodChannel('plugins.flutter.io/path_provider');

  channel.setMockMethodCallHandler((MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'getApplicationDocumentsDirectory':
      case 'getApplicationSupportDirectory':
      case 'getTemporaryDirectory':
        // Return a writable temp directory path for tests
        return Directory.systemTemp.path;
      default:
        return null;
    }
  });
}

/// Called by the test harness
void initializeTestEnvironment() {
  TestWidgetsFlutterBinding.ensureInitialized();
  _setupMockPathProvider();
}
