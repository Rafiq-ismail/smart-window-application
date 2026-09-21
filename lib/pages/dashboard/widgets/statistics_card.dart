import 'package:flutter/material.dart';
import '../../../services/statistics_service.dart';

class StatisticsCard extends StatelessWidget {
  const StatisticsCard({super.key});

  Widget buildItem(
    IconData icon,
    Color color,
    String title,
    String value,
  ) {
    return Column(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(
            icon,
            color: color,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),

        Text(title),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: StatisticsService.instance,
      builder: (context, child) {
        return Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.analytics,
                      color: Colors.indigo,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Today's Statistics",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceAround,
                  children: [
                    buildItem(
                      Icons.window,
                      Colors.green,
                      "Opened",
                      StatisticsService
                          .instance
                          .windowOpenCount
                          .toString(),
                    ),

                    buildItem(
                      Icons.cloud,
                      Colors.blue,
                      "Rain",
                      StatisticsService
                          .instance
                          .rainCount
                          .toString(),
                    ),

                    buildItem(
                      Icons.warning,
                      Colors.red,
                      "Smoke",
                      StatisticsService
                          .instance
                          .smokeCount
                          .toString(),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                Text(
                  "Average Temperature",
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "${StatisticsService.instance.averageTemperature.toStringAsFixed(1)}°C",
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}