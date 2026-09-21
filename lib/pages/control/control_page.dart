import 'package:flutter/material.dart';

import '../../services/sensor_service.dart';

class ControlPage extends StatefulWidget {
  final String roomName;

  const ControlPage({
    super.key,
    required this.roomName,
  });

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.roomName),
        centerTitle: true,
      ),

      body: StreamBuilder(
        stream: SensorService.instance.stream,
        builder: (context, snapshot) {
          final sensor = SensorService.instance;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [


                // ROOM NAME


                Text(
                  widget.roomName,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),


                // AUTO MODE STATUS

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: sensor.autoMode
                        ? Colors.green.shade50
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: sensor.autoMode
                          ? Colors.green
                          : Colors.grey,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        sensor.autoMode
                            ? Icons.auto_mode
                            : Icons.touch_app,
                        color: sensor.autoMode
                            ? Colors.green
                            : Colors.grey.shade700,
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          sensor.autoMode
                              ? "AUTO MODE ACTIVE"
                              : "MANUAL MODE",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: sensor.autoMode
                                ? Colors.green
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),


                // WINDOW DISPLAY


                Center(
                  child: AnimatedContainer(
                    duration: const Duration(
                      milliseconds: 600,
                    ),
                    curve: Curves.easeInOut,
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      color: sensor.windowOpen
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      sensor.windowOpen
                          ? Icons.window
                          : Icons.window_outlined,
                      size: 100,
                      color: sensor.windowOpen
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ),

                const SizedBox(height: 20),


                // WINDOW STATUS


                Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(
                      milliseconds: 400,
                    ),
                    child: Text(
                      sensor.windowOpen
                          ? "WINDOW OPEN"
                          : "WINDOW CLOSED",
                      key: ValueKey(
                        sensor.windowOpen,
                      ),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: sensor.windowOpen
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 35),


                // OPEN / CLOSE BUTTON


                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.window,
                        ),
                        label: const Text("OPEN"),
                        onPressed: () {
                          sensor.openWindow();
                        },
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.window_outlined,
                        ),
                        label: const Text("CLOSE"),
                        onPressed: () {
                          sensor.closeWindow();
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 35),


                // OPENING PERCENTAGE


                const Text(
                  "Opening Percentage",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Slider(
                  value: sensor.windowOpening,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  label:
                  "${sensor.windowOpening.toInt()}%",
                  onChanged: (value) {
                    sensor.setWindowOpening(value);
                  },
                ),

                Center(
                  child: Text(
                    "${sensor.windowOpening.toInt()}%",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                const Divider(),

                const SizedBox(height: 20),


                // LIVE SENSOR STATUS

                const Text(
                  "Live Sensor Status",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

// TEMPERATURE
                Card(
                  margin: EdgeInsets.zero,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 6,
                    ),
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.thermostat,
                        color: Colors.orange,
                        size: 22,
                      ),
                    ),
                    title: const Text(
                      "Temperature",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Text(
                      "${sensor.temperature.toStringAsFixed(1)} °C",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

// HUMIDITY
                Card(
                  margin: EdgeInsets.zero,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 6,
                    ),
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.water_drop,
                        color: Colors.blue,
                        size: 22,
                      ),
                    ),
                    title: const Text(
                      "Humidity",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Text(
                      "${sensor.humidity.toStringAsFixed(0)} %",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

// RAIN SENSOR
                Card(
                  margin: EdgeInsets.zero,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 6,
                    ),
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: (sensor.rain ? Colors.orange : Colors.green)
                            .withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        Icons.cloud,
                        color: sensor.rain ? Colors.orange : Colors.green,
                        size: 22,
                      ),
                    ),
                    title: const Text(
                      "Rain Sensor",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Text(
                      sensor.rain ? "RAIN DETECTED" : "SAFE",
                      style: TextStyle(
                        color: sensor.rain ? Colors.orange : Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

// SMOKE SENSOR
                Card(
                  margin: EdgeInsets.zero,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 6,
                    ),
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: (sensor.smoke ? Colors.red : Colors.green)
                            .withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        Icons.local_fire_department,
                        color: sensor.smoke ? Colors.red : Colors.green,
                        size: 22,
                      ),
                    ),
                    title: const Text(
                      "Smoke Sensor",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Text(
                      sensor.smoke ? "SMOKE DETECTED" : "NORMAL",
                      style: TextStyle(
                        color: sensor.smoke ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),


                // AUTOMATIC CONTROL INFO


                if (sensor.autoMode &&
                    (sensor.rain || sensor.smoke))
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius:
                      BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.red.shade300,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red.shade700,
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            sensor.rain && sensor.smoke
                                ? "Rain and smoke detected. "
                                "Window has been closed automatically."
                                : sensor.rain
                                ? "Rain detected. "
                                "Window has been closed automatically."
                                : "Smoke detected. "
                                "Window has been closed automatically.",
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight:
                              FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}