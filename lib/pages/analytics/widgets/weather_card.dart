import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../services/weather_service.dart';

class WeatherCard extends StatefulWidget {
  const WeatherCard({super.key});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  late Timer timer;

  @override
  void initState() {
    super.initState();

    WeatherService.instance.updateWeather();

    timer = Timer.periodic(
      const Duration(seconds: 5),
          (_) {
        if (mounted) {
          setState(() {
            WeatherService.instance.updateWeather();
          });
        }
      },
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.divider,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // HEADER
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  weatherIcon(),
                  color: Colors.orange,
                  size: 23,
                ),
              ),

              const SizedBox(width: 13),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Weather Forecast",
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      "Current weather conditions",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // WEATHER INFORMATION
          Row(
            children: [
              Expanded(
                child: _WeatherInfo(
                  icon: Icons.thermostat_rounded,
                  color: Colors.orange,
                  value:
                  "${WeatherService.instance.temperature.toStringAsFixed(1)}°C",
                  title: "Temperature",
                ),
              ),

              Container(
                width: 1,
                height: 45,
                color: AppColors.divider,
              ),

              Expanded(
                child: _WeatherInfo(
                  icon: Icons.water_drop_rounded,
                  color: Colors.blue,
                  value:
                  "${WeatherService.instance.humidity.toStringAsFixed(0)}%",
                  title: "Humidity",
                ),
              ),

              Container(
                width: 1,
                height: 45,
                color: AppColors.divider,
              ),

              Expanded(
                child: _WeatherInfo(
                  icon: Icons.air_rounded,
                  color: Colors.teal,
                  value:
                  "${WeatherService.instance.windSpeed.toStringAsFixed(0)} km/h",
                  title: "Wind",
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // WEATHER MESSAGE
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.tips_and_updates_rounded,
                  color: Colors.orange,
                  size: 21,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    weatherMessage(),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  // WEATHER INFO


  Widget _WeatherInfo({
    required IconData icon,
    required Color color,
    required String value,
    required String title,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 21,
        ),

        const SizedBox(height: 7),

        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          title,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  IconData weatherIcon() {
    switch (WeatherService.instance.condition) {
      case "Sunny":
        return Icons.wb_sunny_rounded;

      case "Cloudy":
        return Icons.cloud_rounded;

      case "Rainy":
        return Icons.umbrella_rounded;

      case "Windy":
        return Icons.air_rounded;

      default:
        return Icons.wb_sunny_rounded;
    }
  }

  String weatherMessage() {
    switch (WeatherService.instance.condition) {
      case "Sunny":
        return "Sunny weather detected. Windows can remain open.";

      case "Cloudy":
        return "Cloudy weather detected. Continue monitoring.";

      case "Rainy":
        return "Rain detected. Windows should close automatically.";

      case "Windy":
        return "Strong wind detected. Reduce window opening.";

      default:
        return "Weather monitoring is active.";
    }
  }
}