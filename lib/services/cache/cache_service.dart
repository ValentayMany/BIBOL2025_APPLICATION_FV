// lib/services/cache/cache_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:BIBOL/utils/logger.dart';

/// 💾 Cache Service
/// Handles offline caching of data using Hive
class CacheService {
  // Private constructor
  CacheService._();

  // Box names
  static const String _newsBoxName = 'news_cache';
  static const String _coursesBoxName = 'courses_cache';
  static const String _galleryBoxName = 'gallery_cache';
  static const String _configBoxName = 'config_cache';

  // Singleton instance
  static final CacheService _instance = CacheService._();
  static CacheService get instance => _instance;

  // Initialization flag
  static bool _isInitialized = false;

  /// Initialize Hive and open boxes
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Hive.initFlutter();

      // Open all boxes
      await Future.wait([
        Hive.openBox(_newsBoxName),
        Hive.openBox(_coursesBoxName),
        Hive.openBox(_galleryBoxName),
        Hive.openBox(_configBoxName),
      ]);

      _isInitialized = true;
      AppLogger.success('Cache service initialized', tag: 'CACHE');
    } catch (e) {
      AppLogger.error('Failed to initialize cache', tag: 'CACHE', error: e);
      rethrow;
    }
  }

  /// ============================================
  /// NEWS CACHE
  /// ============================================

  /// Cache news list
  static Future<void> cacheNews(List<Map<String, dynamic>> newsList) async {
    try {
      await _ensureInitialized();
      final box = Hive.box(_newsBoxName);

      await box.put('news_list', jsonEncode(newsList));
      await box.put('news_timestamp', DateTime.now().toIso8601String());

      AppLogger.debug('Cached ${newsList.length} news items', tag: 'CACHE');
    } catch (e) {
      AppLogger.error('Failed to cache news', tag: 'CACHE', error: e);
    }
  }

  /// Get cached news
  static Future<List<Map<String, dynamic>>?> getCachedNews({
    Duration maxAge = const Duration(hours: 24),
  }) async {
    try {
      await _ensureInitialized();
      final box = Hive.box(_newsBoxName);

      final newsJson = box.get('news_list');
      final timestampStr = box.get('news_timestamp');

      if (newsJson == null || timestampStr == null) {
        return null;
      }

      // Check if cache is still valid
      final timestamp = DateTime.parse(timestampStr as String);
      if (DateTime.now().difference(timestamp) > maxAge) {
        AppLogger.debug('News cache expired', tag: 'CACHE');
        return null;
      }

      final List<dynamic> decoded = jsonDecode(newsJson as String);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      AppLogger.error('Failed to get cached news', tag: 'CACHE', error: e);
      return null;
    }
  }

  /// Clear news cache
  static Future<void> clearNewsCache() async {
    try {
      await _ensureInitialized();
      final box = Hive.box(_newsBoxName);
      await box.clear();
      AppLogger.debug('News cache cleared', tag: 'CACHE');
    } catch (e) {
      AppLogger.error('Failed to clear news cache', tag: 'CACHE', error: e);
    }
  }

  /// ============================================
  /// COURSES CACHE
  /// ============================================

  /// Cache courses list
  static Future<void> cacheCourses(
    List<Map<String, dynamic>> coursesList,
  ) async {
    try {
      await _ensureInitialized();
      final box = Hive.box(_coursesBoxName);

      await box.put('courses_list', jsonEncode(coursesList));
      await box.put('courses_timestamp', DateTime.now().toIso8601String());

      AppLogger.debug('Cached ${coursesList.length} courses', tag: 'CACHE');
    } catch (e) {
      AppLogger.error('Failed to cache courses', tag: 'CACHE', error: e);
    }
  }

  /// Get cached courses
  static Future<List<Map<String, dynamic>>?> getCachedCourses({
    Duration maxAge = const Duration(hours: 24),
  }) async {
    try {
      await _ensureInitialized();
      final box = Hive.box(_coursesBoxName);

      final coursesJson = box.get('courses_list');
      final timestampStr = box.get('courses_timestamp');

      if (coursesJson == null || timestampStr == null) {
        return null;
      }

      // Check if cache is still valid
      final timestamp = DateTime.parse(timestampStr as String);
      if (DateTime.now().difference(timestamp) > maxAge) {
        AppLogger.debug('Courses cache expired', tag: 'CACHE');
        return null;
      }

      final List<dynamic> decoded = jsonDecode(coursesJson as String);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      AppLogger.error('Failed to get cached courses', tag: 'CACHE', error: e);
      return null;
    }
  }

  /// Clear courses cache
  static Future<void> clearCoursesCache() async {
    try {
      await _ensureInitialized();
      final box = Hive.box(_coursesBoxName);
      await box.clear();
      AppLogger.debug('Courses cache cleared', tag: 'CACHE');
    } catch (e) {
      AppLogger.error('Failed to clear courses cache', tag: 'CACHE', error: e);
    }
  }

  /// ============================================
  /// GALLERY CACHE
  /// ============================================

  /// Cache gallery items
  static Future<void> cacheGallery(
    List<Map<String, dynamic>> galleryList,
  ) async {
    try {
      await _ensureInitialized();
      final box = Hive.box(_galleryBoxName);

      await box.put('gallery_list', jsonEncode(galleryList));
      await box.put('gallery_timestamp', DateTime.now().toIso8601String());

      AppLogger.debug(
        'Cached ${galleryList.length} gallery items',
        tag: 'CACHE',
      );
    } catch (e) {
      AppLogger.error('Failed to cache gallery', tag: 'CACHE', error: e);
    }
  }

  /// Get cached gallery
  static Future<List<Map<String, dynamic>>?> getCachedGallery({
    Duration maxAge = const Duration(hours: 24),
  }) async {
    try {
      await _ensureInitialized();
      final box = Hive.box(_galleryBoxName);

      final galleryJson = box.get('gallery_list');
      final timestampStr = box.get('gallery_timestamp');

      if (galleryJson == null || timestampStr == null) {
        return null;
      }

      // Check if cache is still valid
      final timestamp = DateTime.parse(timestampStr as String);
      if (DateTime.now().difference(timestamp) > maxAge) {
        AppLogger.debug('Gallery cache expired', tag: 'CACHE');
        return null;
      }

      final List<dynamic> decoded = jsonDecode(galleryJson as String);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      AppLogger.error('Failed to get cached gallery', tag: 'CACHE', error: e);
      return null;
    }
  }

  /// Clear gallery cache
  static Future<void> clearGalleryCache() async {
    try {
      await _ensureInitialized();
      final box = Hive.box(_galleryBoxName);
      await box.clear();
      AppLogger.debug('Gallery cache cleared', tag: 'CACHE');
    } catch (e) {
      AppLogger.error('Failed to clear gallery cache', tag: 'CACHE', error: e);
    }
  }

  /// ============================================
  /// CONFIG CACHE
  /// ============================================

  /// Save config value
  static Future<void> saveConfig(String key, dynamic value) async {
    try {
      await _ensureInitialized();
      final box = Hive.box(_configBoxName);
      await box.put(key, value);
      AppLogger.debug('Config saved: $key', tag: 'CACHE');
    } catch (e) {
      AppLogger.error('Failed to save config', tag: 'CACHE', error: e);
    }
  }

  /// Get config value
  static Future<dynamic> getConfig(String key, {dynamic defaultValue}) async {
    try {
      await _ensureInitialized();
      final box = Hive.box(_configBoxName);
      return box.get(key, defaultValue: defaultValue);
    } catch (e) {
      AppLogger.error('Failed to get config', tag: 'CACHE', error: e);
      return defaultValue;
    }
  }

  /// ============================================
  /// UTILITY METHODS
  /// ============================================

  /// Clear all cache
  static Future<void> clearAll() async {
    try {
      await _ensureInitialized();

      await Future.wait([
        clearNewsCache(),
        clearCoursesCache(),
        clearGalleryCache(),
        Hive.box(_configBoxName).clear(),
      ]);

      AppLogger.info('All cache cleared', tag: 'CACHE');
    } catch (e) {
      AppLogger.error('Failed to clear all cache', tag: 'CACHE', error: e);
    }
  }

  /// Get cache size
  static Future<Map<String, int>> getCacheSize() async {
    try {
      await _ensureInitialized();

      return {
        'news': Hive.box(_newsBoxName).length,
        'courses': Hive.box(_coursesBoxName).length,
        'gallery': Hive.box(_galleryBoxName).length,
        'config': Hive.box(_configBoxName).length,
      };
    } catch (e) {
      AppLogger.error('Failed to get cache size', tag: 'CACHE', error: e);
      return {};
    }
  }

  /// Check if cache exists
  static Future<bool> hasCachedData() async {
    try {
      await _ensureInitialized();

      final newsBox = Hive.box(_newsBoxName);
      final coursesBox = Hive.box(_coursesBoxName);

      return newsBox.isNotEmpty || coursesBox.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Close all boxes (call this when app is closing)
  static Future<void> close() async {
    try {
      await Hive.close();
      _isInitialized = false;
      AppLogger.info('Cache service closed', tag: 'CACHE');
    } catch (e) {
      AppLogger.error('Failed to close cache', tag: 'CACHE', error: e);
    }
  }

  /// ============================================
  /// INTERNAL METHODS
  /// ============================================

  /// Ensure cache is initialized
  static Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  /// Print cache statistics (for debugging)
  static Future<void> printStatistics() async {
    if (kDebugMode) {
      try {
        await _ensureInitialized();

        final sizes = await getCacheSize();

        AppLogger.section('CACHE STATISTICS');
        AppLogger.debug('News items: ${sizes['news']}', tag: 'CACHE');
        AppLogger.debug('Courses items: ${sizes['courses']}', tag: 'CACHE');
        AppLogger.debug('Gallery items: ${sizes['gallery']}', tag: 'CACHE');
        AppLogger.debug('Config items: ${sizes['config']}', tag: 'CACHE');
        AppLogger.divider();
      } catch (e) {
        AppLogger.error('Failed to print statistics', tag: 'CACHE', error: e);
      }
    }
  }
}
