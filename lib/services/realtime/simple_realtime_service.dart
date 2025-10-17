import 'dart:async';
import 'dart:convert';
import 'package:BIBOL/models/news/news_models.dart';
import 'package:http/http.dart' as http;
import 'package:BIBOL/config/bibol_api.dart';
import 'package:BIBOL/models/website/contact_model.dart';
import 'package:BIBOL/services/website/contact_service.dart';

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

  // Data tracking
  String _lastNewsHash = '';
  String _lastContactHash = '';

  // Configuration
  Duration _pollingInterval = const Duration(seconds: 30);

  // Getters
  Stream<List<NewsModel>>? get newsStream => _newsController?.stream;
  Stream<List<ContactModel>>? get contactsStream => _contactsController?.stream;
  Stream<String>? get statusStream => _statusController?.stream;
  bool get isRunning => _isRunning;

  /// 🚀 Start real-time polling
  void startPolling() {
    if (_isRunning) return;

    _isRunning = true;
    _newsController ??= StreamController<List<NewsModel>>.broadcast();
    _contactsController ??= StreamController<List<ContactModel>>.broadcast();
    _statusController ??= StreamController<String>.broadcast();

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
      _updateStatus('Checking for updates...');

      // Poll news and contacts
      final newsChanged = await _checkNewsUpdates();
      final contactsChanged = await _checkContactsUpdates();

      if (newsChanged || contactsChanged) {
        _updateStatus('Updates found!');
        print('✅ Real-time updates detected');
      } else {
        _updateStatus('No updates');
        print('📊 No updates found');
      }
    } catch (e) {
      _updateStatus('Error: $e');
      print('❌ Polling error: $e');
    }

    _scheduleNextPoll();
  }

  /// 📰 Check for news updates
  Future<bool> _checkNewsUpdates() async {
    try {
      final response = await http.get(
        Uri.parse(NewsApiConfig.getNewsUrl()),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final currentHash = json.encode(jsonData).hashCode.toString();

        if (currentHash != _lastNewsHash) {
          _lastNewsHash = currentHash;

          // Parse and emit news data
          if (jsonData is Map && jsonData['data'] is List) {
            final newsList =
                (jsonData['data'] as List)
                    .map((item) => NewsModel.fromJson(item))
                    .toList();
            _newsController?.add(newsList);
            print('📰 News updated: ${newsList.length} items');
            return true;
          }
        }
      }

      return false;
    } catch (e) {
      print('❌ News polling error: $e');
      return false;
    }
  }

  /// 📞 Check for contacts updates
  Future<bool> _checkContactsUpdates() async {
    try {
      final contacts = await ContactService.getContacts();
      final currentHash =
          contacts.map((c) => c.toJson()).toString().hashCode.toString();

      if (currentHash != _lastContactHash) {
        _lastContactHash = currentHash;
        _contactsController?.add(contacts);
        print('📞 Contacts updated: ${contacts.length} items');
        return true;
      }

      return false;
    } catch (e) {
      print('❌ Contacts polling error: $e');
      return false;
    }
  }

  /// 📊 Update status
  void _updateStatus(String status) {
    _statusController?.add(status);
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
  }
}
