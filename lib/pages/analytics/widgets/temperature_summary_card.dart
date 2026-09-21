import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../services/sensor_service.dart';

class TemperatureSummaryCard extends StatelessWidget {
  const TemperatureSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: SensorService.instance.stream,
      builder: (context, snapshot) {
        final temp = SensorService.instance.temperature;

        final highest = temp + 2;
        final lowest = temp - 2;
        final average = temp;

        return Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.thermostat_rounded,
                      color: Colors.orange,
                      size: 23,
                    ),
                  ),

                  const SizedBox(width: 13),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Today's Temperature",
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          "Temperature summary",
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

              const SizedBox(height: 22),

              // VALUES
              Row(
                children: [
                  Expanded(
                    child: _TemperatureItem(
                      title: "Highest",
                      value: "${highest.toStringAsFixed(1)}°C",
                      color: Colors.red,
                    ),
                  ),

                  Container(
                    width: 1,
                    height: 42,
                    color: AppColors.divider,
                  ),

                  Expanded(
                    child: _TemperatureItem(
                      title: "Average",
                      value: "${average.toStringAsFixed(1)}°C",
                      color: Colors.orange,
                    ),
                  ),

                  Container(
                    width: 1,
                    height: 42,
                    color: AppColors.divider,
                  ),

                  Expanded(
                    child: _TemperatureItem(
                      title: "Lowest",
                      value: "${lowest.toStringAsFixed(1)}°C",
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}


// TEMPERATURE ITEM


class _TemperatureItem extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _TemperatureItem({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          title,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}