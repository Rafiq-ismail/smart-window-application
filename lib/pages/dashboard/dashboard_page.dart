import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/window_service.dart';
import '../../services/esp32_control_service.dart';

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


class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {

  bool _lastRain = false;
  bool _lastSmoke = false;
  bool _lastWindow = true;

  bool _lastRoom2Smoke = false;
  bool _lastRoom3Smoke = false;

  Future<void> _openAllWindows() async {
    // Manual command -> disable Auto Mode first
    await SensorService.instance.setAutoMode(false);

    // Open all 3 physical actuators
    final window1Success =
    await Esp32ControlService.instance.openWindow1();

    final window2Success =
    await Esp32ControlService.instance.openWindow2();

    final window3Success =
    await Esp32ControlService.instance.openWindow3();

    if (!window1Success ||
        !window2Success ||
        !window3Success) {
      throw Exception('One or more windows failed to open');
    }

    // Update Firestore after physical movement succeeds
    final snapshot =
    await WindowService.instance.getUserWindows().first;

    for (final document in snapshot.docs) {
      await WindowService.instance.updateWindowState(
        windowId: document.id,
        openingPercentage: 100,
      );
    }
  }

  Future<void> _closeAllWindows() async {
    // Manual command -> disable Auto Mode first
    await SensorService.instance.setAutoMode(false);

    // Close all 3 physical actuators
    final window1Success =
    await Esp32ControlService.instance.closeWindow1();

    final window2Success =
    await Esp32ControlService.instance.closeWindow2();

    final window3Success =
    await Esp32ControlService.instance.closeWindow3();

    if (!window1Success ||
        !window2Success ||
        !window3Success) {
      throw Exception('One or more windows failed to close');
    }

    // Update Firestore after physical movement succeeds
    final snapshot =
    await WindowService.instance.getUserWindows().first;

    for (final document in snapshot.docs) {
      await WindowService.instance.updateWindowState(
        windowId: document.id,
        openingPercentage: 0,
      );
    }
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
                      message: sensor.autoMode
                          ? "Windows closed automatically."
                          : "Auto Mode is off. Windows remain unchanged.",
                      color: Colors.orange,
                      icon: Icons.cloud,
                    );
                  });
                }

// Smoke Notification
                // Room 1 Smoke Notification
                if (SettingsService.instance.notifications &&
                    sensor.smoke &&
                    !_lastSmoke) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    TopNotificationService.show(
                      context: context,
                      title: "Smoke Alert - Room 1",
                      message: sensor.autoMode
                          ? "Smoke or gas detected in Room 1. Window closed automatically."
                          : "Smoke or gas detected in Room 1. Auto Mode is off.",
                      color: Colors.red,
                      icon: Icons.local_fire_department,
                    );
                  });
                }

// Room 2 Smoke Notification
                if (SettingsService.instance.notifications &&
                    sensor.room2Smoke &&
                    !_lastRoom2Smoke) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    TopNotificationService.show(
                      context: context,
                      title: "Smoke Alert - Room 2",
                      message: sensor.autoMode
                          ? "Smoke or gas detected in Room 2. Window closed automatically."
                          : "Smoke or gas detected in Room 2. Auto Mode is off.",
                      color: Colors.red,
                      icon: Icons.local_fire_department,
                    );
                  });
                }

// Room 3 Smoke Notification
                if (SettingsService.instance.notifications &&
                    sensor.room3Smoke &&
                    !_lastRoom3Smoke) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    TopNotificationService.show(
                      context: context,
                      title: "Smoke Alert - Room 3",
                      message: sensor.autoMode
                          ? "Smoke or gas detected in Room 3. Window closed automatically."
                          : "Smoke or gas detected in Room 3. Auto Mode is off.",
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
                _lastRoom2Smoke = sensor.room2Smoke;
                _lastRoom3Smoke = sensor.room3Smoke;
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

            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: WindowService.instance.getUserWindows(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return const Text(
                    "Unable to load windows.",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  );
                }

                final windows = snapshot.data?.docs ?? [];

                if (windows.isEmpty) {
                  return const Text(
                    "No windows added yet.",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  );
                }

                return Column(
                  children: List.generate(
                    windows.length,
                        (index) {
                      final document = windows[index];
                      final data = document.data();

                      final windowName =
                          data['name']?.toString() ?? 'Window';

                      final status =
                          data['status']?.toString() ?? 'CLOSED';

                      final openingPercentage =
                          (data['openingPercentage'] as num?)
                              ?.toInt() ??
                              0;

                      final actuatorChannel =
                          (data['actuatorChannel'] as num?)
                              ?.toInt() ??
                              0;

                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == windows.length - 1 ? 0 : 15,
                        ),
                        child: RoomStatusCard(
                          roomName: windowName,
                          icon: Icons.window_rounded,
                          status: status,
                          openingPercentage: openingPercentage,
                          actuatorChannel: actuatorChannel,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ControlPage(
                                  windowId: document.id,
                                  roomName: windowName,
                                  actuatorChannel: actuatorChannel,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),

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
                onTap: () async {
                  try {
                    await _openAllWindows();

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("All windows opened"),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  } catch (e) {
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Failed to open all windows"),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: QuickActionCard(
                title: "Close All",
                icon: Icons.lock_rounded,
                color: AppColors.danger,
                onTap: () async {
                  try {
                    await _closeAllWindows();

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("All windows closed"),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  } catch (e) {
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Failed to close all windows"),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: QuickActionCard(
                title: "Auto Mode",
                icon: Icons.auto_mode_rounded,
                color: AppColors.primary,
                onTap: () async {
                  final newValue =
                  !SensorService.instance.autoMode;

                  await SensorService.instance.setAutoMode(
                    newValue,
                  );

                  if (!context.mounted) return;

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