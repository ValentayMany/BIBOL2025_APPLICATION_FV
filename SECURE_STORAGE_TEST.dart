// test/services/secure_storage_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:BIBOL/services/storage/secure_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SecureStorageService Tests', () {
    setUp(() async {
      // Clear all data before each test
      try {
        await SecureStorageService.clearAll();
      } catch (e) {
        // Ignore errors during setup
      }
    });

    tearDown(() async {
      // Clean up after each test
      try {
        await SecureStorageService.clearAll();
      } catch (e) {
        // Ignore errors during teardown
      }
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
      final initialStatus = await SecureStorageService.isLoggedIn();
      expect(initialStatus, isFalse);
      
      // After saving token and user info
      await SecureStorageService.saveToken('test_token');
      await SecureStorageService.saveUserInfo({'id': 1, 'name': 'Test'});
      
      final loggedInStatus = await SecureStorageService.isLoggedIn();
      expect(loggedInStatus, isTrue);
    });

    test('should clear all data', () async {
      await SecureStorageService.saveToken('test_token');
      await SecureStorageService.saveUserInfo({'id': 1, 'name': 'Test'});
      
      await SecureStorageService.clearAll();
      
      final token = await SecureStorageService.getToken();
      final userInfo = await SecureStorageService.getUserInfo();
      final isLoggedIn = await SecureStorageService.isLoggedIn();
      
      expect(token, isNull);
      expect(userInfo, isNull);
      expect(isLoggedIn, isFalse);
    });
  });
}
