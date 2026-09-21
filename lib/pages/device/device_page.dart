import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import 'device_details_page.dart';
import 'widgets/device_card.dart';

class DevicesPage extends StatelessWidget {
  const DevicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text("Devices"),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        children: [

          // PAGE DESCRIPTION


          const Text(
            "Connected Devices",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            "Monitor and manage your smart window devices",
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 20),


          // ESP32


          DeviceCard(
            icon: Icons.memory_rounded,
            title: "ESP32 Controller",
            subtitle: "Connected",
            online: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DeviceDetailsPage(
                    title: "ESP32 Controller",
                    icon: Icons.memory_rounded,
                    online: true,
                  ),
                ),
              );
            },
          ),


          // LIVING ROOM


          DeviceCard(
            icon: Icons.window_rounded,
            title: "Living Room Window",
            subtitle: "OPEN",
            online: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DeviceDetailsPage(
                    title: "Living Room Window",
                    icon: Icons.window_rounded,
                    online: true,
                  ),
                ),
              );
            },
          ),


          // BEDROOM


          DeviceCard(
            icon: Icons.window_outlined,
            title: "Bedroom Window",
            subtitle: "CLOSED",
            online: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DeviceDetailsPage(
                    title: "Bedroom Window",
                    icon: Icons.window_outlined,
                    online: false,
                  ),
                ),
              );
            },
          ),


          // KITCHEN


          DeviceCard(
            icon: Icons.kitchen_rounded,
            title: "Kitchen Window",
            subtitle: "OPEN",
            online: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DeviceDetailsPage(
                    title: "Kitchen Window",
                    icon: Icons.kitchen_rounded,
                    online: true,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 12),


          // SENSORS TITLE


          const Text(
            "Sensors",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),


          // RAIN SENSOR


          DeviceCard(
            icon: Icons.cloud_rounded,
            title: "Rain Sensor",
            subtitle: "Online",
            online: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DeviceDetailsPage(
                    title: "Rain Sensor",
                    icon: Icons.cloud_rounded,
                    online: true,
                  ),
                ),
              );
            },
          ),


          // SMOKE SENSOR


          DeviceCard(
            icon: Icons.local_fire_department_rounded,
            title: "Smoke Sensor",
            subtitle: "Online",
            online: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DeviceDetailsPage(
                    title: "Smoke Sensor",
                    icon: Icons.local_fire_department_rounded,
                    online: true,
                  ),
                ),
              );
            },
          ),


          // TEMPERATURE SENSOR


          DeviceCard(
            icon: Icons.thermostat_rounded,
            title: "Temperature Sensor",
            subtitle: "28°C",
            online: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DeviceDetailsPage(
                    title: "Temperature Sensor",
                    icon: Icons.thermostat_rounded,
                    online: true,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}