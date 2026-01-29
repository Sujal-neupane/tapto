import 'package:shared_preferences/shared_preferences.dart';

class TokenStorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';

  final SharedPreferences _prefs;

  TokenStorageService(this._prefs);

  /// Save authentication token
  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  /// Get saved token
  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  /// Check if token exists
  bool hasToken() {
    return _prefs.containsKey(_tokenKey);
  }

  /// Save user ID
  Future<void> saveUserId(String userId) async {
    await _prefs.setString(_userIdKey, userId);
  }

  /// Get saved user ID
  String? getUserId() {
    return _prefs.getString(_userIdKey);
  }

  /// Clear all auth data
  Future<void> clearAuthData() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userIdKey);
  }

  /// Clear only token (keep user ID for re-login)
  Future<void> clearToken() async {
    await _prefs.remove(_tokenKey);
  }
}