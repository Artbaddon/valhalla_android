import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// StorageService
/// - Wraps `SharedPreferences` for non-sensitive values
/// - Wraps `FlutterSecureStorage` for sensitive values (like tokens)
class StorageService {
  StorageService._internal();
  static StorageService? _instance;
  static StorageService get instance =>
      _instance ??= StorageService._internal();

  SharedPreferences? _prefs;
  FlutterSecureStorage? _secure;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _secure = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
    if (kDebugMode) debugPrint('StorageService initialized');
  }

  // SharedPreferences (non-sensitive)
  Future<bool> setString(String key, String value) async {
    return await _prefs!.setString(key, value);
  }

  Future<String?> getString(String key) async {
    return _prefs!.getString(key);
  }

  Future<bool> remove(String key) async {
    return await _prefs!.remove(key);
  }

  // JSON helpers
  Future<bool> setObject(String key, Map<String, dynamic> json) async {
    return await _prefs!.setString(key, _encode(json));
  }

  Map<String, dynamic>? getObject(String key) {
    final raw = _prefs!.getString(key);
    if (raw == null) return null;
    return _decode(raw);
  }

  // Secure storage (sensitive)
  Future<void> setSecure(String key, String value) async {
    await _secure!.write(key: key, value: value);
  }

  Future<String?> getSecure(String key) async {
    return _secure!.read(key: key);
  }

  Future<void> removeSecure(String key) async {
    await _secure!.delete(key: key);
  }

  // Internal helpers
  String _encode(Map<String, dynamic> json) =>
      const JsonEncoder().convert(json);
  Map<String, dynamic> _decode(String raw) =>
      const JsonDecoder().convert(raw) as Map<String, dynamic>;
}
