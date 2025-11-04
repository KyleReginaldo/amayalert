import 'package:shared_preferences/shared_preferences.dart';

class AuthStorageService {
  static const String _emailKey = 'remember_email';
  static const String _passwordKey = 'remember_password';
  static const String _rememberMeKey = 'remember_me';

  final SharedPreferences _prefs;

  AuthStorageService(this._prefs);

  /// Save email and password when remember me is checked
  Future<void> saveCredentials({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    await _prefs.setBool(_rememberMeKey, rememberMe);

    if (rememberMe) {
      await _prefs.setString(_emailKey, email);
      await _prefs.setString(_passwordKey, password);
    } else {
      // Clear saved credentials if remember me is unchecked
      await clearCredentials();
    }
  }

  /// Get saved credentials if remember me was checked
  Future<Map<String, String?>> getSavedCredentials() async {
    final rememberMe = _prefs.getBool(_rememberMeKey) ?? false;

    if (rememberMe) {
      return {
        'email': _prefs.getString(_emailKey),
        'password': _prefs.getString(_passwordKey),
      };
    }

    return {'email': null, 'password': null};
  }

  /// Check if remember me was previously selected
  bool isRememberMeEnabled() {
    return _prefs.getBool(_rememberMeKey) ?? false;
  }

  /// Clear all saved credentials
  Future<void> clearCredentials() async {
    await _prefs.remove(_emailKey);
    await _prefs.remove(_passwordKey);
    await _prefs.remove(_rememberMeKey);
  }
}
