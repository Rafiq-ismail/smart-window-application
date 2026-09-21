import 'dart:async';
import 'dart:math';

import 'history_service.dart';
import 'notification_service.dart';
import 'settings_service.dart';

class SensorService {
  static final SensorService instance = SensorService._();

  SensorService._();

  final Random random = Random();

  double temperature = 28;
  double humidity = 65;

  bool rain = false;
  bool smoke = false;

  bool windowOpen = true;
  double windowOpening = 100;

  bool autoMode = true;

  final StreamController<void> controller =
  StreamController<void>.broadcast();

  Stream<void> get stream => controller.stream;

  Timer? _timer;

  bool _lastRain = false;
  bool _lastSmoke = false;

  void startSimulation() {

    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 2),
          (timer) {

        // SIMULATE SENSOR VALUES


        temperature = 25 + random.nextDouble() * 8;

        humidity = 55 + random.nextDouble() * 30;

        rain = random.nextInt(4) == 0;

        smoke = random.nextInt(10) == 0;


        // AUTO WINDOW CONTROL


        if (autoMode) {
          if (rain || smoke) {
            // Dangerous condition
            windowOpen = false;
            windowOpening = 0;
          } else {
            // Safe condition
            windowOpen = true;
            windowOpening = 100;
          }
        }


        // SAVE HISTORY


        HistoryService.instance.addData(
          temperature,
          humidity,
        );


        // NOTIFICATIONS


        if (SettingsService.instance.notifications) {
          // Rain notification
          if (rain && !_lastRain) {
            NotificationService.instance.addNotification(
              title: "Rain Detected",
              message: autoMode
                  ? "Window closed automatically."
                  : "Rain detected. Auto Mode is OFF.",
            );
          }

          // Smoke notification
          if (smoke && !_lastSmoke) {
            NotificationService.instance.addNotification(
              title: "Smoke Alert",
              message: autoMode
                  ? "Window closed automatically."
                  : "Smoke detected. Auto Mode is OFF.",
            );
          }
        }


        // SAVE PREVIOUS SENSOR STATES


        _lastRain = rain;
        _lastSmoke = smoke;


        // UPDATE UI


        controller.add(null);
      },
    );
  }


  // MANUAL OPEN


  void openWindow() {
    windowOpen = true;
    windowOpening = 100;

    controller.add(null);
  }


  // MANUAL CLOSE


  void closeWindow() {
    windowOpen = false;
    windowOpening = 0;

    controller.add(null);
  }


  // WINDOW PERCENTAGE


  void setWindowOpening(double value) {
    windowOpening = value.clamp(0, 100);

    windowOpen = windowOpening > 0;

    controller.add(null);
  }


  // AUTO MODE


  void setAutoMode(bool value) {
    autoMode = value;

    // Immediately apply the current sensor condition
    if (autoMode) {
      if (rain || smoke) {
        windowOpen = false;
        windowOpening = 0;
      } else {
        windowOpen = true;
        windowOpening = 100;
      }
    }

    controller.add(null);
  }

  void dispose() {
    _timer?.cancel();
    controller.close();
  }
}