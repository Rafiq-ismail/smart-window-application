import 'package:flutter/material.dart';
import '../../../services/sensor_service.dart';

class DashboardSummaryCard extends StatelessWidget {
  const DashboardSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: SensorService.instance.stream,
      builder: (context, snapshot) {
        return Card(
          elevation: 4,
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
                      Icons.dashboard,
                      color: Colors.indigo,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "System Summary",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [

                    summaryItem(
                      Icons.thermostat,
                      "${SensorService.instance.temperature.toStringAsFixed(1)}°C",
                      "Temp",
                      Colors.orange,
                    ),

                    summaryItem(
                      Icons.water_drop,
                      "${SensorService.instance.humidity.toStringAsFixed(0)}%",
                      "Humidity",
                      Colors.blue,
                    ),

                    summaryItem(
                      Icons.window,
                      SensorService.instance.windowOpen
                          ? "OPEN"
                          : "CLOSED",
                      "Window",
                      SensorService.instance.windowOpen
                          ? Colors.green
                          : Colors.red,
                    ),

                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget summaryItem(
      IconData icon,
      String value,
      String label,
      Color color,
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
          ),
        ),

        Text(label),
      ],
    );
  }
}