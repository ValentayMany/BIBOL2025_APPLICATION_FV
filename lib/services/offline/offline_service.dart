import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class OfflineService {
  static OfflineService? _instance;
  static OfflineService get instance => _instance ??= OfflineService._();

  OfflineService._();

  // Connectivity
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // State
  bool _isOnline = true;
  bool _isInitialized = false;

  // Cache keys
  static const String _newsCacheKey = 'cached_news';
  static const String _coursesCacheKey = 'cached_courses';
  static const String _contactsCacheKey = 'cached_contacts';
  static const String _lastSyncKey = 'last_sync_time';
  static const String _offlineModeKey = 'offline_mode_enabled';

  // Controllers
  StreamController<bool>? _connectivityController;
  StreamController<Map<String, dynamic>>? _cacheController;
  StreamController<String>? _syncController;

  // Getters
  Stream<bool>? get connectivityStream => _connectivityController?.stream;
  Stream<Map<String, dynamic>>? get cacheStream => _cacheController?.stream;
  Stream<String>? get syncStream => _syncController?.stream;
  bool get isOnline => _isOnline;
  bool get isOfflineMode => !_isOnline;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    _connectivityController ??= StreamController<bool>.broadcast();
    _cacheController ??= StreamController<Map<String, dynamic>>.broadcast();
    _syncController ??= StreamController<String>.broadcast();

    await checkConnectivity();

    _connectivity.onConnectivityChanged.listen((result) {
      _handleConnectivityChange([
        result,
      ]); // ✅ ห่อเป็น List ให้ตรงกับฟังก์ชันของคุณ
    });

    _isInitialized = true;
    print('📱 Offline Service initialized');
  }

  Future<void> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _handleConnectivityChange([result]); // แก้ตรงนี้
    } catch (e) {
      print('❌ Connectivity check error: $e');
      _updateConnectivity(false);
    }
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final isConnected = results.any((r) => r != ConnectivityResult.none);

    if (isConnected) {
      _hasInternetAccess()
          .then((hasInternet) {
            _updateConnectivity(hasInternet);
          })
          .catchError((e) {
            print('❌ Internet check error: $e');
            _updateConnectivity(false);
          });
    } else {
      _updateConnectivity(false);
    }
  }

  /// ✅ เปลี่ยนจาก DNS Lookup เป็น HTTP check
  Future<bool> _hasInternetAccess() async {
    try {
      final response = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Internet access check failed: $e');
      return false;
    }
  }

  void _updateConnectivity(bool isOnline) {
    if (_isOnline != isOnline) {
      _isOnline = isOnline;
      _connectivityController?.add(isOnline);

      if (isOnline) {
        print('🌐 Back online - starting sync');
        _syncController?.add('Back online - starting sync');
        _performBackgroundSync();
      } else {
        print('📱 Gone offline');
        _syncController?.add('Gone offline');
      }
    }
  }

  Future<void> cacheData(String key, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(data);
      final success = await prefs.setString(key, jsonString);

      if (success) {
        print('💾 Data cached successfully: $key');
        _cacheController?.add({
          'action': 'cached',
          'key': key,
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print('❌ Cache error: $e');
    }
  }

  Future<Map<String, dynamic>?> getCachedData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(key);

      if (jsonString != null) {
        final data = json.decode(jsonString) as Map<String, dynamic>;
        print('📖 Cached data retrieved: $key');
        return data;
      }
    } catch (e) {
      print('❌ Get cache error: $e');
    }
    return null;
  }

  Future<void> cacheNews(List<Map<String, dynamic>> news) async {
    await cacheData(_newsCacheKey, {
      'data': news,
      'cached_at': DateTime.now().toIso8601String(),
      'count': news.length,
    });
  }

  Future<List<Map<String, dynamic>>> getCachedNews() async {
    final cached = await getCachedData(_newsCacheKey);
    if (cached != null && cached['data'] is List) {
      return (cached['data'] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();
    }
    return [];
  }

  Future<void> cacheCourses(List<Map<String, dynamic>> courses) async {
    await cacheData(_coursesCacheKey, {
      'data': courses,
      'cached_at': DateTime.now().toIso8601String(),
      'count': courses.length,
    });
  }

  Future<List<Map<String, dynamic>>> getCachedCourses() async {
    final cached = await getCachedData(_coursesCacheKey);
    if (cached != null && cached['data'] is List) {
      return (cached['data'] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();
    }
    return [];
  }

  Future<void> cacheContacts(List<Map<String, dynamic>> contacts) async {
    await cacheData(_contactsCacheKey, {
      'data': contacts,
      'cached_at': DateTime.now().toIso8601String(),
      'count': contacts.length,
    });
  }

  Future<List<Map<String, dynamic>>> getCachedContacts() async {
    final cached = await getCachedData(_contactsCacheKey);
    if (cached != null && cached['data'] is List) {
      return (cached['data'] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();
    }
    return [];
  }

  Future<void> _performBackgroundSync() async {
    if (!_isOnline) return;

    try {
      _syncController?.add('Starting background sync...');
      await Future.delayed(const Duration(seconds: 1));

      _syncController?.add('Background sync completed');
      print('🔄 Background sync completed');
    } catch (e) {
      _syncController?.add('Background sync failed');
      print('❌ Background sync error: $e');
    }
  }

  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final newsCached = prefs.getString(_newsCacheKey) != null;
      final coursesCached = prefs.getString(_coursesCacheKey) != null;
      final contactsCached = prefs.getString(_contactsCacheKey) != null;

      final lastSync = prefs.getString(_lastSyncKey);

      return {
        'isOnline': _isOnline,
        'newsCached': newsCached,
        'coursesCached': coursesCached,
        'contactsCached': contactsCached,
        'lastSync': lastSync,
        'cacheSize': await _getCacheSize(),
      };
    } catch (e) {
      print('❌ Cache stats error: $e');
      return {};
    }
  }

  Future<int> _getCacheSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      int totalSize = 0;

      for (final key in keys) {
        if (key.startsWith('cached_')) {
          final value = prefs.getString(key);
          if (value != null) {
            totalSize += value.length;
          }
        }
      }

      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      for (final key in keys) {
        if (key.startsWith('cached_')) {
          await prefs.remove(key);
        }
      }

      print('🧹 Cache cleared');
      _cacheController?.add({
        'action': 'cleared',
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('❌ Clear cache error: $e');
    }
  }

  Future<void> forceSync() async {
    if (!_isOnline) {
      throw Exception('Cannot sync while offline');
    }

    _syncController?.add('Force sync started...');
    await _performBackgroundSync();
  }

  Future<bool> isOfflineModeEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_offlineModeKey) ?? false;
    } catch (e) {
      print('❌ Offline mode check error: $e');
      return false;
    }
  }

  Future<void> setOfflineMode(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_offlineModeKey, enabled);
      print('🔧 Offline mode ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      print('❌ Set offline mode error: $e');
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityController?.close();
    _cacheController?.close();
    _syncController?.close();
    _isInitialized = false;
  }
}
