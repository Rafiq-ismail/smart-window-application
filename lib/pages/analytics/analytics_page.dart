import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import 'widgets/weather_card.dart';
import 'widgets/sensor_chart.dart';
import 'widgets/temperature_summary_card.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Analytics"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          // WEATHER


          const WeatherCard(),

          const SizedBox(height: 20),


          // SENSOR ANALYTICS


          const SensorChart(),

          const SizedBox(height: 20),


          // TEMPERATURE SUMMARY


          const TemperatureSummaryCard(),

          const SizedBox(height: 30),


          // SENSOR STATISTICS


          const Text(
            "Sensor Statistics",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          // Rain Events
          _StatisticsCard(
            icon: Icons.cloud_rounded,
            title: "Rain Events",
            value: "5",
          ),

          const SizedBox(height: 12),

          // Smoke Alerts
          _StatisticsCard(
            icon: Icons.local_fire_department_rounded,
            title: "Smoke Alerts",
            value: "2",
          ),

          const SizedBox(height: 12),

          // Window Open Count
          _StatisticsCard(
            icon: Icons.window_rounded,
            title: "Window Open Count",
            value: "24",
          ),

          const SizedBox(height: 12),

          // Window Close Count
          _StatisticsCard(
            icon: Icons.window_outlined,
            title: "Window Close Count",
            value: "19",
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}


// STATISTICS CARD


class _StatisticsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StatisticsCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
      child: Row(
        children: [

          // ICON


          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryDark,
              size: 23,
            ),
          ),

          const SizedBox(width: 14),


          // TITLE


          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),


          // VALUE


          Text(
            value,
            style: const TextStyle(
              color: AppColors.primaryDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}