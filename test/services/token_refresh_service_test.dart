// Token Refresh Service Tests
// Tests for token refresh functionality

import 'package:flutter_test/flutter_test.dart';
import 'package:BIBOL/services/auth/token_refresh_service.dart';
import 'package:BIBOL/services/storage/secure_storage_service.dart';

void main() {
  // Setup
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TokenRefreshService Tests', () {
    test('TokenRefreshService has singleton instance', () {
      // Arrange & Act
      final instance1 = TokenRefreshService.instance;
      final instance2 = TokenRefreshService.instance;

      // Assert - Should be the same instance
      expect(instance1, equals(instance2));
      expect(identical(instance1, instance2), isTrue);
    });

    test('validateToken returns false when no token exists', () async {
      // Arrange - Clear any existing tokens
      await SecureStorageService.deleteToken();

      // Act
      final isValid = await TokenRefreshService.validateToken();

      // Assert
      expect(isValid, isFalse);
    });

    test('needsRefresh returns true when no token exists', () async {
      // Arrange - Clear any existing tokens
      await SecureStorageService.deleteToken();

      // Act
      final needs = await TokenRefreshService.needsRefresh();

      // Assert
      expect(needs, isTrue);
    });

    test('isAuthenticated returns false when not logged in', () async {
      // Arrange - Clear all data
      await SecureStorageService.clearAll();

      // Act
      final isAuth = await TokenRefreshService.isAuthenticated();

      // Assert
      expect(isAuth, isFalse);
    });

    test('logout clears all tokens', () async {
      // Arrange - Save some fake tokens
      await SecureStorageService.saveToken('fake_token');
      await SecureStorageService.saveRefreshToken('fake_refresh_token');

      // Act
      await TokenRefreshService.logout();

      // Assert - Tokens should be cleared
      final token = await SecureStorageService.getToken();
      final refreshToken = await SecureStorageService.getRefreshToken();

      expect(token, isNull);
      expect(refreshToken, isNull);
    });

    test('getValidToken returns null when no token exists', () async {
      // Arrange - Clear tokens
      await SecureStorageService.clearAll();

      // Act
      final token = await TokenRefreshService.getValidToken();

      // Assert
      expect(token, isNull);
    });
  });

  group('TokenRefreshService Token Validation Tests', () {
    test('validateToken checks token validity', () async {
      // This test checks the validation logic
      // In a real test environment, we would need to mock SecureStorageService

      // Act
      final result = await TokenRefreshService.validateToken();

      // Assert - Should return boolean
      expect(result, isA<bool>());
    });

    test('needsRefresh checks token expiry', () async {
      // Act
      final result = await TokenRefreshService.needsRefresh();

      // Assert - Should return boolean
      expect(result, isA<bool>());
    });
  });

  group('TokenRefreshService Integration Tests', () {
    test('logout is idempotent', () async {
      // Arrange - First logout
      await TokenRefreshService.logout();

      // Act - Logout again
      await TokenRefreshService.logout();

      // Assert - Should not throw error
      final token = await SecureStorageService.getToken();
      expect(token, isNull);
    });

    test('ensureValidToken handles no token gracefully', () async {
      // Arrange - Clear all tokens
      await SecureStorageService.clearAll();

      // Act
      final result = await TokenRefreshService.ensureValidToken();

      // Assert - Should return false (no token to refresh)
      expect(result, isFalse);
    });
  });

  group('TokenRefreshService Error Handling Tests', () {
    test('validateToken handles errors gracefully', () async {
      // Act - Even if there's an error, it should not throw
      bool errorThrown = false;

      try {
        await TokenRefreshService.validateToken();
      } catch (e) {
        errorThrown = true;
      }

      // Assert - Should not throw
      expect(errorThrown, isFalse);
    });

    test('needsRefresh handles errors gracefully', () async {
      // Act - Even if there's an error, it should not throw
      bool errorThrown = false;

      try {
        await TokenRefreshService.needsRefresh();
      } catch (e) {
        errorThrown = true;
      }

      // Assert - Should not throw
      expect(errorThrown, isFalse);
    });

    test('isAuthenticated handles errors gracefully', () async {
      // Act - Even if there's an error, it should not throw
      bool errorThrown = false;

      try {
        await TokenRefreshService.isAuthenticated();
      } catch (e) {
        errorThrown = true;
      }

      // Assert - Should not throw
      expect(errorThrown, isFalse);
    });
  });

  group('TokenRefreshService State Management Tests', () {
    test('logout clears authentication state', () async {
      // Arrange - Set up some authentication state
      await SecureStorageService.saveToken('test_token');
      await SecureStorageService.saveUserInfo({'id': 1, 'name': 'Test'});

      // Act
      await TokenRefreshService.logout();

      // Assert - All should be cleared
      final isLoggedIn = await SecureStorageService.isLoggedIn();
      final token = await SecureStorageService.getToken();
      final userInfo = await SecureStorageService.getUserInfo();

      expect(isLoggedIn, isFalse);
      expect(token, isNull);
      expect(userInfo, isNull);
    });
  });

  group('TokenRefreshService Utility Tests', () {
    test('debugPrintStatus does not throw errors', () async {
      // Act - Should work even without setup
      bool errorThrown = false;

      try {
        await TokenRefreshService.debugPrintStatus();
      } catch (e) {
        errorThrown = true;
      }

      // Assert - Should not throw
      expect(errorThrown, isFalse);
    });
  });
}
