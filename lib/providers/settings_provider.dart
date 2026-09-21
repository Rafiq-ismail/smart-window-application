import 'package:flutter/material.dart';

import '../services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  bool notifications = true;
  bool autoMode = true;
  bool darkMode = false;

  Future<void> load() async {
    await SettingsService.instance.loadSettings();

    notifications = SettingsService.instance.notifications;
    autoMode = SettingsService.instance.autoMode;
    darkMode = SettingsService.instance.darkMode;

    notifyListeners();
  }

  Future<void> setNotifications(bool value) async {
    notifications = value;

    await SettingsService.instance.setNotifications(value);

    notifyListeners();
  }

  Future<void> setAutoMode(bool value) async {
    autoMode = value;

    await SettingsService.instance.setAutoMode(value);

    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    darkMode = value;

    await SettingsService.instance.setDarkMode(value);

    notifyListeners();
  }
}