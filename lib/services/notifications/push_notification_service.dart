// lib/services/notifications/push_notification_service.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:BIBOL/utils/logger.dart';

/// 🔔 Push Notification Service
/// Handles Firebase Cloud Messaging and local notifications
class PushNotificationService {
  // Private constructor for singleton
  PushNotificationService._();

  // Singleton instance
  static final PushNotificationService _instance = PushNotificationService._();
  static PushNotificationService get instance => _instance;

  // Firebase Messaging instance
  static FirebaseMessaging? _firebaseMessaging;

  // Local Notifications plugin
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Notification callback
  static Function(RemoteMessage)? _onMessageCallback;
  static Function(String)? _onTokenRefreshCallback;

  // Initialization flag
  static bool _isInitialized = false;

  // Badge count
  static int _badgeCount = 0;

  /// ============================================
  /// INITIALIZATION
  /// ============================================

  /// Initialize push notifications
  static Future<bool> initialize({
    Function(RemoteMessage)? onMessage,
    Function(String)? onTokenRefresh,
  }) async {
    if (_isInitialized) {
      AppLogger.warning('Push notifications already initialized', tag: 'PUSH');
      return true;
    }

    try {
      AppLogger.info('Initializing push notifications...', tag: 'PUSH');

      // Store callbacks
      _onMessageCallback = onMessage;
      _onTokenRefreshCallback = onTokenRefresh;

      // Initialize Firebase (if not already initialized)
      if (Firebase.apps.isEmpty) {
        AppLogger.debug('Firebase not initialized, skipping FCM setup', tag: 'PUSH');
        // Note: Firebase needs to be initialized with firebase_options.dart
        // Run: flutterfire configure
        return false;
      }

      // Get Firebase Messaging instance
      _firebaseMessaging = FirebaseMessaging.instance;

      // Request permissions (iOS)
      await _requestPermissions();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Setup message handlers
      _setupMessageHandlers();

      // Get FCM token
      final token = await _firebaseMessaging!.getToken();
      if (token != null) {
        AppLogger.success('FCM Token: $token', tag: 'PUSH');
        _onTokenRefreshCallback?.call(token);
      }

      // Listen for token refresh
      _firebaseMessaging!.onTokenRefresh.listen((newToken) {
        AppLogger.info('FCM Token refreshed: $newToken', tag: 'PUSH');
        _onTokenRefreshCallback?.call(newToken);
      });

      _isInitialized = true;
      AppLogger.success('Push notifications initialized', tag: 'PUSH');
      return true;
    } catch (e) {
      AppLogger.error('Failed to initialize push notifications', tag: 'PUSH', error: e);
      return false;
    }
  }

  /// Request notification permissions (iOS)
  static Future<void> _requestPermissions() async {
    try {
      final settings = await _firebaseMessaging!.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      AppLogger.info(
        'Notification permissions: ${settings.authorizationStatus}',
        tag: 'PUSH',
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        AppLogger.success('Notifications permission granted', tag: 'PUSH');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        AppLogger.info('Provisional notification permission granted', tag: 'PUSH');
      } else {
        AppLogger.warning('Notification permission denied', tag: 'PUSH');
      }
    } catch (e) {
      AppLogger.error('Error requesting permissions', tag: 'PUSH', error: e);
    }
  }

  /// Initialize local notifications
  static Future<void> _initializeLocalNotifications() async {
    try {
      // Android initialization
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Initialization settings
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize
      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      AppLogger.success('Local notifications initialized', tag: 'PUSH');
    } catch (e) {
      AppLogger.error('Failed to initialize local notifications', tag: 'PUSH', error: e);
    }
  }

  /// Setup message handlers
  static void _setupMessageHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppLogger.info('Received foreground message', tag: 'PUSH');
      _handleForegroundMessage(message);
    });

    // Background messages (when app is in background but not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLogger.info('Notification opened app from background', tag: 'PUSH');
      _handleNotificationTap(message);
    });

    // Handle initial message (when app is opened from terminated state)
    _firebaseMessaging!.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        AppLogger.info('App opened from terminated state', tag: 'PUSH');
        _handleNotificationTap(message);
      }
    });
  }

  /// ============================================
  /// MESSAGE HANDLERS
  /// ============================================

  /// Handle foreground message (show local notification)
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    try {
      AppLogger.debug('Foreground message data: ${message.data}', tag: 'PUSH');

      final notification = message.notification;
      if (notification != null) {
        // Show local notification
        await _showLocalNotification(
          title: notification.title ?? 'BIBOL',
          body: notification.body ?? '',
          payload: message.data.toString(),
        );

        // Increment badge
        _badgeCount++;
        await _updateBadge(_badgeCount);
      }

      // Trigger callback
      _onMessageCallback?.call(message);
    } catch (e) {
      AppLogger.error('Error handling foreground message', tag: 'PUSH', error: e);
    }
  }

  /// Handle notification tap
  static void _handleNotificationTap(RemoteMessage message) {
    try {
      AppLogger.info('Notification tapped', tag: 'PUSH');
      AppLogger.debug('Message data: ${message.data}', tag: 'PUSH');

      // Trigger callback
      _onMessageCallback?.call(message);

      // Navigate to specific screen based on data
      _navigateBasedOnData(message.data);
    } catch (e) {
      AppLogger.error('Error handling notification tap', tag: 'PUSH', error: e);
    }
  }

  /// Handle local notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    try {
      AppLogger.info('Local notification tapped', tag: 'PUSH');
      AppLogger.debug('Payload: ${response.payload}', tag: 'PUSH');

      // Parse payload and navigate
      // Note: In real implementation, you'd parse the payload properly
    } catch (e) {
      AppLogger.error('Error handling local notification tap', tag: 'PUSH', error: e);
    }
  }

  /// Navigate based on notification data
  static void _navigateBasedOnData(Map<String, dynamic> data) {
    try {
      // Example: Navigate to specific screen based on 'type' field
      final type = data['type'];
      final id = data['id'];

      AppLogger.debug('Navigation type: $type, id: $id', tag: 'PUSH');

      // TODO: Implement navigation logic
      // Example:
      // if (type == 'news') {
      //   Navigator.pushNamed(context, '/news/$id');
      // }
    } catch (e) {
      AppLogger.error('Error navigating from notification', tag: 'PUSH', error: e);
    }
  }

  /// ============================================
  /// LOCAL NOTIFICATIONS
  /// ============================================

  /// Show local notification
  static Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      // Android notification details
      const androidDetails = AndroidNotificationDetails(
        'bibol_channel', // Channel ID
        'BIBOL Notifications', // Channel name
        channelDescription: 'Notifications from BIBOL app',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
      );

      // iOS notification details
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      // Notification details
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Show notification
      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000, // Unique ID
        title,
        body,
        details,
        payload: payload,
      );

      AppLogger.success('Local notification shown', tag: 'PUSH');
    } catch (e) {
      AppLogger.error('Failed to show local notification', tag: 'PUSH', error: e);
    }
  }

  /// ============================================
  /// BADGE MANAGEMENT
  /// ============================================

  /// Update badge count
  static Future<void> _updateBadge(int count) async {
    try {
      if (Platform.isIOS) {
        // iOS badge update would be handled via native code or plugin
        AppLogger.debug('Badge count: $count', tag: 'PUSH');
      }
    } catch (e) {
      AppLogger.error('Error updating badge', tag: 'PUSH', error: e);
    }
  }

  /// Clear badge
  static Future<void> clearBadge() async {
    try {
      _badgeCount = 0;
      await _updateBadge(0);
      AppLogger.success('Badge cleared', tag: 'PUSH');
    } catch (e) {
      AppLogger.error('Error clearing badge', tag: 'PUSH', error: e);
    }
  }

  /// ============================================
  /// TOKEN MANAGEMENT
  /// ============================================

  /// Get FCM token
  static Future<String?> getToken() async {
    try {
      if (_firebaseMessaging == null) {
        AppLogger.warning('Firebase Messaging not initialized', tag: 'PUSH');
        return null;
      }

      final token = await _firebaseMessaging!.getToken();
      AppLogger.debug('FCM Token: $token', tag: 'PUSH');
      return token;
    } catch (e) {
      AppLogger.error('Error getting FCM token', tag: 'PUSH', error: e);
      return null;
    }
  }

  /// Delete FCM token
  static Future<void> deleteToken() async {
    try {
      if (_firebaseMessaging == null) {
        AppLogger.warning('Firebase Messaging not initialized', tag: 'PUSH');
        return;
      }

      await _firebaseMessaging!.deleteToken();
      AppLogger.success('FCM Token deleted', tag: 'PUSH');
    } catch (e) {
      AppLogger.error('Error deleting FCM token', tag: 'PUSH', error: e);
    }
  }

  /// Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    try {
      if (_firebaseMessaging == null) {
        AppLogger.warning('Firebase Messaging not initialized', tag: 'PUSH');
        return;
      }

      await _firebaseMessaging!.subscribeToTopic(topic);
      AppLogger.success('Subscribed to topic: $topic', tag: 'PUSH');
    } catch (e) {
      AppLogger.error('Error subscribing to topic', tag: 'PUSH', error: e);
    }
  }

  /// Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      if (_firebaseMessaging == null) {
        AppLogger.warning('Firebase Messaging not initialized', tag: 'PUSH');
        return;
      }

      await _firebaseMessaging!.unsubscribeFromTopic(topic);
      AppLogger.success('Unsubscribed from topic: $topic', tag: 'PUSH');
    } catch (e) {
      AppLogger.error('Error unsubscribing from topic', tag: 'PUSH', error: e);
    }
  }

  /// ============================================
  /// UTILITY METHODS
  /// ============================================

  /// Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    try {
      if (_firebaseMessaging == null) {
        return false;
      }

      final settings = await _firebaseMessaging!.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      AppLogger.error('Error checking notification status', tag: 'PUSH', error: e);
      return false;
    }
  }

  /// Debug: Print notification status
  static Future<void> debugPrintStatus() async {
    if (kDebugMode) {
      try {
        AppLogger.section('PUSH NOTIFICATION STATUS');
        AppLogger.debug('Initialized: $_isInitialized', tag: 'PUSH');
        AppLogger.debug('Badge Count: $_badgeCount', tag: 'PUSH');

        final token = await getToken();
        AppLogger.debug('FCM Token: ${token ?? "Not available"}', tag: 'PUSH');

        final enabled = await areNotificationsEnabled();
        AppLogger.debug('Notifications Enabled: $enabled', tag: 'PUSH');

        AppLogger.divider();
      } catch (e) {
        AppLogger.error('Error printing status', tag: 'PUSH', error: e);
      }
    }
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if needed
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }

  AppLogger.info('Background message received', tag: 'PUSH');
  AppLogger.debug('Message data: ${message.data}', tag: 'PUSH');

  // Handle background message
  // Note: Cannot update UI from here
}
