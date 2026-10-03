import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/sensor_service.dart';
import '../../services/esp32_control_service.dart';
import '../../services/window_service.dart';

class ControlPage extends StatefulWidget {
  final String windowId;
  final String roomName;
  final int actuatorChannel;

  const ControlPage({
    super.key,
    this.windowId = '',
    required this.roomName,
    this.actuatorChannel = 0,
  });

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  double? _sliderValue;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.roomName), centerTitle: true),

      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: widget.windowId.isNotEmpty
            ? FirebaseFirestore.instance
                  .collection('windows')
                  .doc(widget.windowId)
                  .snapshots()
            : const Stream.empty(),
        builder: (context, windowSnapshot) {
          final windowData = windowSnapshot.data?.data();

          final windowStatus = windowData?['status']?.toString() ?? 'CLOSED';

          final openingPercentage =
              (windowData?['openingPercentage'] as num?)?.toDouble() ?? 0.0;

          final bool isWindowOpen = windowStatus.toUpperCase() == 'OPEN';

          return StreamBuilder(
            stream: SensorService.instance.stream,
            builder: (context, sensorSnapshot) {
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
                          color: sensor.autoMode ? Colors.green : Colors.grey,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            sensor.autoMode ? Icons.auto_mode : Icons.touch_app,
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
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOut,
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          color: isWindowOpen
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Icon(
                          isWindowOpen ? Icons.window : Icons.window_outlined,
                          size: 100,
                          color: isWindowOpen ? Colors.green : Colors.red,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // WINDOW STATUS
                    Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: Text(
                          isWindowOpen ? "WINDOW OPEN" : "WINDOW CLOSED",
                          key: ValueKey(isWindowOpen),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isWindowOpen ? Colors.green : Colors.red,
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
                            icon: const Icon(Icons.window),
                            label: const Text("OPEN"),
                            onPressed: () async {
                              if (widget.windowId.isEmpty ||
                                  widget.actuatorChannel < 1 ||
                                  widget.actuatorChannel > 3) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "This window is not assigned to an actuator.",
                                    ),
                                  ),
                                );
                                return;
                              }

                              bool success = false;

                              switch (widget.actuatorChannel) {
                                case 1:
                                  success = await Esp32ControlService.instance
                                      .openWindow1();
                                  break;

                                case 2:
                                  success = await Esp32ControlService.instance
                                      .openWindow2();
                                  break;

                                case 3:
                                  success = await Esp32ControlService.instance
                                      .openWindow3();
                                  break;
                              }

                              if (!mounted) return;

                              if (success) {
                                await WindowService.instance.updateWindowState(
                                  windowId: widget.windowId,
                                  openingPercentage: 100,
                                );

                                if (!mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Window opened successfully.",
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Failed to open window."),
                                  ),
                                );
                              }
                            },
                          ),
                        ),

                        const SizedBox(width: 15),

                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.window_outlined),
                            label: const Text("CLOSE"),
                            onPressed: () async {
                              if (widget.windowId.isEmpty ||
                                  widget.actuatorChannel < 1 ||
                                  widget.actuatorChannel > 3) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "This window is not assigned to an actuator.",
                                    ),
                                  ),
                                );
                                return;
                              }

                              bool success = false;

                              switch (widget.actuatorChannel) {
                                case 1:
                                  success = await Esp32ControlService.instance
                                      .closeWindow1();
                                  break;

                                case 2:
                                  success = await Esp32ControlService.instance
                                      .closeWindow2();
                                  break;

                                case 3:
                                  success = await Esp32ControlService.instance
                                      .closeWindow3();
                                  break;
                              }

                              if (!mounted) return;

                              if (success) {
                                await WindowService.instance.updateWindowState(
                                  windowId: widget.windowId,
                                  openingPercentage: 0,
                                );

                                if (!mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Window closed successfully.",
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Failed to close window."),
                                  ),
                                );
                              }
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
                      value: (_sliderValue ?? openingPercentage).clamp(0.0, 100.0),
                      min: 0,
                      max: 100,
                      divisions: 100,
                      label: "${(_sliderValue ?? openingPercentage).toInt()}%",
                      onChanged: (value) {
                        setState(() {
                          _sliderValue = value;

                        });
                      },

                      onChangeEnd: (value) async {
                        final percent = value.round();

                        if (widget.windowId.isEmpty ||
                            widget.actuatorChannel < 1 ||
                            widget.actuatorChannel > 3) {
                          setState(() {
                            _sliderValue = null;

                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "This window is not assigned to an actuator.",
                              ),
                            ),
                          );
                          return;
                        }

                        bool success = false;

                        switch (widget.actuatorChannel) {
                          case 1:
                            success = await Esp32ControlService.instance
                                .setWindow1Position(percent);
                            break;

                          case 2:
                            success = await Esp32ControlService.instance
                                .setWindow2Position(percent);
                            break;

                          case 3:
                            success = await Esp32ControlService.instance
                                .setWindow3Position(percent);
                            break;
                        }

                        if (!mounted) return;

                        if (success) {
                          await WindowService.instance.updateWindowState(
                            windowId: widget.windowId,
                            openingPercentage: percent,
                          );

                          if (!mounted) return;

                          setState(() {
                            _sliderValue = null;

                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Window position set to $percent%.",
                              ),
                            ),
                          );
                        } else {
                          setState(() {
                            _sliderValue = null;

                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Failed to change window position.",
                              ),
                            ),
                          );
                        }
                      },

                    ),

                    Center(
                      child: Text(
                        "${openingPercentage.toInt()}%",
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
                    if (sensor.autoMode && (sensor.rain || sensor.smoke))
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.red.shade300),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                  fontWeight: FontWeight.w600,
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
          );
        },
      ),
    );
  }
}
