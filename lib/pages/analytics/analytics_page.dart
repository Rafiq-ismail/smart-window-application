import 'package:flutter/material.dart';

import 'widgets/weather_card.dart';
import 'widgets/sensor_chart.dart';
import 'widgets/temperature_summary_card.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text("Analytics"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
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
          Text(
            "Sensor Statistics",
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          _StatisticsCard(
            icon: Icons.cloud_rounded,
            title: "Rain Events",
            value: "5",
          ),

          const SizedBox(height: 12),

          _StatisticsCard(
            icon: Icons.local_fire_department_rounded,
            title: "Smoke Alerts",
            value: "2",
          ),

          const SizedBox(height: 12),

          _StatisticsCard(
            icon: Icons.window_rounded,
            title: "Window Open Count",
            value: "24",
          ),

          const SizedBox(height: 12),

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
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),

        border: Border.all(
          color: colors.outlineVariant,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: Theme.of(context).brightness == Brightness.dark
                  ? 0.12
                  : 0.035,
            ),
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
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: colors.primary,
              size: 23,
            ),
          ),

          const SizedBox(width: 14),

          // TITLE
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // VALUE
          Text(
            value,
            style: TextStyle(
              color: colors.primary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}