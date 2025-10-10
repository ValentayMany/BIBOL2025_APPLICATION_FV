// Push Notification Service Tests
// Tests for push notification functionality

import 'package:flutter_test/flutter_test.dart';
import 'package:BIBOL/services/notifications/push_notification_service.dart';

void main() {
  // Setup
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PushNotificationService Tests', () {
    test('PushNotificationService has singleton instance', () {
      // Arrange & Act
      final instance1 = PushNotificationService.instance;
      final instance2 = PushNotificationService.instance;

      // Assert - Should be the same instance
      expect(instance1, equals(instance2));
      expect(identical(instance1, instance2), isTrue);
    });

    test('clearBadge completes without error', () async {
      // Act - Should complete without throwing
      bool errorThrown = false;

      try {
        await PushNotificationService.clearBadge();
      } catch (e) {
        errorThrown = true;
      }

      // Assert - Should not throw error
      expect(errorThrown, isFalse);
    });

    test('getToken handles uninitialized state gracefully', () async {
      // Act - Before initialization
      final token = await PushNotificationService.getToken();

      // Assert - Should return null when not initialized
      expect(token, isNull);
    });

    test('deleteToken handles uninitialized state gracefully', () async {
      // Act - Should not throw when not initialized
      bool errorThrown = false;

      try {
        await PushNotificationService.deleteToken();
      } catch (e) {
        errorThrown = true;
      }

      // Assert - Should not throw
      expect(errorThrown, isFalse);
    });

    test('subscribeToTopic handles uninitialized state gracefully', () async {
      // Act - Should not throw when not initialized
      bool errorThrown = false;

      try {
        await PushNotificationService.subscribeToTopic('test_topic');
      } catch (e) {
        errorThrown = true;
      }

      // Assert - Should not throw
      expect(errorThrown, isFalse);
    });

    test('unsubscribeFromTopic handles uninitialized state gracefully',
        () async {
      // Act - Should not throw when not initialized
      bool errorThrown = false;

      try {
        await PushNotificationService.unsubscribeFromTopic('test_topic');
      } catch (e) {
        errorThrown = true;
      }

      // Assert - Should not throw
      expect(errorThrown, isFalse);
    });

    test('areNotificationsEnabled returns false when not initialized',
        () async {
      // Act
      final enabled = await PushNotificationService.areNotificationsEnabled();

      // Assert - Should return false when Firebase not initialized
      expect(enabled, isFalse);
    });
  });

  group('PushNotificationService Error Handling Tests', () {
    test('getToken handles errors gracefully', () async {
      // Act - Even with Firebase not initialized
      bool errorThrown = false;

      try {
        await PushNotificationService.getToken();
      } catch (e) {
        errorThrown = true;
      }

      // Assert - Should not throw
      expect(errorThrown, isFalse);
    });

    test('areNotificationsEnabled handles errors gracefully', () async {
      // Act
      bool errorThrown = false;

      try {
        await PushNotificationService.areNotificationsEnabled();
      } catch (e) {
        errorThrown = true;
      }

      // Assert - Should not throw
      expect(errorThrown, isFalse);
    });
  });

  group('PushNotificationService Utility Tests', () {
    test('debugPrintStatus does not throw errors', () async {
      // Act - Should work even without Firebase
      bool errorThrown = false;

      try {
        await PushNotificationService.debugPrintStatus();
      } catch (e) {
        errorThrown = true;
      }

      // Assert - Should not throw
      expect(errorThrown, isFalse);
    });

    test('clearBadge is idempotent', () async {
      // Act - Clear badge multiple times
      await PushNotificationService.clearBadge();
      await PushNotificationService.clearBadge();
      await PushNotificationService.clearBadge();

      // Assert - Should not throw error
      expect(true, isTrue);
    });
  });

  group('PushNotificationService Integration Tests', () {
    test('initialize handles missing Firebase gracefully', () async {
      // Act - Initialize without Firebase configured
      final result = await PushNotificationService.initialize();

      // Assert - Should return false when Firebase not configured
      // (Since we don't have Firebase configured in test environment)
      expect(result, isFalse);
    });

    test('initialize accepts callbacks', () async {
      // Arrange
      bool messageCalled = false;
      bool tokenCalled = false;

      // Act
      await PushNotificationService.initialize(
        onMessage: (message) {
          messageCalled = true;
        },
        onTokenRefresh: (token) {
          tokenCalled = true;
        },
      );

      // Assert - Callbacks should be stored (even if not called in test)
      expect(messageCalled, isFalse); // Won't be called without Firebase
      expect(tokenCalled, isFalse); // Won't be called without Firebase
    });
  });

  group('PushNotificationService State Tests', () {
    test('getToken returns null before initialization', () async {
      // Act
      final token = await PushNotificationService.getToken();

      // Assert
      expect(token, isNull);
    });

    test('areNotificationsEnabled returns false before initialization',
        () async {
      // Act
      final enabled = await PushNotificationService.areNotificationsEnabled();

      // Assert
      expect(enabled, isFalse);
    });
  });

  group('PushNotificationService Topic Management Tests', () {
    test('subscribeToTopic with valid topic name', () async {
      // Act - Should not throw even if Firebase not initialized
      bool errorThrown = false;

      try {
        await PushNotificationService.subscribeToTopic('valid_topic_name');
      } catch (e) {
        errorThrown = true;
      }

      // Assert
      expect(errorThrown, isFalse);
    });

    test('unsubscribeFromTopic with valid topic name', () async {
      // Act - Should not throw even if Firebase not initialized
      bool errorThrown = false;

      try {
        await PushNotificationService.unsubscribeFromTopic('valid_topic_name');
      } catch (e) {
        errorThrown = true;
      }

      // Assert
      expect(errorThrown, isFalse);
    });

    test('topic operations are safe when called multiple times', () async {
      // Act - Multiple subscriptions/unsubscriptions
      await PushNotificationService.subscribeToTopic('test');
      await PushNotificationService.subscribeToTopic('test');
      await PushNotificationService.unsubscribeFromTopic('test');
      await PushNotificationService.unsubscribeFromTopic('test');

      // Assert - Should complete without errors
      expect(true, isTrue);
    });
  });

  group('PushNotificationService Badge Tests', () {
    test('clearBadge can be called multiple times', () async {
      // Act
      await PushNotificationService.clearBadge();
      await PushNotificationService.clearBadge();
      await PushNotificationService.clearBadge();

      // Assert - Should not throw
      expect(true, isTrue);
    });
  });
}
