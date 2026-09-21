import 'package:flutter/material.dart';

import 'widgets/profile_header.dart';
import 'widgets/profile_menu_tile.dart';
import 'widgets/settings_switch_tile.dart';
import 'widgets/about_card.dart';

import '../history/history_page.dart';
import '../esp32/esp32_page.dart';

import '../../services/pdf_service.dart';
import '../../services/settings_service.dart';
import '../../services/auth_service.dart';

import '../../core/app_routes.dart';
import '../../core/app_colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late bool notificationEnabled;
  late bool autoMode;
  late bool darkMode;

  @override
  void initState() {
    super.initState();

    notificationEnabled =
        SettingsService.instance.notifications;

    autoMode =
        SettingsService.instance.autoMode;

    darkMode =
        SettingsService.instance.darkMode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          // PROFILE HEADER


          const ProfileHeader(),

          const SizedBox(height: 30),


          // SETTINGS


          const Text(
            "Settings",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          // Notifications
          SettingsSwitchTile(
            icon: Icons.notifications_rounded,
            title: "Notifications",
            subtitle: "Receive Smart Window alerts",
            color: AppColors.primary,
            value: notificationEnabled,
            onChanged: (value) async {
              await SettingsService.instance
                  .setNotifications(value);

              if (!mounted) return;

              setState(() {
                notificationEnabled = value;
              });
            },
          ),

          // Auto Mode
          SettingsSwitchTile(
            icon: Icons.auto_mode_rounded,
            title: "Auto Mode",
            subtitle: "Automatic window control",
            color: AppColors.primary,
            value: autoMode,
            onChanged: (value) async {
              await SettingsService.instance
                  .setAutoMode(value);

              if (!mounted) return;

              setState(() {
                autoMode = value;
              });
            },
          ),

          // Dark Mode
          SettingsSwitchTile(
            icon: Icons.dark_mode_rounded,
            title: "Dark Mode",
            subtitle: "Enable dark appearance",
            color: AppColors.primary,
            value: darkMode,
            onChanged: (value) async {
              await SettingsService.instance
                  .setDarkMode(value);

              if (!mounted) return;

              setState(() {
                darkMode = value;
              });
            },
          ),

          const SizedBox(height: 30),


          const Text(
            "More",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          // Activity History
          ProfileMenuTile(
            icon: Icons.history_rounded,
            title: "Activity History",
            subtitle: "View system activities",
            color: AppColors.primary,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HistoryPage(),
                ),
              );
            },
          ),

          // ESP32
          ProfileMenuTile(
            icon: Icons.memory_rounded,
            title: "ESP32 Connection",
            subtitle: "Connection information",
            color: AppColors.primary,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ESP32Page(),
                ),
              );
            },
          ),

          // Export Report
          ProfileMenuTile(
            icon: Icons.picture_as_pdf_rounded,
            title: "Export Report",
            subtitle: "Download system report",
            color: AppColors.primary,
            onTap: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Generating PDF Report...",
                  ),
                  duration: Duration(seconds: 2),
                ),
              );

              await PdfService.exportReport();
            },
          ),

          const SizedBox(height: 20),


          // ABOUT


          const AboutCard(),

          const SizedBox(height: 25),


          // LOGOUT


          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: 0.025,
                  ),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                icon: const Icon(
                  Icons.logout_rounded,
                  size: 21,
                ),
                label: const Text(
                  "Logout",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (dialogContext) {
                      return AlertDialog(
                        title: const Text("Logout"),
                        content: const Text(
                          "Are you sure you want to logout?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                            },
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(dialogContext);

                              await AuthService.instance.logout();

                              if (!mounted) return;

                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                AppRoutes.login,
                                    (route) => false,
                              );
                            },
                            child: const Text("Logout"),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}