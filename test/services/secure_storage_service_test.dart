// test/services/secure_storage_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:BIBOL/services/storage/secure_storage_service.dart';
import '../helpers/shared_prefs_helpers.dart';
import '../helpers/in_memory_secure_storage_adapter.dart';
import 'package:BIBOL/services/storage/secure_storage_adapter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SecureStorageService Tests', () {
    setUpAll(() async {
      // Initialize mocks once for the group
      TestWidgetsFlutterBinding.ensureInitialized();
      // use in-memory adapter to avoid platform channels
      SecureStorageService.setAdapter(InMemorySecureStorageAdapter());
      setupMockSharedPreferences();
    });

    setUp(() async {
      // Clear all data before each test
      await SecureStorageService.clearAll();
    });

    tearDown(() async {
      // Clean up after each test
      await SecureStorageService.clearAll();
    });

    tearDownAll(() async {
      // No platform channel mocks used; just reset shared preferences
      tearDownMockSharedPreferences();
    });

    test('should save and retrieve token', () async {
      const testToken = 'test_token_12345';

      await SecureStorageService.saveToken(testToken);
      final retrievedToken = await SecureStorageService.getToken();

      expect(retrievedToken, equals(testToken));
    });

    test('should validate token expiry', () async {
      const testToken = 'test_token_12345';

      await SecureStorageService.saveToken(testToken);
      final isValid = await SecureStorageService.isTokenValid();

      expect(isValid, isTrue);
    });

    test('should save and retrieve user info', () async {
      final testUserInfo = {
        'id': 1,
        'first_name': 'Test',
        'last_name': 'User',
        'email': 'test@example.com',
      };

      await SecureStorageService.saveUserInfo(testUserInfo);
      final retrievedInfo = await SecureStorageService.getUserInfo();

      expect(retrievedInfo, isNotNull);
      expect(retrievedInfo!['first_name'], equals('Test'));
      expect(retrievedInfo['email'], equals('test@example.com'));
    });

    test('should check login status correctly', () async {
      // Initially not logged in
      expect(await SecureStorageService.isLoggedIn(), isFalse);

      // After saving token and user info
      await SecureStorageService.saveToken('test_token');
      await SecureStorageService.saveUserInfo({'id': 1, 'name': 'Test'});

      expect(await SecureStorageService.isLoggedIn(), isTrue);
    });

    test('should clear all data', () async {
      await SecureStorageService.saveToken('test_token');
      await SecureStorageService.saveUserInfo({'id': 1, 'name': 'Test'});

      await SecureStorageService.clearAll();

      expect(await SecureStorageService.getToken(), isNull);
      expect(await SecureStorageService.getUserInfo(), isNull);
      expect(await SecureStorageService.isLoggedIn(), isFalse);
    });
  });
}
