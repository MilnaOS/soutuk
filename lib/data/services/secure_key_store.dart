import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureKeyStore {
  static const _openAiKeyName = 'openai_api_key';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// A locked/unavailable OS keyring (e.g. no keyring daemon on a headless
  /// Linux session) throws a PlatformException rather than just returning
  /// null. Treat that the same as "no key stored" so callers can fall
  /// through to their next key source (env var, .env file) instead of
  /// crashing.
  Future<String?> getOpenAiKey() async {
    try {
      return await _storage.read(key: _openAiKeyName);
    } catch (e) {
      debugPrint('[SecureKeyStore] read failed, treating as no stored key: $e');
      return null;
    }
  }

  Future<void> setOpenAiKey(String key) => _storage.write(key: _openAiKeyName, value: key);

  Future<void> clearOpenAiKey() => _storage.delete(key: _openAiKeyName);
}
