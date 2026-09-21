import 'package:flutter/material.dart';

class ESP32Page extends StatelessWidget {
  const ESP32Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ESP32 Connection"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [

                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.green,
                    child: Icon(
                      Icons.memory,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "ESP32 Connected",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      "ONLINE",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 25),

          buildTile(
            Icons.wifi,
            "WiFi Network",
            "SmartHome WiFi",
          ),

          buildTile(
            Icons.router,
            "IP Address",
            "192.168.1.100",
          ),

          buildTile(
            Icons.memory,
            "Device",
            "ESP32 DevKit V1",
          ),

          buildTile(
            Icons.settings,
            "Firmware",
            "Version 1.0.0",
          ),

          buildTile(
            Icons.timer,
            "Uptime",
            "12 Hours",
          ),

          buildTile(
            Icons.speed,
            "Signal Strength",
            "-48 dBm",
          ),

          buildTile(
            Icons.storage,
            "Flash Memory",
            "4 MB",
          ),

          buildTile(
            Icons.sd_storage,
            "Free Memory",
            "286 KB",
          ),

        ],
      ),
    );
  }

  Widget buildTile(
    IconData icon,
    String title,
    String value,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.blue,
        ),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}