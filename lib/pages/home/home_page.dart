import 'package:flutter/material.dart';

import '../dashboard/dashboard_page.dart';
import '../window/windows_page.dart';
import '../device/user_devices_page.dart';
import '../sensors/sensors_page.dart';
import '../analytics/analytics_page.dart';
import '../profile/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  final List<Widget> pages = [
    const DashboardPage(),

    // USER WINDOWS
    const WindowsPage(),

    // USER DEVICES / ESP32
    const UserDevicesPage(),

    const SensorsPage(),

    const AnalyticsPage(),

    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.window),
            label: "Windows",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.developer_board),
            label: "Devices",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.sensors),
            label: "Sensors",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Analytics",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}