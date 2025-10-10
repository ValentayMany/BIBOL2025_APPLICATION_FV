// lib/utils/notification_helper.dart

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:BIBOL/services/notifications/push_notification_service.dart';
import 'package:BIBOL/utils/logger.dart';

/// 🔔 Notification Helper
/// Helper functions for handling push notifications
class NotificationHelper {
  // Private constructor
  NotificationHelper._();

  /// Handle notification tap navigation
  static Future<void> handleNotificationTap(
    BuildContext context,
    RemoteMessage message,
  ) async {
    try {
      final data = message.data;
      final type = data['type'];
      final id = data['id'];

      AppLogger.info('Handling notification tap: $type, $id', tag: 'NOTIF');

      // Clear badge when opening notification
      await PushNotificationService.clearBadge();

      // Navigate based on notification type
      switch (type) {
        case 'news':
          _navigateToNews(context, id);
          break;
        case 'course':
          _navigateToCourse(context, id);
          break;
        case 'announcement':
          _navigateToAnnouncement(context, id);
          break;
        case 'gallery':
          _navigateToGallery(context, id);
          break;
        default:
          AppLogger.warning('Unknown notification type: $type', tag: 'NOTIF');
      }
    } catch (e) {
      AppLogger.error('Error handling notification tap', tag: 'NOTIF', error: e);
    }
  }

  /// Navigate to news detail
  static void _navigateToNews(BuildContext context, String? newsId) {
    if (newsId == null) return;

    try {
      // TODO: Navigate to news detail page
      // Navigator.pushNamed(context, '/news/$newsId');
      AppLogger.debug('Navigating to news: $newsId', tag: 'NOTIF');
    } catch (e) {
      AppLogger.error('Error navigating to news', tag: 'NOTIF', error: e);
    }
  }

  /// Navigate to course detail
  static void _navigateToCourse(BuildContext context, String? courseId) {
    if (courseId == null) return;

    try {
      // TODO: Navigate to course detail page
      // Navigator.pushNamed(context, '/course/$courseId');
      AppLogger.debug('Navigating to course: $courseId', tag: 'NOTIF');
    } catch (e) {
      AppLogger.error('Error navigating to course', tag: 'NOTIF', error: e);
    }
  }

  /// Navigate to announcement
  static void _navigateToAnnouncement(BuildContext context, String? announcementId) {
    if (announcementId == null) return;

    try {
      // TODO: Navigate to announcement page
      AppLogger.debug('Navigating to announcement: $announcementId', tag: 'NOTIF');
    } catch (e) {
      AppLogger.error('Error navigating to announcement', tag: 'NOTIF', error: e);
    }
  }

  /// Navigate to gallery
  static void _navigateToGallery(BuildContext context, String? galleryId) {
    if (galleryId == null) return;

    try {
      // TODO: Navigate to gallery page
      AppLogger.debug('Navigating to gallery: $galleryId', tag: 'NOTIF');
    } catch (e) {
      AppLogger.error('Error navigating to gallery', tag: 'NOTIF', error: e);
    }
  }

  /// Show in-app notification banner
  static void showInAppNotification(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 4),
  }) {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: ListTile(
            leading: const Icon(
              Icons.notifications_active,
              color: Colors.white,
            ),
            title: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              message,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          backgroundColor: Colors.blue.shade700,
          behavior: SnackBarBehavior.floating,
          duration: duration,
          action: onTap != null
              ? SnackBarAction(
                  label: 'View',
                  textColor: Colors.white,
                  onPressed: onTap,
                )
              : null,
        ),
      );
    } catch (e) {
      AppLogger.error('Error showing in-app notification', tag: 'NOTIF', error: e);
    }
  }

  /// Request notification permissions (iOS)
  static Future<bool> requestPermissions() async {
    try {
      AppLogger.info('Requesting notification permissions', tag: 'NOTIF');

      // Initialize if not already done
      final initialized = await PushNotificationService.initialize();
      if (!initialized) {
        AppLogger.error('Failed to initialize notifications', tag: 'NOTIF');
        return false;
      }

      // Check if enabled
      final enabled = await PushNotificationService.areNotificationsEnabled();
      AppLogger.info('Notifications enabled: $enabled', tag: 'NOTIF');

      return enabled;
    } catch (e) {
      AppLogger.error('Error requesting permissions', tag: 'NOTIF', error: e);
      return false;
    }
  }

  /// Subscribe to default topics
  static Future<void> subscribeToDefaultTopics() async {
    try {
      AppLogger.info('Subscribing to default topics', tag: 'NOTIF');

      // Subscribe to general topics
      await PushNotificationService.subscribeToTopic('all_users');
      await PushNotificationService.subscribeToTopic('announcements');
      await PushNotificationService.subscribeToTopic('news');

      AppLogger.success('Subscribed to default topics', tag: 'NOTIF');
    } catch (e) {
      AppLogger.error('Error subscribing to topics', tag: 'NOTIF', error: e);
    }
  }

  /// Subscribe to student-specific topics
  static Future<void> subscribeToStudentTopics({
    required String studentId,
    String? major,
    String? year,
  }) async {
    try {
      AppLogger.info('Subscribing to student topics', tag: 'NOTIF');

      // Subscribe to student-specific topic
      await PushNotificationService.subscribeToTopic('student_$studentId');

      // Subscribe to major-specific topic
      if (major != null) {
        await PushNotificationService.subscribeToTopic('major_$major');
      }

      // Subscribe to year-specific topic
      if (year != null) {
        await PushNotificationService.subscribeToTopic('year_$year');
      }

      AppLogger.success('Subscribed to student topics', tag: 'NOTIF');
    } catch (e) {
      AppLogger.error('Error subscribing to student topics', tag: 'NOTIF', error: e);
    }
  }

  /// Unsubscribe from all topics (on logout)
  static Future<void> unsubscribeFromAllTopics({
    required String studentId,
    String? major,
    String? year,
  }) async {
    try {
      AppLogger.info('Unsubscribing from all topics', tag: 'NOTIF');

      // Unsubscribe from default topics
      await PushNotificationService.unsubscribeFromTopic('all_users');
      await PushNotificationService.unsubscribeFromTopic('announcements');
      await PushNotificationService.unsubscribeFromTopic('news');

      // Unsubscribe from student-specific topics
      await PushNotificationService.unsubscribeFromTopic('student_$studentId');

      if (major != null) {
        await PushNotificationService.unsubscribeFromTopic('major_$major');
      }

      if (year != null) {
        await PushNotificationService.unsubscribeFromTopic('year_$year');
      }

      AppLogger.success('Unsubscribed from all topics', tag: 'NOTIF');
    } catch (e) {
      AppLogger.error('Error unsubscribing from topics', tag: 'NOTIF', error: e);
    }
  }

  /// Send FCM token to backend
  static Future<void> sendTokenToBackend(String token) async {
    try {
      AppLogger.info('Sending FCM token to backend', tag: 'NOTIF');

      // TODO: Implement API call to send token to backend
      // Example:
      // await ApiInterceptor.post(
      //   'https://api.bibol.edu.la/notifications/register',
      //   body: {'fcm_token': token},
      // );

      AppLogger.success('FCM token sent to backend', tag: 'NOTIF');
    } catch (e) {
      AppLogger.error('Error sending token to backend', tag: 'NOTIF', error: e);
    }
  }

  /// Delete FCM token from backend (on logout)
  static Future<void> deleteTokenFromBackend(String token) async {
    try {
      AppLogger.info('Deleting FCM token from backend', tag: 'NOTIF');

      // TODO: Implement API call to delete token from backend
      // Example:
      // await ApiInterceptor.delete(
      //   'https://api.bibol.edu.la/notifications/unregister',
      //   body: {'fcm_token': token},
      // );

      AppLogger.success('FCM token deleted from backend', tag: 'NOTIF');
    } catch (e) {
      AppLogger.error('Error deleting token from backend', tag: 'NOTIF', error: e);
    }
  }

  /// Setup notification listeners for the app
  static Future<void> setupNotificationListeners(BuildContext context) async {
    try {
      AppLogger.info('Setting up notification listeners', tag: 'NOTIF');

      await PushNotificationService.initialize(
        onMessage: (RemoteMessage message) {
          // Show in-app notification when app is in foreground
          final notification = message.notification;
          if (notification != null) {
            showInAppNotification(
              context,
              title: notification.title ?? 'BIBOL',
              message: notification.body ?? '',
              onTap: () {
                handleNotificationTap(context, message);
              },
            );
          }
        },
        onTokenRefresh: (String token) {
          // Send new token to backend
          sendTokenToBackend(token);
        },
      );

      AppLogger.success('Notification listeners setup complete', tag: 'NOTIF');
    } catch (e) {
      AppLogger.error('Error setting up listeners', tag: 'NOTIF', error: e);
    }
  }
}
