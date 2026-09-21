import 'package:flutter/material.dart';

class LiveMonitorCard extends StatelessWidget {
  const LiveMonitorCard({super.key});

  Widget buildItem(
      IconData icon,
      String title,
      String value,
      Color color,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [

          CircleAvatar(
            radius: 22,
            backgroundColor: color..withValues(alpha:.15),
            child: Icon(
              icon,
              color: color,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),

          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [

            const Row(
              children: [

                Icon(Icons.monitor_heart),

                SizedBox(width: 10),

                Text(
                  "Live Monitoring",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              ],
            ),

            const Divider(height: 30),

            buildItem(
              Icons.thermostat,
              "Temperature",
              "28°C",
              Colors.orange,
            ),

            buildItem(
              Icons.water_drop,
              "Humidity",
              "65%",
              Colors.blue,
            ),

            buildItem(
              Icons.cloud,
              "Rain",
              "Safe",
              Colors.green,
            ),

            buildItem(
              Icons.local_fire_department,
              "Smoke",
              "Normal",
              Colors.red,
            ),

          ],
        ),
      ),
    );
  }
}