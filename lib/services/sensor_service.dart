import 'dart:async';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'history_service.dart';
import 'notification_service.dart';
import 'settings_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'esp32_control_service.dart';
import 'window_service.dart';
import 'emergency_service.dart';

class SensorService {
  static final SensorService instance = SensorService._();

  SensorService._();

  final Random random = Random();

// ROOM 1 - Living Room
  double temperature = 28;
  double humidity = 65;

// ROOM 2 - Bedroom
  double room2Temperature = 28;
  double room2Humidity = 65;

// ROOM 3 - Kitchen
  double room3Temperature = 28;
  double room3Humidity = 65;

  bool rain = false;
  bool smoke = false;

  bool _lastRainForFirestoreSync = false;

  bool windowOpen = true;
  double windowOpening = 100;

  bool autoMode = true;

  final StreamController<void> controller =
  StreamController<void>.broadcast();

  Future<void> syncAutoModeFromEsp32() async {
    print('SYNC AUTO MODE -> Reading ESP32 status...');

    final bool? esp32AutoMode =
    await Esp32ControlService.instance.getAutoModeStatus();

    if (esp32AutoMode == null) {
      print(
        'SYNC AUTO MODE FAILED -> Keeping current state: '
            '${autoMode ? "ON" : "OFF"}',
      );
      return;
    }

    autoMode = esp32AutoMode;

    print(
      'SYNC AUTO MODE SUCCESS -> ${autoMode ? "ON" : "OFF"}',
    );

    controller.add(null);
  }

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
            final smokeValue = room1['smokeDetected'];

            if (tempValue is num) {
              temperature = tempValue.toDouble();
            }

            if (humidityValue is num) {
              humidity = humidityValue.toDouble();
            }

            if (smokeValue is bool) {
              smoke = smokeValue;
            }
          }

          // =========================
// ROOM 2 - DHT22
// =========================

          final room2 = data['room2'];

          if (room2 is Map) {
            final tempValue = room2['temperature'];
            final humidityValue = room2['humidity'];

            if (tempValue is num) {
              room2Temperature = tempValue.toDouble();
            }

            if (humidityValue is num) {
              room2Humidity = humidityValue.toDouble();
            }
          }

// =========================
// ROOM 3 - DHT22
// =========================

          final room3 = data['room3'];

          if (room3 is Map) {
            final tempValue = room3['temperature'];
            final humidityValue = room3['humidity'];

            if (tempValue is num) {
              room3Temperature = tempValue.toDouble();
            }

            if (humidityValue is num) {
              room3Humidity = humidityValue.toDouble();
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

          // ============================================================
// RAIN AUTO-CLOSE -> FIRESTORE SYNC
// ============================================================

          if (rain &&
              !_lastRainForFirestoreSync &&
              autoMode) {
            print(
              'RAIN EDGE -> Syncing closed windows to Firestore',
            );

            WindowService.instance
                .syncAutoClosedWindows();
          }

          _lastRainForFirestoreSync = rain;

          // ============================================================
// SMOKE AUTO-CLOSE -> FIRESTORE SYNC
// ============================================================

// MQ Room 1 controls Window 1 only.
// ESP32 already closes the physical actuator.
// Flutter only synchronizes the result to Firestore.
          if (smoke && !_lastSmoke && autoMode) {
            print(
              'SMOKE EDGE -> Syncing Window 1 closed to Firestore',
            );

            WindowService.instance.syncSmokeClosedWindow1();
          }

          // ============================================================
// SMOKE -> EMERGENCY
// ============================================================

// Smoke detected: create one active emergency.
          if (smoke && !_lastSmoke) {
            print(
              'SMOKE EDGE -> Creating emergency',
            );

            EmergencyService.instance.createSmokeEmergency();
          }

// Smoke returned to normal: resolve active smoke emergency.
          if (!smoke && _lastSmoke) {
            print(
              'SMOKE SAFE -> Resolving emergency',
            );

            EmergencyService.instance.resolveActiveSmokeEmergency();
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
// SENSOR NOTIFICATIONS
// =========================

          if (SettingsService.instance.notifications) {
            // Rain notification
            if (rain && !_lastRain) {
              NotificationService.instance.addNotification(
                title: 'Rain Detected',
                message: autoMode
                    ? 'Window closed automatically.'
                    : 'Rain detected. Auto Mode is OFF.',
              );
            }

            // Smoke / gas notification
            if (smoke && !_lastSmoke) {
              NotificationService.instance.addNotification(
                title: 'Smoke Alert',
                message: autoMode
                    ? 'Smoke or gas detected in Room 1.'
                    : 'Smoke or gas detected in Room 1. Auto Mode is OFF.',
              );
            }
          }

          _lastRain = rain;
          _lastSmoke = smoke;

          print(
            'Firebase Sensor -> '
                'Temp: $temperature°C, '
                'Humidity: $humidity%, '
                'Rain: $rain, '
                'Smoke: $smoke',
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


  Future<void> setAutoMode(bool value) async {
    bool success;

    if (value) {
      success =
      await Esp32ControlService.instance.enableAutoMode();
    } else {
      success =
      await Esp32ControlService.instance.disableAutoMode();
    }

    if (!success) {
      print(
        'AUTO MODE ERROR -> ESP32 did not respond',
      );
      return;
    }

    autoMode = value;

    print(
      'AUTO MODE -> ${autoMode ? "ON" : "OFF"}',
    );

    controller.add(null);
  }

  void dispose() {
    _timer?.cancel();
    _firebaseSubscription?.cancel();
    controller.close();
  }
}