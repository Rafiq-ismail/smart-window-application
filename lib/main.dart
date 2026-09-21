import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/app_routes.dart';

import 'pages/splash/splash_page.dart';
import 'pages/login/login_page.dart';
import 'pages/dashboard/dashboard_page.dart';

import 'providers/settings_provider.dart';
import 'services/settings_service.dart';
import 'services/sensor_service.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Load saved settings
  await SettingsService.instance.loadSettings();

  // Apply saved Auto Mode to Sensor Service
  SensorService.instance.autoMode =
      SettingsService.instance.autoMode;

  // Start sensor simulation
  SensorService.instance.startSimulation();

  // Load provider settings
  final settingsProvider = SettingsProvider();
  await settingsProvider.load();

  runApp(
    ChangeNotifierProvider(
      create: (_) => settingsProvider,
      child: const SmartWindowApp(),
    ),
  );
}

class SmartWindowApp extends StatelessWidget {
  const SmartWindowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          title: "Smart Window",

          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,

          themeMode:
          settings.darkMode
              ? ThemeMode.dark
              : ThemeMode.light,

          initialRoute: AppRoutes.splash,

          routes: {
            AppRoutes.splash: (_) => const SplashPage(),
            AppRoutes.login: (_) => const LoginPage(),
            AppRoutes.dashboard: (_) => const DashboardPage(),
          },
        );
      },
    );
  }
}