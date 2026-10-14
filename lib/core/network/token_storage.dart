import 'package:shared_preferences/shared_preferences.dart';

/// Persistent Token & Session Storage using SharedPreferences
class TokenStorage {
  static const String _keyAuthToken = 'auth_token';
  static const String _keyRefreshToken = 'refresh_token';

  // In-memory cache for ultra-fast synchronous lookup
  static String? _cachedToken;

  /// Singleton instance
  static final TokenStorage instance = TokenStorage._internal();
  TokenStorage._internal();

  /// Initialize and preload cached token into memory on app startup
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString(_keyAuthToken);
  }

  /// Save access token in SharedPreferences and memory cache
  Future<void> saveToken(String token) async {
    _cachedToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAuthToken, token);
  }

  /// Get current access token
  Future<String?> getToken() async {
    if (_cachedToken != null && _cachedToken!.isNotEmpty) {
      return _cachedToken;
    }
    final prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString(_keyAuthToken);
    return _cachedToken;
  }

  /// Synchronously get cached token if available
  String? get cachedToken => _cachedToken;

  /// Clear token from storage (on logout or 401 session expiry)
  Future<void> clearToken() async {
    _cachedToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAuthToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyUser);
  }

  /// Check whether an auth token currently exists
  static const String _keyUser = 'cached_user_json';

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Optional: Save refresh token
  Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRefreshToken, token);
  }

  /// Optional: Get refresh token
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRefreshToken);
  }

  /// Save cached user data as JSON string
  Future<void> saveUser(String userJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, userJson);
  }

  /// Get cached user data
  Future<String?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUser);
  }
}
