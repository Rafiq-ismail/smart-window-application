import 'package:flutter/material.dart';

import '../../../services/sensor_service.dart';

class DashboardSummaryCard extends StatelessWidget {
  const DashboardSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder(
      stream: SensorService.instance.stream,
      builder: (context, snapshot) {
        return Container(
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
              // HEADER
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,

                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(13),
                    ),

                    child: Icon(
                      Icons.dashboard_rounded,
                      color: colors.primary,
                      size: 22,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      "System Summary",
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // SUMMARY VALUES
              Row(
                children: [
                  Expanded(
                    child: _SummaryItem(
                      icon: Icons.thermostat_rounded,
                      value:
                      "${SensorService.instance.temperature.toStringAsFixed(1)}°C",
                      label: "Temp",
                      color: Colors.orange,
                    ),
                  ),

                  Container(
                    width: 1,
                    height: 65,
                    color: colors.outlineVariant,
                  ),

                  Expanded(
                    child: _SummaryItem(
                      icon: Icons.water_drop_rounded,
                      value:
                      "${SensorService.instance.humidity.toStringAsFixed(0)}%",
                      label: "Humidity",
                      color: Colors.blue,
                    ),
                  ),

                  Container(
                    width: 1,
                    height: 65,
                    color: colors.outlineVariant,
                  ),

                  Expanded(
                    child: _SummaryItem(
                      icon: Icons.window_rounded,
                      value:
                      SensorService.instance.windowOpen
                          ? "OPEN"
                          : "CLOSED",
                      label: "Window",
                      color:
                      SensorService.instance.windowOpen
                          ? Colors.green
                          : Colors.red,
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


// SUMMARY ITEM

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _SummaryItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          width: 48,
          height: 48,

          decoration: BoxDecoration(
            color: color.withValues(
              alpha: isDark ? 0.14 : 0.12,
            ),
            borderRadius: BorderRadius.circular(15),
          ),

          child: Icon(
            icon,
            color: color,
            size: 23,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          label,
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}