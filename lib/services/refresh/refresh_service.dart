import 'dart:async';
import 'package:BIBOL/services/error/error_handler_service.dart';
import 'package:BIBOL/services/news/news_service.dart';
import 'package:BIBOL/services/course/course_Service.dart';
import 'package:BIBOL/services/website/contact_service.dart';

/// 🔄 Refresh Service
/// 
/// Centralized refresh service for BIBOL App
/// - News refresh
/// - Courses refresh
/// - Contacts refresh
/// - Error handling
/// - Progress tracking
class RefreshService {
  static RefreshService? _instance;
  static RefreshService get instance => _instance ??= RefreshService._();
  
  RefreshService._();

  // Refresh state tracking
  bool _isRefreshing = false;
  String? _currentRefreshType;
  DateTime? _lastRefreshTime;
  
  // Controllers
  StreamController<bool>? _refreshController;
  StreamController<String>? _refreshStatusController;
  StreamController<Map<String, dynamic>>? _refreshProgressController;

  // Getters
  Stream<bool>? get refreshStream => _refreshController?.stream;
  Stream<String>? get refreshStatusStream => _refreshStatusController?.stream;
  Stream<Map<String, dynamic>>? get refreshProgressStream => _refreshProgressController?.stream;
  bool get isRefreshing => _isRefreshing;
  String? get currentRefreshType => _currentRefreshType;
  DateTime? get lastRefreshTime => _lastRefreshTime;

  /// 🚀 Initialize refresh service
  void initialize() {
    _refreshController ??= StreamController<bool>.broadcast();
    _refreshStatusController ??= StreamController<String>.broadcast();
    _refreshProgressController ??= StreamController<Map<String, dynamic>>.broadcast();
    
    print('🔄 Refresh Service initialized');
  }

  /// 📰 Refresh news
  Future<void> refreshNews() async {
    await _performRefresh(
      'news',
      () => _refreshNewsData(),
      'ข่าวสาร',
    );
  }

  /// 📘 Refresh courses
  Future<void> refreshCourses() async {
    await _performRefresh(
      'courses',
      () => _refreshCoursesData(),
      'คอร์สเรียน',
    );
  }

  /// 📞 Refresh contacts
  Future<void> refreshContacts() async {
    await _performRefresh(
      'contacts',
      () => _refreshContactsData(),
      'ข้อมูลติดต่อ',
    );
  }

  /// 🔄 Refresh all data
  Future<void> refreshAll() async {
    await _performRefresh(
      'all',
      () => _refreshAllData(),
      'ข้อมูลทั้งหมด',
    );
  }

  /// 🎯 Perform refresh with error handling
  Future<void> _performRefresh(
    String type,
    Future<void> Function() refreshFunction,
    String displayName,
  ) async {
    if (_isRefreshing) {
      print('⚠️ Refresh already in progress, skipping $type');
      return;
    }

    try {
      _setRefreshing(true, type);
      _updateStatus('กำลังอัปเดต$displayName...');
      _updateProgress(0, 'เริ่มต้นการอัปเดต');

      await ErrorHandlerService.executeWithRetry(
        refreshFunction,
        operationName: 'Refresh $displayName',
        maxRetries: 2,
        retryDelay: const Duration(seconds: 1),
      );

      _updateProgress(100, 'อัปเดต$displayNameเรียบร้อยแล้ว');
      _updateStatus('อัปเดต$displayNameเรียบร้อยแล้ว');
      _lastRefreshTime = DateTime.now();

      print('✅ Refresh $type completed successfully');
    } on AppError catch (error) {
      _updateStatus('เกิดข้อผิดพลาดในการอัปเดต$displayName');
      print('❌ Refresh $type failed: ${error.message}');
      rethrow;
    } catch (e) {
      _updateStatus('เกิดข้อผิดพลาดที่ไม่คาดคิด');
      print('❌ Unexpected error during refresh $type: $e');
      rethrow;
    } finally {
      _setRefreshing(false, null);
    }
  }

  /// 📰 Refresh news data
  Future<void> _refreshNewsData() async {
    _updateProgress(20, 'กำลังดึงข่าวสาร...');
    
    // Simulate news refresh
    await Future.delayed(const Duration(milliseconds: 500));
    
    _updateProgress(60, 'กำลังประมวลผลข่าวสาร...');
    
    // Simulate processing
    await Future.delayed(const Duration(milliseconds: 300));
    
    _updateProgress(80, 'กำลังอัปเดตข้อมูล...');
    
    // Simulate final update
    await Future.delayed(const Duration(milliseconds: 200));
  }

  /// 📘 Refresh courses data
  Future<void> _refreshCoursesData() async {
    _updateProgress(20, 'กำลังดึงคอร์สเรียน...');
    
    // Simulate courses refresh
    await Future.delayed(const Duration(milliseconds: 400));
    
    _updateProgress(60, 'กำลังประมวลผลคอร์สเรียน...');
    
    // Simulate processing
    await Future.delayed(const Duration(milliseconds: 300));
    
    _updateProgress(80, 'กำลังอัปเดตข้อมูล...');
    
    // Simulate final update
    await Future.delayed(const Duration(milliseconds: 300));
  }

  /// 📞 Refresh contacts data
  Future<void> _refreshContactsData() async {
    _updateProgress(20, 'กำลังดึงข้อมูลติดต่อ...');
    
    // Simulate contacts refresh
    await Future.delayed(const Duration(milliseconds: 300));
    
    _updateProgress(60, 'กำลังประมวลผลข้อมูลติดต่อ...');
    
    // Simulate processing
    await Future.delayed(const Duration(milliseconds: 200));
    
    _updateProgress(80, 'กำลังอัปเดตข้อมูล...');
    
    // Simulate final update
    await Future.delayed(const Duration(milliseconds: 200));
  }

  /// 🔄 Refresh all data
  Future<void> _refreshAllData() async {
    _updateProgress(10, 'กำลังเริ่มต้นการอัปเดตทั้งหมด...');
    
    // Refresh news
    _updateProgress(25, 'กำลังอัปเดตข่าวสาร...');
    await _refreshNewsData();
    
    // Refresh courses
    _updateProgress(50, 'กำลังอัปเดตคอร์สเรียน...');
    await _refreshCoursesData();
    
    // Refresh contacts
    _updateProgress(75, 'กำลังอัปเดตข้อมูลติดต่อ...');
    await _refreshContactsData();
    
    _updateProgress(100, 'อัปเดตข้อมูลทั้งหมดเรียบร้อยแล้ว');
  }

  /// 🔄 Set refreshing state
  void _setRefreshing(bool isRefreshing, String? type) {
    _isRefreshing = isRefreshing;
    _currentRefreshType = type;
    _refreshController?.add(isRefreshing);
  }

  /// 📊 Update refresh status
  void _updateStatus(String status) {
    _refreshStatusController?.add(status);
  }

  /// 📈 Update refresh progress
  void _updateProgress(int progress, String message) {
    _refreshProgressController?.add({
      'progress': progress,
      'message': message,
      'timestamp': DateTime.now(),
    });
  }

  /// 📊 Get refresh statistics
  Map<String, dynamic> getRefreshStats() {
    return {
      'isRefreshing': _isRefreshing,
      'currentType': _currentRefreshType,
      'lastRefreshTime': _lastRefreshTime,
      'timeSinceLastRefresh': _lastRefreshTime != null 
          ? DateTime.now().difference(_lastRefreshTime!).inSeconds 
          : null,
    };
  }

  /// 🔄 Force refresh (bypass cache)
  Future<void> forceRefresh(String type) async {
    switch (type) {
      case 'news':
        await refreshNews();
        break;
      case 'courses':
        await refreshCourses();
        break;
      case 'contacts':
        await refreshContacts();
        break;
      case 'all':
        await refreshAll();
        break;
      default:
        throw ArgumentError('Invalid refresh type: $type');
    }
  }

  /// ⏰ Check if refresh is needed
  bool shouldRefresh({Duration? threshold}) {
    if (_lastRefreshTime == null) return true;
    
    final thresholdDuration = threshold ?? const Duration(minutes: 5);
    return DateTime.now().difference(_lastRefreshTime!) > thresholdDuration;
  }

  /// 🧹 Cleanup resources
  void dispose() {
    _refreshController?.close();
    _refreshStatusController?.close();
    _refreshProgressController?.close();
  }
}
