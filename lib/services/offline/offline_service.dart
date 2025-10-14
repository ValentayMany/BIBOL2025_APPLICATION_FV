/// OfflineService - Service สำหรับจัดการ Offline Mode
///
/// Service นี้จัดการการทำงานแบบ offline โดยใช้ cache
/// และ sync ข้อมูลเมื่อกลับมา online
///
/// **ฟีเจอร์หลัก:**
/// - Cache-first strategy
/// - Background sync เมื่อกลับมา online
/// - ตรวจสอบสถานะ network
/// - แสดงข้อมูล cache ระหว่างรอ
///
/// **ตัวอย่างการใช้งาน:**
/// ```dart
/// // ตรวจสอบว่า online หรือไม่
/// final isOnline = await OfflineService.isOnline();
///
/// // ดึงข้อมูลแบบ offline-aware
/// final news = await OfflineService.getNewsOfflineAware();
///
/// // Sync ข้อมูลเมื่อกลับมา online
/// await OfflineService.syncWhenOnline();
/// ```
library;

import 'dart:async';
import 'dart:io';
import 'package:BIBOL/services/cache/cache_service.dart';
import 'package:BIBOL/services/news/news_service.dart';
import 'package:BIBOL/services/course/course_service.dart';
import 'package:BIBOL/utils/logger.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class OfflineService {
  // Private constructor
  OfflineService._();

  // Singleton instance
  static final OfflineService _instance = OfflineService._();
  static OfflineService get instance => _instance;

  // Connectivity
  static final Connectivity _connectivity = Connectivity();
  static StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  // Callbacks
  static Function()? _onOnline;
  static Function()? _onOffline;

  /// เริ่มต้น Offline Service
  ///
  /// **Parameters:**
  /// - [onOnline] - callback เมื่อกลับมา online
  /// - [onOffline] - callback เมื่อเป็น offline
  static Future<void> initialize({
    Function()? onOnline,
    Function()? onOffline,
  }) async {
    _onOnline = onOnline;
    _onOffline = onOffline;

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (ConnectivityResult result) async {
        try {
          final connResult = result;

          if (connResult != ConnectivityResult.none) {
            AppLogger.info('🟢 Back online!', tag: 'OFFLINE');
            _onOnline?.call();
            await syncWhenOnline();
          } else {
            AppLogger.info('🔴 Offline', tag: 'OFFLINE');
            _onOffline?.call();
          }
        } catch (e) {
          AppLogger.error(
            'Error in connectivity listener',
            tag: 'OFFLINE',
            error: e,
          );
        }
      },
      onError: (error) {
        AppLogger.error(
          'Connectivity stream error',
          tag: 'OFFLINE',
          error: error,
        );
      },
    );

    AppLogger.success('Offline service initialized', tag: 'OFFLINE');
  }

  /// ตรวจสอบว่า online หรือไม่
  ///
  /// **Returns:**
  /// - [bool] - true ถ้า online
  static Future<bool> isOnline() async {
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    } catch (e) {
      AppLogger.error('Error checking online status', tag: 'OFFLINE', error: e);
      return false;
    }
  }

  /// ตรวจสอบว่า connectivity type
  ///
  /// **Returns:**
  /// - [List<ConnectivityResult>] - ประเภทการเชื่อมต่อ
  static Future<ConnectivityResult> getConnectivityType() async {
    try {
      return await _connectivity.checkConnectivity();
    } catch (e) {
      AppLogger.error(
        'Error getting connectivity type',
        tag: 'OFFLINE',
        error: e,
      );
      return ConnectivityResult.none;
    }
  }

  /// ========================================
  /// OFFLINE-AWARE DATA FETCHING
  /// ========================================

  /// ดึงข่าวแบบ offline-aware
  ///
  /// Strategy:
  /// 1. แสดง cache ก่อน (ถ้ามี)
  /// 2. ดึงข้อมูลใหม่จาก API (ถ้า online)
  /// 3. อัพเดท cache
  ///
  /// **Parameters:**
  /// - [onCacheLoaded] - callback เมื่อโหลด cache เสร็จ
  /// - [onFreshDataLoaded] - callback เมื่อโหลดข้อมูลใหม่เสร็จ
  ///
  /// **Example:**
  /// ```dart
  /// await OfflineService.getNewsOfflineAware(
  ///   onCacheLoaded: (cachedNews) {
  ///     setState(() => news = cachedNews); // แสดง cache ก่อน
  ///   },
  ///   onFreshDataLoaded: (freshNews) {
  ///     setState(() => news = freshNews); // อัพเดทด้วยข้อมูลใหม่
  ///   },
  /// );
  /// ```
  static Future<void> getNewsOfflineAware({
    Function(List<Map<String, dynamic>>)? onCacheLoaded,
    Function(List<Map<String, dynamic>>)? onFreshDataLoaded,
  }) async {
    try {
      // 1. โหลด cache ก่อน
      final cachedNews = await CacheService.getCachedNews();
      if (cachedNews != null && cachedNews.isNotEmpty) {
        AppLogger.info('📦 Using cached news', tag: 'OFFLINE');
        onCacheLoaded?.call(cachedNews);
      }

      // 2. ถ้า online ดึงข้อมูลใหม่
      if (await isOnline()) {
        try {
          final newsResponse = await NewsService.getNews(limit: 10);
          // NewsResponse stores items in `data` as NewsModel which contains topics
          final newsList =
              newsResponse.data
                  .expand((newsModel) => newsModel.topics)
                  .map(
                    (topic) => {
                      'id': topic.id,
                      'title': topic.title,
                      'details': topic.details,
                      'photo_file': topic.photoFile,
                      'visits': topic.visits,
                    },
                  )
                  .toList();

          // 3. บันทึก cache
          await CacheService.cacheNews(newsList);

          AppLogger.info('🔄 Fresh data loaded', tag: 'OFFLINE');
          onFreshDataLoaded?.call(newsList);
        } catch (e) {
          AppLogger.error(
            'Failed to fetch fresh news',
            tag: 'OFFLINE',
            error: e,
          );
          // ถ้าดึงไม่ได้ ใช้ cache ต่อ
        }
      } else {
        AppLogger.info('📴 Offline - using cache only', tag: 'OFFLINE');
      }
    } catch (e) {
      AppLogger.error('Error in getNewsOfflineAware', tag: 'OFFLINE', error: e);
    }
  }

  /// ดึงหลักสูตรแบบ offline-aware
  ///
  /// **Parameters:**
  /// - [onCacheLoaded] - callback เมื่อโหลด cache เสร็จ
  /// - [onFreshDataLoaded] - callback เมื่อโหลดข้อมูลใหม่เสร็จ
  static Future<void> getCoursesOfflineAware({
    Function(List<Map<String, dynamic>>)? onCacheLoaded,
    Function(List<Map<String, dynamic>>)? onFreshDataLoaded,
  }) async {
    try {
      // 1. โหลด cache ก่อน
      final cachedCourses = await CacheService.getCachedCourses();
      if (cachedCourses != null && cachedCourses.isNotEmpty) {
        AppLogger.info('📦 Using cached courses', tag: 'OFFLINE');
        onCacheLoaded?.call(cachedCourses);
      }

      // 2. ถ้า online ดึงข้อมูลใหม่
      if (await isOnline()) {
        try {
          final coursesResponse = await CourseService.fetchCourses();
          final coursesList =
              coursesResponse.courses
                  .map(
                    (course) => {
                      'id': course.id,
                      'title': course.title,
                      'icon': course.icon,
                      // CourseModel doesn't have `recommended`; include details instead
                      'details': course.details,
                    },
                  )
                  .toList();

          // 3. บันทึก cache
          await CacheService.cacheCourses(coursesList);

          AppLogger.info('🔄 Fresh courses loaded', tag: 'OFFLINE');
          onFreshDataLoaded?.call(coursesList);
        } catch (e) {
          AppLogger.error(
            'Failed to fetch fresh courses',
            tag: 'OFFLINE',
            error: e,
          );
        }
      } else {
        AppLogger.info('📴 Offline - using cache only', tag: 'OFFLINE');
      }
    } catch (e) {
      AppLogger.error(
        'Error in getCoursesOfflineAware',
        tag: 'OFFLINE',
        error: e,
      );
    }
  }

  /// ========================================
  /// SYNC
  /// ========================================

  /// Sync ข้อมูลเมื่อกลับมา online
  ///
  /// จะดึงข้อมูลใหม่ทั้งหมดและอัพเดท cache
  static Future<void> syncWhenOnline() async {
    if (!await isOnline()) {
      AppLogger.info('Cannot sync - offline', tag: 'OFFLINE');
      return;
    }

    AppLogger.info('🔄 Syncing data...', tag: 'OFFLINE');

    try {
      // Sync news
      final newsResponse = await NewsService.getNews(limit: 10);
      final newsList =
          newsResponse.data
              .expand((newsModel) => newsModel.topics)
              .map(
                (topic) => {
                  'id': topic.id,
                  'title': topic.title,
                  'details': topic.details,
                  'photo_file': topic.photoFile,
                  'visits': topic.visits,
                },
              )
              .toList();
      await CacheService.cacheNews(newsList);

      // Sync courses
      final coursesResponse = await CourseService.fetchCourses();
      final coursesList =
          coursesResponse.courses
              .map(
                (course) => {
                  'id': course.id,
                  'title': course.title,
                  'icon': course.icon,
                  'details': course.details,
                },
              )
              .toList();
      await CacheService.cacheCourses(coursesList);

      AppLogger.success('✅ Sync completed', tag: 'OFFLINE');
    } catch (e) {
      AppLogger.error('Sync failed', tag: 'OFFLINE', error: e);
    }
  }

  /// ========================================
  /// CLEANUP
  /// ========================================

  /// ปิด offline service
  static void dispose() {
    _connectivitySubscription?.cancel();
    AppLogger.info('Offline service disposed', tag: 'OFFLINE');
  }
}
