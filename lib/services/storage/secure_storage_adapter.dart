// lib/services/storage/secure_storage_adapter.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Adapter interface so storage implementation can be injected (useful for tests)
abstract class SecureStorageAdapter {
  Future<void> write({required String key, required String? value});
  Future<String?> read({required String key});
  Future<void> delete({required String key});
  Future<Map<String, String>> readAll();
  Future<void> deleteAll();
}

/// Default implementation using flutter_secure_storage
class FlutterSecureStorageAdapter implements SecureStorageAdapter {
  final FlutterSecureStorage _impl = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  @override
  Future<void> write({required String key, required String? value}) async {
    if (value == null) {
      await _impl.delete(key: key);
    } else {
      await _impl.write(key: key, value: value);
    }
  }

  @override
  Future<String?> read({required String key}) async {
    return await _impl.read(key: key);
  }

  @override
  Future<void> delete({required String key}) async {
    await _impl.delete(key: key);
  }

  @override
  Future<Map<String, String>> readAll() async {
    return await _impl.readAll();
  }

  @override
  Future<void> deleteAll() async {
    await _impl.deleteAll();
  }
}
