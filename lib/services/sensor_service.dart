import 'dart:async';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'history_service.dart';
import 'notification_service.dart';
import 'settings_service.dart';
import 'package:firebase_core/firebase_core.dart';

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

  StreamSubscription<DatabaseEvent>? _firebaseSubscription;

  final DatabaseReference _sensorRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
    'https://smartwindow-131e5-default-rtdb.asia-southeast1.firebasedatabase.app',
  ).ref(
    'devices/esp32_01/sensors',
  );

  bool _lastRain = false;
  bool _lastSmoke = false;

  void startFirebaseSensors() {
    print('START FIREBASE SENSOR LISTENER');

    _firebaseSubscription?.cancel();

    _firebaseSubscription = _sensorRef.onValue.listen(
          (DatabaseEvent event) {
        final data = event.snapshot.value;

        if (data == null || data is! Map) {
          print('Firebase sensor data is empty.');
          return;
        }

        try {
          // =========================
          // ROOM 1 - DHT22
          // =========================

          final room1 = data['room1'];

          if (room1 is Map) {
            final tempValue = room1['temperature'];
            final humidityValue = room1['humidity'];

            if (tempValue is num) {
              temperature = tempValue.toDouble();
            }

            if (humidityValue is num) {
              humidity = humidityValue.toDouble();
            }
          }

          // =========================
          // RAIN SENSOR
          // =========================

          final rainData = data['rain'];

          if (rainData is Map) {
            final rainValue = rainData['detected'];

            if (rainValue is bool) {
              rain = rainValue;
            }
          }

          // =========================
          // AUTO WINDOW CONTROL
          // =========================

          if (autoMode) {
            if (rain || smoke) {
              windowOpen = false;
              windowOpening = 0;
            } else {
              windowOpen = true;
              windowOpening = 100;
            }
          }

          // =========================
          // HISTORY
          // =========================

          HistoryService.instance.addData(
            temperature,
            humidity,
          );

          // =========================
          // RAIN NOTIFICATION
          // =========================

          if (SettingsService.instance.notifications) {
            if (rain && !_lastRain) {
              NotificationService.instance.addNotification(
                title: 'Rain Detected',
                message: autoMode
                    ? 'Window closed automatically.'
                    : 'Rain detected. Auto Mode is OFF.',
              );
            }
          }

          _lastRain = rain;

          print(
            'Firebase Sensor -> '
                'Temp: $temperature°C, '
                'Humidity: $humidity%, '
                'Rain: $rain',
          );

          // Update existing UI
          controller.add(null);
        } catch (e) {
          print('Firebase sensor error: $e');
        }
      },
      onError: (error) {
        print('Firebase database listener error: $error');
      },
    );
  }

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
    _firebaseSubscription?.cancel();
    controller.close();
  }
}