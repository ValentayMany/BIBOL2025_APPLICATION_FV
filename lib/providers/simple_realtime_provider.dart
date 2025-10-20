import 'package:flutter/foundation.dart';
import 'package:BIBOL/services/realtime/simple_realtime_service.dart';
import 'package:BIBOL/services/error/error_handler_service.dart';

/// 🔄 Simple Real-time Provider
/// 
/// Easy to use real-time provider without complex dependencies
class SimpleRealtimeProvider extends ChangeNotifier {
  static SimpleRealtimeProvider? _instance;
  static SimpleRealtimeProvider get instance => _instance ??= SimpleRealtimeProvider._();
  
  SimpleRealtimeProvider._();

  final SimpleRealtimeService _service = SimpleRealtimeService.instance;

  // State
  bool _isInitialized = false;
  String _status = 'Disconnected';
  int _newsCount = 0;
  int _contactsCount = 0;
  bool _isLoading = false;
  AppError? _lastError;

  // Getters
  bool get isInitialized => _isInitialized;
  String get status => _status;
  int get newsCount => _newsCount;
  int get contactsCount => _contactsCount;
  bool get isLoading => _isLoading;
  AppError? get lastError => _lastError;

  /// 🚀 Initialize real-time service
  void initialize() {
    if (_isInitialized) return;

    _service.startPolling();
    
    // Listen to status updates
    _service.statusStream?.listen((status) {
      _status = status;
      notifyListeners();
    });

    // Listen to news updates
    _service.newsStream?.listen((news) {
      _newsCount = news.length;
      notifyListeners();
    });

    // Listen to contacts updates
    _service.contactsStream?.listen((contacts) {
      _contactsCount = contacts.length;
      notifyListeners();
    });

    // Listen to loading state
    _service.loadingStream?.listen((isLoading) {
      _isLoading = isLoading;
      notifyListeners();
    });

    // Listen to errors
    _service.errorStream?.listen((error) {
      _lastError = error;
      notifyListeners();
    });

    _isInitialized = true;
    _status = 'Connected';
    notifyListeners();
    
    print('🔄 Simple Real-time Provider initialized');
  }

  /// ⏹️ Stop real-time service
  void stop() {
    _service.stopPolling();
    _status = 'Disconnected';
    notifyListeners();
  }

  /// 🔄 Restart service
  void restart() {
    stop();
    _clearError();
    initialize();
  }

  /// ✅ Clear error
  void _clearError() {
    _lastError = null;
    notifyListeners();
  }

  /// 🚨 Clear last error
  void clearError() {
    _clearError();
  }

  /// 🎛️ Set polling interval
  void setPollingInterval(Duration interval) {
    _service.setPollingInterval(interval);
  }

  /// 📊 Get detailed status
  Map<String, dynamic> getDetailedStatus() {
    return {
      'isInitialized': _isInitialized,
      'status': _status,
      'newsCount': _newsCount,
      'contactsCount': _contactsCount,
      'isLoading': _isLoading,
      'hasError': _lastError != null,
      'lastError': _lastError?.toString(),
      'serviceStatus': _service.getStatus(),
    };
  }

  /// 🧹 Dispose provider
  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
