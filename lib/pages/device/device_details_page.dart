import 'package:flutter/material.dart';
import '../../services/sensor_service.dart';

class DeviceDetailsPage extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool online;

  const DeviceDetailsPage({
    super.key,
    required this.title,
    required this.icon,
    required this.online,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor:
              online ? Colors.green.shade100 : Colors.red.shade100,
              child: Icon(
                icon,
                size: 55,
                color: online ? Colors.green : Colors.red,
              ),
            ),
          ),

          const SizedBox(height: 25),

          Center(
            child: Text(
              online ? "CONNECTED" : "OFFLINE",
              style: TextStyle(
                color: online ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),

          const SizedBox(height: 30),

          StreamBuilder(
            stream: SensorService.instance.stream,
            builder: (context, snapshot) {

              final sensor = SensorService.instance;

              return Column(
                children: [

                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.thermostat),
                      title: const Text("Temperature"),
                      trailing: Text(
                        "${sensor.temperature.toStringAsFixed(1)} °C",
                      ),
                    ),
                  ),

                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.water_drop),
                      title: const Text("Humidity"),
                      trailing: Text(
                        "${sensor.humidity.toStringAsFixed(0)} %",
                      ),
                    ),
                  ),

                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.cloud),
                      title: const Text("Rain"),
                      trailing: Text(
                        sensor.rain ? "Detected" : "Safe",
                        style: TextStyle(
                          color: sensor.rain
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                    ),
                  ),

                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.local_fire_department),
                      title: const Text("Smoke"),
                      trailing: Text(
                        sensor.smoke ? "Detected" : "Normal",
                        style: TextStyle(
                          color: sensor.smoke
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                    ),
                  ),

                ],
              );
            },
          ),

          const SizedBox(height: 30),

          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.restart_alt),
            label: const Text("Restart Device"),
          ),

          const SizedBox(height: 15),

          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.system_update),
            label: const Text("Update Firmware"),
          ),

          const SizedBox(height: 15),

          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.article),
            label: const Text("View Logs"),
          ),
        ],
      ),
    );
  }
}