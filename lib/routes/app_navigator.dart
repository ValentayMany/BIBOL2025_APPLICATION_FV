// lib/config/routes/app_navigator.dart

// ignore_for_file: avoid_print

import 'package:BIBOL/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:BIBOL/models/course/course_model.dart';

/// Navigation Helper Class
/// ใช้สำหรับจัดการการนำทางในแอพ
class AppNavigator {
  // Private constructor
  AppNavigator._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Navigate to a route
  static Future<void> navigateTo(String routeName, {Object? arguments}) async {
    try {
      await navigatorKey.currentState?.pushNamed(
        routeName,
        arguments: arguments,
      );
    } catch (e) {
      print('❌ Navigation Error: $e');
    }
  }

  /// Navigate and replace current route
  static Future<void> navigateAndReplace(
    String routeName, {
    Object? arguments,
  }) async {
    try {
      await navigatorKey.currentState?.pushReplacementNamed(
        routeName,
        arguments: arguments,
      );
    } catch (e) {
      print('❌ Navigation Error: $e');
    }
  }

  /// Navigate and remove all previous routes
  static Future<void> navigateAndRemoveAll(String routeName) async {
    try {
      await navigatorKey.currentState?.pushNamedAndRemoveUntil(
        routeName,
        (route) => false,
      );
    } catch (e) {
      print('❌ Navigation Error: $e');
    }
  }

  /// Go back to previous screen
  static void goBack() {
    try {
      navigatorKey.currentState?.pop();
    } catch (e) {
      print('❌ Navigation Error: $e');
    }
  }

  /// Navigate to course detail page
  static Future<void> navigateToCourseDetail(CourseModel course) async {
    try {
      await navigatorKey.currentState?.pushNamed(
        AppRoutes.courseDetail,
        arguments: course,
      );
    } catch (e) {
      print('❌ Navigation Error: $e');
    }
  }

  /// Navigate to news detail page
  static Future<void> navigateToNewsDetail(String newsId) async {
    try {
      await navigatorKey.currentState?.pushNamed(
        AppRoutes.newsDetail,
        arguments: newsId,
      );
    } catch (e) {
      print('❌ Navigation Error: $e');
    }
  }
}
