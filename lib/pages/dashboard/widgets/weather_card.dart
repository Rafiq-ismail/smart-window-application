import 'package:flutter/material.dart';

import '../../../services/sensor_service.dart';

class WeatherCard extends StatelessWidget {
  const WeatherCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder(
      stream: SensorService.instance.stream,
      builder: (context, snapshot) {
        final sensor = SensorService.instance;
        final bool isRaining = sensor.rain;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),

          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(24),

            border: Border.all(
              color: colors.outlineVariant,
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: isDark ? 0.12 : 0.04,
                ),
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
                      color: isRaining
                          ? Colors.orange.withValues(
                        alpha: isDark ? 0.14 : 0.10,
                      )
                          : colors.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),

                    child: Icon(
                      isRaining
                          ? Icons.cloudy_snowing
                          : Icons.wb_sunny_rounded,
                      color: isRaining
                          ? Colors.orange
                          : colors.primary,
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
                          "Weather",
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          "Current environment",
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // RAIN STATUS
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),

                    decoration: BoxDecoration(
                      color: isRaining
                          ? Colors.orange.withValues(
                        alpha: isDark ? 0.14 : 0.10,
                      )
                          : colors.primaryContainer,
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
                              ? Colors.orange
                              : colors.primary,
                        ),

                        const SizedBox(width: 5),

                        Text(
                          isRaining ? "Rain" : "Clear",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isRaining
                                ? Colors.orange
                                : colors.primary,
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.thermostat_rounded,
                    color: Colors.orange,
                    size: 30,
                  ),

                  const SizedBox(width: 8),

                  Text(
                    "${sensor.temperature.toStringAsFixed(1)}°",
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Text(
                    "C",
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
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
                  color: isDark
                      ? colors.primaryContainer
                      .withValues(alpha: 0.32)
                      : colors.surfaceContainerHighest
                      .withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(17),

                  border: Border.all(
                    color: colors.outlineVariant,
                  ),
                ),

                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,

                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(
                          alpha: isDark ? 0.14 : 0.10,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: const Icon(
                        Icons.water_drop_outlined,
                        color: Colors.blue,
                        size: 21,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Humidity",
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            "Current humidity level",
                            style: TextStyle(
                              color: colors.onSurface,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Text(
                      "${sensor.humidity.toStringAsFixed(0)}%",
                      style: TextStyle(
                        color: Colors.blue,
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
                      ? Colors.orange.withValues(
                    alpha: isDark ? 0.10 : 0.07,
                  )
                      : isDark
                      ? colors.primaryContainer
                      .withValues(alpha: 0.32)
                      : colors.surfaceContainerHighest
                      .withValues(alpha: 0.55),

                  borderRadius: BorderRadius.circular(17),

                  border: Border.all(
                    color: isRaining
                        ? Colors.orange.withValues(
                      alpha: isDark ? 0.20 : 0.14,
                    )
                        : colors.outlineVariant,
                  ),
                ),

                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,

                      decoration: BoxDecoration(
                        color: isRaining
                            ? Colors.orange.withValues(
                          alpha: isDark ? 0.16 : 0.12,
                        )
                            : colors.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: Icon(
                        Icons.cloud_outlined,
                        color: isRaining
                            ? Colors.orange
                            : colors.primary,
                        size: 21,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Rain Sensor",
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            "Outdoor condition",
                            style: TextStyle(
                              color: colors.onSurface,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Text(
                      isRaining ? "Detected" : "No Rain",
                      style: TextStyle(
                        color: isRaining
                            ? Colors.orange
                            : colors.primary,
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