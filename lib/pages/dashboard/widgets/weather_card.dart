import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../services/sensor_service.dart';

class WeatherCard extends StatelessWidget {
  const WeatherCard({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: SensorService.instance.stream,
      builder: (context, snapshot) {
        final sensor = SensorService.instance;

        final bool isRaining = sensor.rain;

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // HEADER


              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isRaining
                          ? Icons.cloudy_snowing
                          : Icons.wb_sunny_rounded,
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
                          "Weather",
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          "Current environment",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Rain status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: isRaining
                          ? const Color(0xFFFFF1E4)
                          : AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isRaining
                              ? Icons.water_drop
                              : Icons.check_circle,
                          size: 14,
                          color: isRaining
                              ? AppColors.warning
                              : AppColors.success,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isRaining ? "Rain" : "Clear",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isRaining
                                ? AppColors.warning
                                : AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),


              // TEMPERATURE


              Row(
                crossAxisAlignment:
                CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.thermostat_rounded,
                    color: AppColors.temperature,
                    size: 30,
                  ),

                  const SizedBox(width: 8),

                  Text(
                    "${sensor.temperature.toStringAsFixed(1)}°",
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(width: 10),

                  const Text(
                    "C",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),


              // HUMIDITY


              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F3),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3EBE7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.water_drop_outlined,
                        color: AppColors.humidity,
                        size: 21,
                      ),
                    ),

                    const SizedBox(width: 12),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Humidity",
                            style: TextStyle(
                              color:
                              AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            "Current humidity level",
                            style: TextStyle(
                              color:
                              AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Text(
                      "${sensor.humidity.toStringAsFixed(0)}%",
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),


              // RAIN SENSOR


              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: isRaining
                      ? const Color(0xFFFFF5EB)
                      : const Color(0xFFF5F6F3),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isRaining
                            ? const Color(0xFFFFE8D2)
                            : AppColors.primaryLight,
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.cloud_outlined,
                        color: isRaining
                            ? AppColors.warning
                            : AppColors.rain,
                        size: 21,
                      ),
                    ),

                    const SizedBox(width: 12),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Rain Sensor",
                            style: TextStyle(
                              color:
                              AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            "Outdoor condition",
                            style: TextStyle(
                              color:
                              AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Text(
                      isRaining
                          ? "Detected"
                          : "No Rain",
                      style: TextStyle(
                        color: isRaining
                            ? AppColors.warning
                            : AppColors.success,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}