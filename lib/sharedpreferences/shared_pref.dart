import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  static const keyBaseUrl = 'baseUrl';
  static const keyDatabase = 'database';
  static const keyUsername = 'username';
  static const keySessionJson = 'session';
  static const keyUserLogin = 'userLogin';
  static const savedBaseUrl = 'savedBaseUrl';

  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  /// setting and getting

  Future setSavedBaseUrl(List<String> url) async {
    final p = await _prefs;
    await p.setStringList(savedBaseUrl, url);
  }

  Future<List<String>?> getSavedBaseUrl() async {
    final p = await _prefs;
    return p.getStringList(savedBaseUrl);
  }

  Future<void> setBaseUrl(String url) async {
    final p = await _prefs;
    await p.setString(keyBaseUrl, url);
  }

  Future<String?> getBaseUrl() async {
    final p = await _prefs;
    return p.getString(keyBaseUrl);
  }

  Future<void> setDatabase(String db) async {
    final p = await _prefs;
    await p.setString(keyDatabase, db);
  }

  Future<String?> getDatabase() async {
    final p = await _prefs;
    return p.getString(keyDatabase);
  }

  Future<void> setUsername(String username) async {
    final p = await _prefs;
    await p.setString(keyUsername, username);
  }

  Future<String?> getUsername() async {
    final p = await _prefs;
    return p.getString(keyUsername);
  }

  Future<void> setSessionJson(String json) async {
    final p = await _prefs;
    await p.setString(keySessionJson, json);
  }

  ///get session
  Future<String?> getSessionJson() async {
    final p = await _prefs;
    return p.getString(keySessionJson);
  }

  ///clear session

  Future<void> clearSessionJson() async {
    final p = await _prefs;
    await p.remove(keySessionJson);
  }

  ///set logged in

  Future<void> setLoggedIn(bool value) async {
    final p = await _prefs;
    await p.setBool(keyUserLogin, value);
  }

  ///check logged in
  Future<bool> isLoggedIn() async {
    final p = await _prefs;
    return p.getBool(keyUserLogin) ?? false;
  }

  ///clear all
  Future<void> clearAll() async {
    final p = await _prefs;
    setLoggedIn(false);
    p.remove(keySessionJson);
    p.remove(keyDatabase);

    p.remove(keyUsername);
    p.remove(keyBaseUrl);
  }
}
