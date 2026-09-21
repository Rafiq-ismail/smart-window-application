import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../services/sensor_service.dart';

class RoomStatusCard extends StatelessWidget {
  final String roomName;
  final IconData icon;
  final VoidCallback? onTap;

  const RoomStatusCard({
    super.key,
    required this.roomName,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: SensorService.instance.stream,
      builder: (context, snapshot) {
        final sensor = SensorService.instance;

        final bool isOpen = sensor.windowOpen;
        final double opening = sensor.windowOpening;

        final Color statusColor = isOpen
            ? AppColors.success
            : AppColors.textSecondary;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(22),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: AppColors.divider,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.035),
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
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          icon,
                          color: AppColors.primaryDark,
                          size: 25,
                        ),
                      ),

                      const SizedBox(width: 13),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              roomName,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 3),

                            const Text(
                              "Smart window",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),


                      // STATUS


                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: isOpen
                              ? AppColors.primaryLight
                              : const Color(0xFFF1F2EF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isOpen
                                  ? Icons.lock_open_rounded
                                  : Icons.lock_outline_rounded,
                              size: 14,
                              color: statusColor,
                            ),

                            const SizedBox(width: 5),

                            Text(
                              isOpen ? "Open" : "Closed",
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
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
                      const Text(
                        "Window Opening",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),

                      Text(
                        "${opening.toInt()}%",
                        style: const TextStyle(
                          color: AppColors.textPrimary,
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
                      value: (opening / 100).clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: AppColors.primaryLight,
                      valueColor:
                      const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
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
                        color: AppColors.divider,
                      ),

                      Expanded(
                        child: _RoomInfo(
                          icon: Icons.thermostat_rounded,
                          label: "Temperature",
                          value:
                          "${sensor.temperature.toStringAsFixed(1)}°C",
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 19,
          color: AppColors.primaryDark,
        ),

        const SizedBox(width: 8),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}