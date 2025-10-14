// test/helpers/mock_secure_storage.dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

final MethodChannel _secureStorageChannel = const MethodChannel(
  'plugins.it_nomads.com/flutter_secure_storage',
);

/// In-memory map to simulate secure storage
final Map<String, String> _inMemorySecureStorage = <String, String>{};

/// Register mock handlers for flutter_secure_storage MethodChannel using the
/// TestDefaultBinaryMessenger so tests running on the VM can intercept calls.
Future<void> setupMockSecureStorage() async {
  _inMemorySecureStorage.clear();

  _secureStorageChannel.setMockMethodCallHandler((MethodCall call) async {
    final args = call.arguments as Map<dynamic, dynamic>?;
    switch (call.method) {
      case 'write':
        final key = args?['key'] as String?;
        final value = args?['value'] as String?;
        if (key != null) {
          if (value == null) {
            _inMemorySecureStorage.remove(key);
          } else {
            _inMemorySecureStorage[key] = value;
          }
        }
        return null;
      case 'read':
        final key = args?['key'] as String?;
        return key == null ? null : _inMemorySecureStorage[key];
      case 'delete':
        final key = args?['key'] as String?;
        if (key != null) _inMemorySecureStorage.remove(key);
        return null;
      case 'readAll':
        return Map<String, String>.from(_inMemorySecureStorage);
      case 'deleteAll':
        _inMemorySecureStorage.clear();
        return null;
      default:
        throw PlatformException(
          code: 'Unimplemented',
          message: 'Mock for ${call.method} not implemented',
        );
    }
  });
}

/// Remove mock handler and clear storage
Future<void> tearDownMockSecureStorage() async {
  _secureStorageChannel.setMockMethodCallHandler(null);
}

/// Initialize SharedPreferences with empty in-memory values for tests
void setupMockSharedPreferences([Map<String, Object>? initialValues]) {
  SharedPreferences.setMockInitialValues(initialValues ?? <String, Object>{});
}

/// Clear SharedPreferences mock
Future<void> tearDownMockSharedPreferences() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
}
