import 'package:shared_preferences/shared_preferences.dart';

String PREFS_TOKEN = 'token';

class SharedPrefs {
  static Future<SharedPreferences> _prefs;

  static init() {
    _prefs = SharedPreferences.getInstance();
  }

  // Returns null if not set.
  static Future<String> getToken() async {
    SharedPreferences prefs = await _prefs;
    String token = prefs.getString(PREFS_TOKEN);
    return token;
  }

  static Future<bool> setToken(String token) async {
    SharedPreferences prefs = await _prefs;
    prefs.setString(PREFS_TOKEN, token);
    return true;
  }

  static Future<bool> removeToken() async {
    SharedPreferences prefs = await _prefs;
    return prefs.remove(PREFS_TOKEN);
  }
}
