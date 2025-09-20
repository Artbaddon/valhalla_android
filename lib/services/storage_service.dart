// lib/services/storage_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth/user_model.dart';
import 'dart:convert';

class StorageService {
  static const _secureStorage = FlutterSecureStorage();
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'jwt_token', value: token);
  }

  static Future<String?> getToken() async {
    return await _secureStorage.read(key: 'jwt_token');
  }

  static Future<void> deleteToken() async {
    await _secureStorage.delete(key: 'jwt_token');
  }

  // User data methods (less secure, but faster)
  static Future<void> saveUser(User user) async {
    await _prefs?.setString('user_data', jsonEncode(user.toJson()));
  }

  static Future<User?> getUser() async {
    final userJson = _prefs?.getString('user_data');
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  static Future<void> clearAll() async {
    await deleteToken();
    await _prefs?.clear();
  }
}