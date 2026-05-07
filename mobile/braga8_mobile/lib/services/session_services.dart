import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const _keyToken = 'session_token';
  static const _keyRole = 'session_role';
  static const _keyName = 'session_name';

  // Save after login
  static Future<void> saveSession({
    required String token,
    required String role,
    required String name,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyRole, role);
    await prefs.setString(_keyName, name);
  }

  // Load on splash
  static Future<Map<String, String>?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keyToken);
    final role = prefs.getString(_keyRole);
    final name = prefs.getString(_keyName);
    if (token == null || role == null) return null;
    return {'token': token, 'role': role, 'name': name ?? ''};
  }

  // Call on logout
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}