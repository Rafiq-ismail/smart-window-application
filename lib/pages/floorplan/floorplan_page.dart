import 'package:flutter/material.dart';

import '../../services/sensor_service.dart';
import '../control/control_page.dart';

class FloorPlanPage extends StatelessWidget {
  const FloorPlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("House Floor Plan"),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: SensorService.instance.stream,
        builder: (context, snapshot) {
          return Center(
            child: Container(
              width: 340,
              height: 500,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border.all(
                  color: Colors.grey.shade400,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  roomButton(
                    context,
                    room: "Living Room",
                    icon: Icons.weekend,
                    left: 20,
                    top: 20,
                  ),
                  roomButton(
                    context,
                    room: "Bedroom",
                    icon: Icons.bed,
                    left: 180,
                    top: 20,
                  ),
                  roomButton(
                    context,
                    room: "Kitchen",
                    icon: Icons.kitchen,
                    left: 20,
                    top: 220,
                  ),
                  roomButton(
                    context,
                    room: "Bathroom",
                    icon: Icons.bathtub,
                    left: 180,
                    top: 220,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget roomButton(
      BuildContext context, {
        required String room,
        required IconData icon,
        required double left,
        required double top,
      }) {
    final sensor = SensorService.instance;
    final bool open = sensor.windowOpen;

    return Positioned(
      left: left,
      top: top,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ControlPage(
                  roomName: room,
                ),
              ),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            width: 120,
            height: 145,
            decoration: BoxDecoration(
              color: open
                  ? Colors.green.shade50
                  : Colors.red.shade50,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: open ? Colors.green : Colors.red,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: open
                      ? Colors.green.withValues(alpha: 0.25)
                      : Colors.red.withValues(alpha: 0.25),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 38,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    room,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Row(
                      key: ValueKey(open),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          open
                              ? Icons.window
                              : Icons.window_outlined,
                          size: 18,
                          color: open
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          open
                              ? "OPEN"
                              : "CLOSED",
                          style: TextStyle(
                            color: open
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: sensor.windowOpening / 100,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(10),
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      open ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${sensor.windowOpening.toInt()}%",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}