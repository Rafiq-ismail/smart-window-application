import 'package:flutter/material.dart';

import '../models/notification_model.dart';

class NotificationService extends ChangeNotifier {

  static final NotificationService instance =
      NotificationService._();

  NotificationService._();

  final List<NotificationModel> notifications = [];

  void addNotification({
    required String title,
    required String message,
  }) {

    notifications.insert(

      0,

      NotificationModel(
        title: title,
        message: message,
        time: DateTime.now(),
      ),

    );

    notifyListeners();

  }

  // Clear all notifications
  void clearNotifications() {

    notifications.clear();

    notifyListeners();

  }

}