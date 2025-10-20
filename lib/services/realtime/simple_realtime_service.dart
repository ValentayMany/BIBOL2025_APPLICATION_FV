import 'dart:async';
import 'dart:convert';
import 'package:BIBOL/models/news/news_models.dart';
import 'package:http/http.dart' as http;
import 'package:BIBOL/config/bibol_api.dart';
import 'package:BIBOL/models/website/contact_model.dart';
import 'package:BIBOL/services/website/contact_service.dart';
import 'package:BIBOL/services/error/error_handler_service.dart';

/// 🔄 Simple Real-time Service (Smart Polling)
///
/// Features:
/// - Easy to use
/// - No complex dependencies
/// - Works with existing API
/// - Automatic polling
class SimpleRealtimeService {
  static SimpleRealtimeService? _instance;
  static SimpleRealtimeService get instance =>
      _instance ??= SimpleRealtimeService._();

  SimpleRealtimeService._();

  Timer? _timer;
  bool _isRunning = false;

  // Controllers
  StreamController<List<NewsModel>>? _newsController;
  StreamController<List<ContactModel>>? _contactsController;
  StreamController<String>? _statusController;
  StreamController<bool>? _loadingController;
  StreamController<AppError?>? _errorController;

  // Data tracking
  String _lastNewsHash = '';
  String _lastContactHash = '';

  // Configuration
  Duration _pollingInterval = const Duration(seconds: 30);

  // Getters
  Stream<List<NewsModel>>? get newsStream => _newsController?.stream;
  Stream<List<ContactModel>>? get contactsStream => _contactsController?.stream;
  Stream<String>? get statusStream => _statusController?.stream;
  Stream<bool>? get loadingStream => _loadingController?.stream;
  Stream<AppError?>? get errorStream => _errorController?.stream;
  bool get isRunning => _isRunning;

  /// 🚀 Start real-time polling
  void startPolling() {
    if (_isRunning) return;

    _isRunning = true;
    _newsController ??= StreamController<List<NewsModel>>.broadcast();
    _contactsController ??= StreamController<List<ContactModel>>.broadcast();
    _statusController ??= StreamController<String>.broadcast();
    _loadingController ??= StreamController<bool>.broadcast();
    _errorController ??= StreamController<AppError?>.broadcast();

    _updateStatus('Starting real-time polling...');
    _scheduleNextPoll();

    print('🔄 Simple Real-time Service started');
  }

  /// ⏹️ Stop polling
  void stopPolling() {
    if (!_isRunning) return;

    _timer?.cancel();
    _isRunning = false;
    _updateStatus('Stopped');

    print('⏹️ Simple Real-time Service stopped');
  }

  /// 🔄 Schedule next poll
  void _scheduleNextPoll() {
    if (!_isRunning) return;

    _timer?.cancel();
    _timer = Timer(_pollingInterval, _performPoll);
  }

  /// 📡 Perform polling
  Future<void> _performPoll() async {
    if (!_isRunning) return;

    try {
      _setLoading(true);
      _clearError();
      _updateStatus('Checking for updates...');

      // Poll news and contacts with error handling
      final newsChanged = await ErrorHandlerService.executeWithRetry(
        () => _checkNewsUpdates(),
        operationName: 'News Polling',
        maxRetries: 2,
      );

      final contactsChanged = await ErrorHandlerService.executeWithRetry(
        () => _checkContactsUpdates(),
        operationName: 'Contacts Polling',
        maxRetries: 2,
      );

      if (newsChanged || contactsChanged) {
        _updateStatus('Updates found!');
        print('✅ Real-time updates detected');
      } else {
        _updateStatus('No updates');
        print('📊 No updates found');
      }
    } on AppError catch (error) {
      _handleError(error);
      _updateStatus('Error occurred');
    } catch (e) {
      final appError = AppError(
        type: ErrorHandlerService.unknownError,
        message: 'Unexpected error during polling',
        originalException: e,
        operationName: 'Real-time Polling',
      );
      _handleError(appError);
    } finally {
      _setLoading(false);
    }

    _scheduleNextPoll();
  }

  /// 📰 Check for news updates
  Future<bool> _checkNewsUpdates() async {
    final response = await http.get(
      Uri.parse(NewsApiConfig.getNewsUrl()),
      headers: {'Content-Type': 'application/json'},
    );

    // Handle HTTP response errors
    ErrorHandlerService.handleHttpResponse(response, operationName: 'News API');

    final jsonData = json.decode(response.body);
    final currentHash = json.encode(jsonData).hashCode.toString();

    if (currentHash != _lastNewsHash) {
      _lastNewsHash = currentHash;

      // Parse and emit news data
      if (jsonData is Map && jsonData['data'] is List) {
        final newsList = (jsonData['data'] as List)
            .map((item) => NewsModel.fromJson(item))
            .toList();
        _newsController?.add(newsList);
        print('📰 News updated: ${newsList.length} items');
        return true;
      }
    }

    return false;
  }

  /// 📞 Check for contacts updates
  Future<bool> _checkContactsUpdates() async {
    final contacts = await ContactService.getContacts();
    final currentHash = contacts.map((c) => c.toJson()).toString().hashCode.toString();

    if (currentHash != _lastContactHash) {
      _lastContactHash = currentHash;
      _contactsController?.add(contacts);
      print('📞 Contacts updated: ${contacts.length} items');
      return true;
    }

    return false;
  }

  /// 📊 Update status
  void _updateStatus(String status) {
    _statusController?.add(status);
  }

  /// 🔄 Set loading state
  void _setLoading(bool isLoading) {
    _loadingController?.add(isLoading);
  }

  /// 🚨 Handle error
  void _handleError(AppError error) {
    ErrorHandlerService.logError(error);
    _errorController?.add(error);
    print('❌ Real-time service error: ${error.message}');
  }

  /// ✅ Clear error
  void _clearError() {
    _errorController?.add(null);
  }

  /// 🎛️ Configure polling interval
  void setPollingInterval(Duration interval) {
    _pollingInterval = interval;
    print('🎛️ Polling interval set to: ${interval.inSeconds}s');
  }

  /// 📊 Get service status
  Map<String, dynamic> getStatus() {
    return {
      'isRunning': _isRunning,
      'interval': _pollingInterval.inSeconds,
      'lastNewsHash': _lastNewsHash.isNotEmpty ? '***' : '',
      'lastContactHash': _lastContactHash.isNotEmpty ? '***' : '',
    };
  }

  /// 🧹 Cleanup resources
  void dispose() {
    stopPolling();
    _newsController?.close();
    _contactsController?.close();
    _statusController?.close();
    _loadingController?.close();
    _errorController?.close();
  }
}
