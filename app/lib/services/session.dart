// lib/services/session.dart
// Session + PIN persistence using shared_preferences.
// Stores a hashed PIN (sha256, never plaintext) + the current bearer token + user info.

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Session {
  static const _pinHashKey = 'pagali.pin.sha256';
  static const _tokenKey   = 'pagali.token';
  static const _userKey    = 'pagali.user';

  final SharedPreferences _p;
  Session(this._p);

  static Future<Session> load() async => Session(await SharedPreferences.getInstance());

  String _hash(String pin) => sha256.convert(utf8.encode('pagali::$pin')).toString();

  bool get hasPin => _p.containsKey(_pinHashKey);
  Future<void> setPin(String pin) => _p.setString(_pinHashKey, _hash(pin));
  bool verifyPin(String pin) => _p.getString(_pinHashKey) == _hash(pin);
  Future<void> clearPin() => _p.remove(_pinHashKey);

  String? get token => _p.getString(_tokenKey);
  Future<void> setToken(String? t) => t == null ? _p.remove(_tokenKey) : _p.setString(_tokenKey, t);

  Map<String, dynamic>? get user {
    final raw = _p.getString(_userKey);
    return raw == null ? null : jsonDecode(raw) as Map<String, dynamic>;
  }
  Future<void> setUser(Map<String, dynamic>? u) =>
    u == null ? _p.remove(_userKey) : _p.setString(_userKey, jsonEncode(u));

  Future<void> signOut() async {
    await _p.remove(_tokenKey);
    await _p.remove(_userKey);
  }
}
