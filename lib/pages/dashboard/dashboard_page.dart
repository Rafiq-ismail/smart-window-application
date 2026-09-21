import 'package:flutter/material.dart';

import '../notification/notification_page.dart';

import '../../services/sensor_service.dart';

import 'widgets/dashboard_header.dart';
import 'widgets/dashboard_summary_card.dart';

import '../control/control_page.dart';
import 'widgets/weather_card.dart';
import '../../services/settings_service.dart';

import 'widgets/energy_card.dart';
import '../../core/app_colors.dart';
import 'widgets/room_status_card.dart';
import 'widgets/sensor_card.dart';
import 'widgets/quick_action_card.dart';
import 'widgets/statistics_card.dart';
import 'widgets/activity_card.dart';
import '../../services/top_notification_service.dart';
import '../../services/emergency_service.dart';
import 'dart:async';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {

  bool _lastRain = false;
  bool _lastSmoke = false;
  bool _lastWindow = true;

  bool _lastEmergencySmoke = false;

  StreamSubscription<void>? _emergencySensorSubscription;

  @override
  void initState() {
    super.initState();

    final sensor = SensorService.instance;

    _lastEmergencySmoke = sensor.smoke;

    _emergencySensorSubscription =
        sensor.stream.listen((_) async {

          final currentSmoke =
              SensorService.instance.smoke;

          if (currentSmoke &&
              !_lastEmergencySmoke) {

            await EmergencyService.instance
                .createSmokeEmergency();
          }

          if (!currentSmoke &&
              _lastEmergencySmoke) {

            await EmergencyService.instance
                .resolveActiveSmokeEmergency();
          }

          _lastEmergencySmoke = currentSmoke;
        });
  }

  @override
  void dispose() {
    _emergencySensorSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Window"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationsPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DashboardHeader(),

            const SizedBox(height: 20),

            const DashboardSummaryCard(),

            const SizedBox(height: 20),

            const WeatherCard(),

            const SizedBox(height: 20),

            StreamBuilder(
              stream: SensorService.instance.stream,
              builder: (context, snapshot) {
                final sensor = SensorService.instance;

// Rain Notification
                if (SettingsService.instance.notifications &&
                    sensor.rain &&
                    !_lastRain) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    TopNotificationService.show(
                      context: context,
                      title: "Rain Detected",
                      message: "Window closed automatically.",
                      color: Colors.orange,
                      icon: Icons.cloud,
                    );
                  });
                }

// Smoke Notification
                if (SettingsService.instance.notifications &&
                    sensor.smoke &&
                    !_lastSmoke) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    TopNotificationService.show(
                      context: context,
                      title: "Smoke Alert",
                      message: "Smoke detected inside room.",
                      color: Colors.red,
                      icon: Icons.local_fire_department,
                    );
                  });
                }

// Window Notification
                if (SettingsService.instance.notifications &&
                    sensor.windowOpen != _lastWindow) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    TopNotificationService.show(
                      context: context,
                      title: sensor.windowOpen
                          ? "Window Opened"
                          : "Window Closed",
                      message: sensor.windowOpen
                          ? "Window opened successfully."
                          : "Window closed successfully.",
                      color: sensor.windowOpen
                          ? Colors.green
                          : Colors.red,
                      icon: sensor.windowOpen
                          ? Icons.window
                          : Icons.window_outlined,
                    );
                  });
                }

                _lastRain = sensor.rain;
                _lastSmoke = sensor.smoke;
                _lastWindow = sensor.windowOpen;

                return Column(
                  children: [

                  ],
                );
              },
            ),

            const EnergyCard(),

            const SizedBox(height: 30),

            const Text(
              "Rooms",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            RoomStatusCard(
              roomName: "Living Room",
              icon: Icons.weekend_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ControlPage(
                      roomName: "Living Room",
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 15),

            RoomStatusCard(
              roomName: "Bedroom",
              icon: Icons.bedroom_parent_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ControlPage(
                      roomName: "Bedroom",
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 15),

            RoomStatusCard(
              roomName: "Kitchen",
              icon: Icons.kitchen_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ControlPage(
                      roomName: "Kitchen",
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            const Text(
              "Sensor Status",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            StreamBuilder(
              stream: SensorService.instance.stream,
              builder: (context, snapshot) {
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.25,
                  children: [
                    SensorCard(
                      title: "Temperature",
                      value:
                      "${SensorService.instance.temperature.toStringAsFixed(0)}°C",
                      icon: Icons.thermostat,
                      color: AppColors.temperature,
                    ),

                    SensorCard(
                      title: "Humidity",
                      value:
                      "${SensorService.instance.humidity.toStringAsFixed(0)}%",
                      icon: Icons.water_drop,
                      color: AppColors.humidity,
                    ),

                    SensorCard(
                      title: "Rain",
                      value: SensorService.instance.rain
                          ? "Detected"
                          : "Safe",
                      icon: Icons.cloud,
                      color: SensorService.instance.rain
                          ? AppColors.warning
                          : AppColors.success,
                    ),

                    SensorCard(
                      title: "Smoke",
                      value: SensorService.instance.smoke
                          ? "Warning"
                          : "Normal",
                      icon: Icons.local_fire_department,
                      color: SensorService.instance.smoke
                          ? AppColors.danger
                          : AppColors.success,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 30),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: QuickActionCard(
                title: "Open All",
                icon: Icons.lock_open_rounded,
                color: AppColors.success,
                onTap: () {
                  SensorService.instance.setAutoMode(false);
                  SensorService.instance.openWindow();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("All windows opened"),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: QuickActionCard(
                title: "Close All",
                icon: Icons.lock_rounded,
                color: AppColors.danger,
                onTap: () {
                  SensorService.instance.setAutoMode(false);
                  SensorService.instance.closeWindow();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("All windows closed"),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: QuickActionCard(
                title: "Auto Mode",
                icon: Icons.auto_mode_rounded,
                color: AppColors.primary,
                onTap: () {
                  SensorService.instance.setAutoMode(
                    !SensorService.instance.autoMode,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        SensorService.instance.autoMode
                            ? "Auto Mode enabled"
                            : "Auto Mode disabled",
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ),
          ],
        ),



        const SizedBox(height: 30),

        const StatisticsCard(),

        const SizedBox(height: 30),

        const Text(
          "Recent Activity",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

const SizedBox(height: 15),

const ActivityCard(
icon: Icons.window,
color: Colors.green,
title: "Living Room Window Opened",
time: "10:35 AM",
),

ActivityCard(
icon: SensorService.instance.rain
? Icons.cloud
: Icons.cloud_done,
color: SensorService.instance.rain
? Colors.blue
: Colors.green,
title: SensorService.instance.rain
? "Rain Detected"
: "Weather Normal",
time: "Live",
),

ActivityCard(
icon: SensorService.instance.windowOpen
? Icons.window
: Icons.window_outlined,
color: SensorService.instance.windowOpen
? Colors.green
: Colors.red,
title: SensorService.instance.windowOpen
? "Window Open"
: "Window Closed",
time: "Live",
),

ActivityCard(
icon: SensorService.instance.smoke
? Icons.local_fire_department
: Icons.check_circle,
color: SensorService.instance.smoke
? Colors.red
: Colors.green,
title: SensorService.instance.smoke
? "Smoke Detected"
: "Smoke Normal",
time: "Live",
),

const SizedBox(height: 30),

            const SizedBox(height: 20),


          ],
        ),
      ),
    );
    }
}