// Secure Storage Service Tests
// Tests for secure token storage functionality
// Note: These tests require platform channels and will be skipped in test environment

import 'package:flutter_test/flutter_test.dart';
import 'package:BIBOL/services/storage/secure_storage_service.dart';

void main() {
  // Setup
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SecureStorageService Tests (Platform-dependent)', () {
    // These tests require flutter_secure_storage platform channels
    // They are skipped in CI/CD but can be run on real devices
    
    test('should save and retrieve token', () async {
      // Arrange
      const testToken = 'test_token_123';

      // Act
      await SecureStorageService.saveToken(testToken);
      final retrievedToken = await SecureStorageService.getToken();

      // Assert
      expect(retrievedToken, equals(testToken));
    }, skip: 'Requires platform channels (flutter_secure_storage)');

    test('should validate token expiry', () async {
      // Arrange
      const testToken = 'test_token_123';
      await SecureStorageService.saveToken(testToken);

      // Act
      final isValid = await SecureStorageService.isTokenValid();

      // Assert
      expect(isValid, isTrue);
    }, skip: 'Requires platform channels (flutter_secure_storage)');

    test('should save and retrieve user info', () async {
      // Arrange
      final testUserInfo = {
        'id': 1,
        'name': 'Test User',
        'email': 'test@example.com'
      };

      // Act
      await SecureStorageService.saveUserInfo(testUserInfo);
      final retrievedUserInfo = await SecureStorageService.getUserInfo();

      // Assert
      expect(retrievedUserInfo, isNotNull);
      expect(retrievedUserInfo!['id'], equals(1));
      expect(retrievedUserInfo['name'], equals('Test User'));
    }, skip: 'Requires platform channels (flutter_secure_storage)');

    test('should check login status correctly', () async {
      // Arrange
      const testToken = 'test_token_123';
      await SecureStorageService.saveToken(testToken);
      await SecureStorageService.saveUserInfo({'id': 1});

      // Act
      final isLoggedIn = await SecureStorageService.isLoggedIn();

      // Assert
      expect(isLoggedIn, isTrue);
    }, skip: 'Requires platform channels (flutter_secure_storage)');

    test('should clear all data', () async {
      // Arrange
      await SecureStorageService.saveToken('test_token');
      await SecureStorageService.saveUserInfo({'id': 1});

      // Act
      await SecureStorageService.clearAll();

      // Assert
      final token = await SecureStorageService.getToken();
      final userInfo = await SecureStorageService.getUserInfo();
      final isLoggedIn = await SecureStorageService.isLoggedIn();

      expect(token, isNull);
      expect(userInfo, isNull);
      expect(isLoggedIn, isFalse);
    }, skip: 'Requires platform channels (flutter_secure_storage)');
  });

  group('SecureStorageService Migration Tests', () {
    test('migrateFromOldService completes without error', () async {
      // Should not throw even without platform channels
      expect(
        () => SecureStorageService.migrateFromOldService(),
        returnsNormally,
      );
    }, skip: 'Requires platform channels');

    test('isSecureStorageAvailable returns Future<bool>', () async {
      final result = SecureStorageService.isSecureStorageAvailable();
      expect(result, isA<Future<bool>>());
    }, skip: 'Requires platform channels');
  });

  group('SecureStorageService Debug Methods', () {
    test('debugPrintAll does not throw', () {
      // Debug method should not throw synchronously
      expect(() => SecureStorageService.debugPrintAll(), returnsNormally);
    });

    test('getAllKeys returns Future', () {
      final result = SecureStorageService.getAllKeys();
      expect(result, isA<Future<List<String>>>());
    });
  });
}
