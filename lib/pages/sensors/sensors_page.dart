import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../services/sensor_service.dart';
import 'widgets/sensor_progress_card.dart';

class SensorsPage extends StatelessWidget {
  const SensorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: SensorService.instance.stream,
      builder: (context, snapshot) {
        final sensor = SensorService.instance;

        return Scaffold(
          backgroundColor: AppColors.background,

          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            centerTitle: true,

            title: const Text(
              "Sensor Monitoring",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            iconTheme: const IconThemeData(
              color: AppColors.textPrimary,
            ),
          ),

          body: ListView(
            padding: const EdgeInsets.fromLTRB(
              20,
              10,
              20,
              30,
            ),

            children: [


              // SENSOR CONNECTION STATUS


              Container(
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.divider,
                  ),
                ),

                child: Row(
                  children: [

                    Container(
                      width: 46,
                      height: 46,

                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(14),
                      ),

                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
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
                            "All Sensors Online",
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 3),

                          Text(
                            "Monitoring every 2 seconds",
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      width: 9,
                      height: 9,

                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),


              // TEMPERATURE


              SensorProgressCard(
                icon: Icons.thermostat_rounded,
                color: AppColors.temperature,
                title: "Temperature",
                value:
                "${sensor.temperature.toStringAsFixed(1)}°C",
                progress:
                (sensor.temperature / 50).clamp(0.0, 1.0),
              ),

              const SizedBox(height: 15),


              // HUMIDITY


              SensorProgressCard(
                icon: Icons.water_drop_rounded,
                color: AppColors.humidity,
                title: "Humidity",
                value:
                "${sensor.humidity.toStringAsFixed(0)}%",
                progress:
                (sensor.humidity / 100).clamp(0.0, 1.0),
              ),

              const SizedBox(height: 15),


              // RAIN


              SensorProgressCard(
                icon: Icons.cloud_rounded,
                color: sensor.rain
                    ? AppColors.danger
                    : AppColors.success,
                title: "Rain Sensor",
                value: sensor.rain
                    ? "RAIN DETECTED"
                    : "SAFE",
                progress: sensor.rain ? 1.0 : 0.0,
              ),

              const SizedBox(height: 15),


              // SMOKE


              SensorProgressCard(
                icon: Icons.local_fire_department_rounded,
                color: sensor.smoke
                    ? AppColors.danger
                    : AppColors.success,
                title: "Smoke Sensor",
                value: sensor.smoke
                    ? "SMOKE DETECTED"
                    : "NORMAL",
                progress: sensor.smoke ? 1.0 : 0.0,
              ),

              const SizedBox(height: 15),


              // AIR QUALITY


              SensorProgressCard(
                icon: Icons.air_rounded,
                color: AppColors.info,
                title: "Air Quality",
                value: "GOOD",
                progress: 0.85,
              ),

              const SizedBox(height: 15),


              // LIGHT INTENSITY


              SensorProgressCard(
                icon: Icons.light_mode_rounded,
                color: AppColors.warning,
                title: "Light Intensity",
                value: "620 Lux",
                progress: 0.62,
              ),

              const SizedBox(height: 20),


              // LAST UPDATED


              Container(
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.divider,
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: 0.035,
                      ),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),

                child: Row(
                  children: [

                    Container(
                      width: 44,
                      height: 44,

                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(14),
                      ),

                      child: const Icon(
                        Icons.access_time_rounded,
                        color: AppColors.primaryDark,
                        size: 22,
                      ),
                    ),

                    const SizedBox(width: 13),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [

                          Text(
                            "Last Updated",
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 3),

                          Text(
                            "Live data refreshes every 2 seconds",
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}