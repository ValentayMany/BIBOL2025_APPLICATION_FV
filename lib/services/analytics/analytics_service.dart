/// 📊 AnalyticsService - Service สำหรับติดตามพฤติกรรมผู้ใช้
/// 
/// Service นี้ใช้สำหรับ log events และติดตามการใช้งานแอป
/// 
/// **ฟีเจอร์หลัก:**
/// - Log page views
/// - Log user actions
/// - Track errors
/// - Custom events
/// 
/// **ตัวอย่างการใช้งาน:**
/// ```dart
/// // Log page view
/// AnalyticsService.logPageView('home');
/// 
/// // Log user action
/// AnalyticsService.logEvent('news_clicked', {
///   'news_id': '123',
///   'news_title': 'Breaking News',
/// });
/// 
/// // Log error
/// AnalyticsService.logError('api_error', error);
/// ```
class AnalyticsService {
  // Private constructor
  AnalyticsService._();

  // Singleton instance
  static final AnalyticsService _instance = AnalyticsService._();
  static AnalyticsService get instance => _instance;

  // Enable/disable analytics
  static bool _isEnabled = true;

  /// เปิด/ปิด analytics
  static void setEnabled(bool enabled) {
    _isEnabled = enabled;
    print('📊 Analytics ${enabled ? 'enabled' : 'disabled'}');
  }

  /// Log การเข้าชมหน้า
  /// 
  /// **Parameters:**
  /// - [pageName] - ชื่อหน้าที่เข้าชม
  /// - [parameters] - ข้อมูลเพิ่มเติม (optional)
  /// 
  /// **Example:**
  /// ```dart
  /// AnalyticsService.logPageView('home');
  /// AnalyticsService.logPageView('news_detail', {'news_id': '123'});
  /// ```
  static void logPageView(String pageName, [Map<String, dynamic>? parameters]) {
    if (!_isEnabled) return;

    final Map<String, dynamic> eventData = {
      'page_name': pageName,
      'timestamp': DateTime.now().toIso8601String(),
      ...?parameters,
    };

    print('📄 Page View: $pageName');
    print('   Data: $eventData');

    // TODO: ส่งไปยัง Firebase Analytics หรือ analytics service อื่นๆ
    // await FirebaseAnalytics.instance.logEvent(
    //   name: 'page_view',
    //   parameters: eventData,
    // );
  }

  /// Log event
  /// 
  /// **Parameters:**
  /// - [eventName] - ชื่อ event
  /// - [parameters] - ข้อมูล event
  /// 
  /// **Example:**
  /// ```dart
  /// AnalyticsService.logEvent('news_clicked', {
  ///   'news_id': '123',
  ///   'news_title': 'Breaking News',
  /// });
  /// ```
  static void logEvent(String eventName, [Map<String, dynamic>? parameters]) {
    if (!_isEnabled) return;

    final Map<String, dynamic> eventData = {
      'event_name': eventName,
      'timestamp': DateTime.now().toIso8601String(),
      ...?parameters,
    };

    print('🎯 Event: $eventName');
    print('   Data: $eventData');

    // TODO: ส่งไปยัง analytics service
    // await FirebaseAnalytics.instance.logEvent(
    //   name: eventName,
    //   parameters: eventData,
    // );
  }

  /// Log error
  /// 
  /// **Parameters:**
  /// - [errorType] - ประเภทของ error
  /// - [error] - object error
  /// - [stackTrace] - stack trace (optional)
  /// 
  /// **Example:**
  /// ```dart
  /// try {
  ///   // ... code
  /// } catch (e, stackTrace) {
  ///   AnalyticsService.logError('api_error', e, stackTrace);
  /// }
  /// ```
  static void logError(
    String errorType,
    dynamic error, [
    StackTrace? stackTrace,
  ]) {
    if (!_isEnabled) return;

    print('❌ Error: $errorType');
    print('   Message: $error');
    if (stackTrace != null) {
      print('   Stack: ${stackTrace.toString()}');
    }

    // TODO: ส่งไปยัง error tracking service
    // await FirebaseCrashlytics.instance.recordError(
    //   error,
    //   stackTrace,
    //   reason: errorType,
    // );
  }

  /// Log user login
  /// 
  /// **Parameters:**
  /// - [userId] - ID ของผู้ใช้
  /// - [method] - วิธีการ login (email, social, etc.)
  static void logLogin(String userId, {String method = 'email'}) {
    logEvent('login', {
      'user_id': userId,
      'method': method,
    });
  }

  /// Log user logout
  static void logLogout() {
    logEvent('logout');
  }

  /// Log search
  /// 
  /// **Parameters:**
  /// - [searchTerm] - คำค้นหา
  /// - [resultCount] - จำนวนผลลัพธ์
  static void logSearch(String searchTerm, {int? resultCount}) {
    logEvent('search', {
      'search_term': searchTerm,
      if (resultCount != null) 'result_count': resultCount,
    });
  }

  /// Log item view (ข่าว, หลักสูตร, etc.)
  /// 
  /// **Parameters:**
  /// - [itemType] - ประเภท (news, course, gallery)
  /// - [itemId] - ID ของรายการ
  /// - [itemName] - ชื่อรายการ
  static void logItemView(
    String itemType,
    String itemId,
    String itemName,
  ) {
    logEvent('item_view', {
      'item_type': itemType,
      'item_id': itemId,
      'item_name': itemName,
    });
  }

  /// Log share action
  /// 
  /// **Parameters:**
  /// - [contentType] - ประเภทเนื้อหา
  /// - [contentId] - ID เนื้อหา
  /// - [method] - วิธีการแชร์
  static void logShare(
    String contentType,
    String contentId,
    String method,
  ) {
    logEvent('share', {
      'content_type': contentType,
      'content_id': contentId,
      'method': method,
    });
  }
}
