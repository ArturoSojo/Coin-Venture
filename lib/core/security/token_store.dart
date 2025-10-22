import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/domain/entities/session_token.dart';

abstract class TokenStore {
  static const instanceName = 'token_store';

  Future<void> save(SessionToken token);
  Future<SessionToken?> read();
  Future<void> clear();

  factory TokenStore.create() {
    if (kIsWeb) {
      return _WebTokenStore();
    }
    return _SecureTokenStore();
  }
}

class _SecureTokenStore implements TokenStore {
  _SecureTokenStore();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const _key = 'session_token';

  @override
  Future<void> clear() => _storage.delete(key: _key);

  @override
  Future<SessionToken?> read() async {
    final raw = await _storage.read(key: _key);
    if (raw == null) return null;
    return SessionToken.fromJson(raw);
  }

  @override
  Future<void> save(SessionToken token) async {
    await _storage.write(key: _key, value: token.toJson());
  }
}

class _WebTokenStore implements TokenStore {
  static const _key = 'session_token';

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  @override
  Future<SessionToken?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    return SessionToken.fromJson(raw);
  }

  @override
  Future<void> save(SessionToken token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, token.toJson());
  }
}
