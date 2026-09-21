import 'package:flutter/material.dart';
import '../../../services/sensor_service.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: SensorService.instance.stream,
      builder: (context, snapshot) {

        final sensor = SensorService.instance;

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
                    Icon(Icons.analytics),
                    SizedBox(width: 10),
                    Text(
                      "Today's Summary",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                buildItem(
                  Icons.thermostat,
                  "Temperature",
                  "${sensor.temperature.toStringAsFixed(1)}°C",
                ),

                buildItem(
                  Icons.water_drop,
                  "Humidity",
                  "${sensor.humidity.toStringAsFixed(0)}%",
                ),

                buildItem(
                  Icons.window,
                  "Window",
                  sensor.windowOpen ? "OPEN" : "CLOSED",
                ),

                buildItem(
                  Icons.cloud,
                  "Rain",
                  sensor.rain ? "Detected" : "Safe",
                ),

                buildItem(
                  Icons.local_fire_department,
                  "Smoke",
                  sensor.smoke ? "Detected" : "Normal",
                ),

              ],
            ),
          ),
        );

      },
    );
  }

  Widget buildItem(
      IconData icon,
      String title,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [

          Icon(icon),

          const SizedBox(width: 12),

          Expanded(
            child: Text(title),
          ),

          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

        ],
      ),
    );
  }
}