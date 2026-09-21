import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class TopNotificationService {
  static void show({
    required BuildContext context,
    required String title,
    required String message,
    Color color = Colors.blue,
    IconData icon = Icons.notifications,
  }) {
    Flushbar(
      title: title,
      message: message,
      icon: Icon(
        icon,
        color: Colors.white,
      ),
      backgroundColor: color,
      flushbarPosition: FlushbarPosition.TOP,
      borderRadius: BorderRadius.circular(15),
      margin: const EdgeInsets.all(15),
      duration: const Duration(seconds: 3),
      animationDuration: const Duration(milliseconds: 500),
      boxShadows: const [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 10,
        ),
      ],
    ).show(context);
  }
}