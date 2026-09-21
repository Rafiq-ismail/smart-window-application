import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../services/sensor_service.dart';

class SystemStatusCard extends StatelessWidget {
  const SystemStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: SensorService.instance.stream,
      builder: (context, snapshot) {
        final sensor = SensorService.instance;

        final bool isRain = sensor.rain;
        final bool isSmoke = sensor.smoke;
        final bool autoMode = sensor.autoMode;

        final bool systemSafe = !isSmoke;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.divider,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [

              // HEADER


              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius:
                      BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: AppColors.primaryDark,
                      size: 25,
                    ),
                  ),

                  const SizedBox(width: 13),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          "System Status",
                          style: TextStyle(
                            color:
                            AppColors.textPrimary,
                            fontSize: 19,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          "Smart Window overview",
                          style: TextStyle(
                            color:
                            AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // STATUS
                  Container(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: systemSafe
                          ? AppColors.primaryLight
                          : const Color(0xFFFFE8E8),
                      borderRadius:
                      BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize:
                      MainAxisSize.min,
                      children: [
                        Icon(
                          systemSafe
                              ? Icons.check_circle
                              : Icons.warning_rounded,
                          size: 14,
                          color: systemSafe
                              ? AppColors.success
                              : AppColors.danger,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          systemSafe
                              ? "Safe"
                              : "Warning",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                            FontWeight.w600,
                            color: systemSafe
                                ? AppColors.success
                                : AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),


              // STATUS ITEMS


              _StatusItem(
                icon: Icons.auto_mode_rounded,
                title: "Control Mode",
                value:
                autoMode ? "Auto Mode" : "Manual Mode",
                color: autoMode
                    ? AppColors.primary
                    : AppColors.info,
              ),

              const SizedBox(height: 10),

              _StatusItem(
                icon: Icons.water_drop_outlined,
                title: "Rain Protection",
                value:
                isRain ? "Rain Detected" : "Ready",
                color: isRain
                    ? AppColors.warning
                    : AppColors.success,
              ),

              const SizedBox(height: 10),

              _StatusItem(
                icon:
                Icons.local_fire_department_outlined,
                title: "Smoke Sensor",
                value:
                isSmoke ? "Smoke Detected" : "Normal",
                color: isSmoke
                    ? AppColors.danger
                    : AppColors.success,
              ),
            ],
          ),
        );
      },
    );
  }
}


// STATUS ITEM


class _StatusItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatusItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius:
              BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}