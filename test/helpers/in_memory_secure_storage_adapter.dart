// test/helpers/in_memory_secure_storage_adapter.dart
import 'package:BIBOL/services/storage/secure_storage_adapter.dart';

class InMemorySecureStorageAdapter implements SecureStorageAdapter {
  final Map<String, String> _store = <String, String>{};

  @override
  Future<void> delete({required String key}) async {
    _store.remove(key);
  }

  @override
  Future<Map<String, String>> readAll() async {
    return Map<String, String>.from(_store);
  }

  @override
  Future<String?> read({required String key}) async {
    return _store[key];
  }

  @override
  Future<void> write({required String key, required String? value}) async {
    if (value == null) {
      _store.remove(key);
    } else {
      _store[key] = value;
    }
  }

  @override
  Future<void> deleteAll() async {
    _store.clear();
  }
}
