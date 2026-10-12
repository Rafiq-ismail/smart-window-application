import 'package:flutter/material.dart';

import '../../../services/sensor_service.dart';

class RoomStatusCard extends StatelessWidget {
  final String roomName;
  final IconData icon;
  final String status;
  final int openingPercentage;
  final int actuatorChannel;
  final VoidCallback? onTap;

  const RoomStatusCard({
    super.key,
    required this.roomName,
    required this.icon,
    this.status = 'CLOSED',
    this.openingPercentage = 0,
    this.actuatorChannel = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder(
      stream: SensorService.instance.stream,
      builder: (context, snapshot) {
        final sensor = SensorService.instance;

        double roomTemperature;

        if (roomName == "Bedroom") {
          roomTemperature = sensor.room2Temperature;
        } else if (roomName == "Kitchen") {
          roomTemperature = sensor.room3Temperature;
        } else {
          // Living Room = Room 1
          roomTemperature = sensor.temperature;
        }

        final bool isOpen =
            status.toUpperCase() == 'OPEN';

        final double opening =
        openingPercentage.toDouble();

        final Color statusColor = isOpen
            ? colors.primary
            : colors.onSurfaceVariant;

        return Material(
          color: Colors.transparent,

          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(22),

            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(22),

                border: Border.all(
                  color: colors.outlineVariant,
                ),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: isDark ? 0.12 : 0.035,
                    ),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),

              child: Column(
                children: [
                  // ROOM HEADER
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,

                        decoration: BoxDecoration(
                          color: colors.primaryContainer,
                          borderRadius:
                          BorderRadius.circular(15),
                        ),

                        child: Icon(
                          icon,
                          color: colors.primary,
                          size: 25,
                        ),
                      ),

                      const SizedBox(width: 13),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              roomName,
                              maxLines: 2,
                              overflow:
                              TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colors.onSurface,
                                fontSize: 18,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 3),

                            Text(
                              "Smart window",
                              style: TextStyle(
                                color:
                                colors.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // STATUS
                      Container(
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),

                        decoration: BoxDecoration(
                          color: isOpen
                              ? colors.primaryContainer
                              : colors
                              .surfaceContainerHighest,
                          borderRadius:
                          BorderRadius.circular(20),
                        ),

                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isOpen
                                  ? Icons.lock_open_rounded
                                  : Icons
                                  .lock_outline_rounded,
                              size: 14,
                              color: statusColor,
                            ),

                            const SizedBox(width: 5),

                            Text(
                              isOpen ? "Open" : "Closed",
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 12,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // OPENING PROGRESS
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Window Opening",
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),

                      Text(
                        "${opening.toInt()}%",
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 9),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value:
                      (opening / 100).clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor:
                      colors.primaryContainer,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(
                        colors.primary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // BOTTOM INFORMATION
                  Row(
                    children: [
                      Expanded(
                        child: _RoomInfo(
                          icon: Icons.auto_mode_rounded,
                          label: "Mode",
                          value: sensor.autoMode
                              ? "Automatic"
                              : "Manual",
                        ),
                      ),

                      Container(
                        width: 1,
                        height: 35,
                        color: colors.outlineVariant,
                      ),

                      Expanded(
                        child: _RoomInfo(
                          icon: Icons.thermostat_rounded,
                          label: "Temperature",
                          value:
                          "${roomTemperature.toStringAsFixed(1)}°C",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}


// ROOM INFO

class _RoomInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _RoomInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 19,
          color: colors.primary,
        ),

        const SizedBox(width: 8),

        Flexible(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}