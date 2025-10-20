import 'package:flutter/foundation.dart';
import 'package:BIBOL/services/offline/offline_service.dart';

/// 📱 Offline Provider
/// 
/// State management for offline mode and caching
class OfflineProvider with ChangeNotifier {
  static OfflineProvider? _instance;
  static OfflineProvider get instance => _instance ??= OfflineProvider._();
  
  OfflineProvider._();

  final OfflineService _service = OfflineService.instance;

  // State
  bool _isOnline = true;
  bool _isInitialized = false;
  bool _isOfflineModeEnabled = false;
  Map<String, dynamic> _cacheStats = {};

  // Getters
  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;
  bool get isInitialized => _isInitialized;
  bool get isOfflineModeEnabled => _isOfflineModeEnabled;
  Map<String, dynamic> get cacheStats => _cacheStats;

  /// 🚀 Initialize offline provider
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize service
    await _service.initialize();

    // Listen to connectivity changes
    _service.connectivityStream?.listen((isOnline) {
      _isOnline = isOnline;
      notifyListeners();
    });

    // Listen to cache changes
    _service.cacheStream?.listen((cacheData) {
      notifyListeners();
    });

    // Listen to sync status
    _service.syncStream?.listen((syncStatus) {
      notifyListeners();
    });

    // Load initial state
    _isOfflineModeEnabled = await _service.isOfflineModeEnabled();
    _cacheStats = await _service.getCacheStats();

    _isInitialized = true;
    notifyListeners();
    
    print('📱 Offline Provider initialized');
  }

  /// 🌐 Check connectivity
  Future<void> checkConnectivity() async {
    await _service.checkConnectivity();
  }

  /// 💾 Cache news data
  Future<void> cacheNews(List<Map<String, dynamic>> news) async {
    await _service.cacheNews(news);
    await _updateCacheStats();
  }

  /// 📖 Get cached news
  Future<List<Map<String, dynamic>>> getCachedNews() async {
    return await _service.getCachedNews();
  }

  /// 💾 Cache courses data
  Future<void> cacheCourses(List<Map<String, dynamic>> courses) async {
    await _service.cacheCourses(courses);
    await _updateCacheStats();
  }

  /// 📖 Get cached courses
  Future<List<Map<String, dynamic>>> getCachedCourses() async {
    return await _service.getCachedCourses();
  }

  /// 💾 Cache contacts data
  Future<void> cacheContacts(List<Map<String, dynamic>> contacts) async {
    await _service.cacheContacts(contacts);
    await _updateCacheStats();
  }

  /// 📖 Get cached contacts
  Future<List<Map<String, dynamic>>> getCachedContacts() async {
    return await _service.getCachedContacts();
  }

  /// 🔄 Force sync
  Future<void> forceSync() async {
    try {
      await _service.forceSync();
      await _updateCacheStats();
    } catch (e) {
      print('❌ Force sync error: $e');
      rethrow;
    }
  }

  /// 🧹 Clear cache
  Future<void> clearCache() async {
    await _service.clearCache();
    await _updateCacheStats();
  }

  /// 🔧 Enable/disable offline mode
  Future<void> setOfflineMode(bool enabled) async {
    await _service.setOfflineMode(enabled);
    _isOfflineModeEnabled = enabled;
    notifyListeners();
  }

  /// 📊 Update cache statistics
  Future<void> _updateCacheStats() async {
    _cacheStats = await _service.getCacheStats();
    notifyListeners();
  }

  /// 📊 Get detailed status
  Map<String, dynamic> getDetailedStatus() {
    return {
      'isOnline': _isOnline,
      'isOffline': !_isOnline,
      'isInitialized': _isInitialized,
      'isOfflineModeEnabled': _isOfflineModeEnabled,
      'cacheStats': _cacheStats,
      'serviceStatus': {
        'isOnline': _service.isOnline,
        'isInitialized': _service.isInitialized,
      },
    };
  }

  /// 🧹 Dispose provider
  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
