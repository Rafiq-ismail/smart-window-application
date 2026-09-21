import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static final SettingsService instance = SettingsService._();

  SettingsService._();

  static const _notificationKey = "notifications";
  static const _autoModeKey = "auto_mode";
  static const _darkModeKey = "dark_mode";

  bool notifications = true;
  bool autoMode = true;
  bool darkMode = false;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    notifications =
        prefs.getBool(_notificationKey) ?? true;

    autoMode =
        prefs.getBool(_autoModeKey) ?? true;

    darkMode =
        prefs.getBool(_darkModeKey) ?? false;
  }

  Future<void> setNotifications(bool value) async {
    notifications = value;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationKey, value);
  }

  Future<void> setAutoMode(bool value) async {
    autoMode = value;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoModeKey, value);
  }

  Future<void> setDarkMode(bool value) async {
    darkMode = value;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }
}