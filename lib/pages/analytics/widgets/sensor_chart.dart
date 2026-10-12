import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../services/history_service.dart';
import '../../../services/sensor_service.dart';

class SensorChart extends StatelessWidget {
  const SensorChart({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder(
      stream: SensorService.instance.stream,
      builder: (context, snapshot) {
        final history = HistoryService.instance;

        return Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Sensor Analytics",
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          "Temperature & Humidity",
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.circular(12),
                      color: colors.primaryContainer,
                    ),
                    child: Icon(
                      Icons.analytics_outlined,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // CURRENT VALUES
              Row(
                children: [
                  Expanded(
                    child: _SensorValue(
                      title: "Temperature",
                      value:
                      "${SensorService.instance.temperature.toStringAsFixed(1)}°C",
                      icon: Icons.thermostat,
                      color: Colors.orange,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _SensorValue(
                      title: "Humidity",
                      value:
                      "${SensorService.instance.humidity.toStringAsFixed(0)}%",
                      icon: Icons.water_drop,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // CHART
              SizedBox(
                height: 250,
                child: LineChart(
                  LineChartData(
                    minY: 20,
                    maxY: 100,

                    backgroundColor: Colors.transparent,

                    // GRID
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 20,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: colors.outlineVariant
                              .withValues(
                            alpha: isDark ? 0.55 : 0.70,
                          ),
                          strokeWidth: 1,
                        );
                      },
                    ),

                    // BORDER
                    borderData: FlBorderData(
                      show: false,
                    ),

                    // AXIS
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false,
                        ),
                      ),

                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false,
                        ),
                      ),

                      bottomTitles: const AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false,
                        ),
                      ),

                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 35,
                          interval: 20,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                fontSize: 11,
                                color:
                                colors.onSurfaceVariant,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // TOUCH
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData:
                      LineTouchTooltipData(
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            return LineTooltipItem(
                              spot.y.toStringAsFixed(1),
                              const TextStyle(
                                color: Colors.white,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),

                    // LINES
                    lineBarsData: [
                      // TEMPERATURE
                      LineChartBarData(
                        spots: history.temperatureHistory,
                        isCurved: true,
                        color: Colors.orange,
                        barWidth: 3,
                        isStrokeCapRound: true,

                        dotData: const FlDotData(
                          show: false,
                        ),

                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.orange.withValues(
                            alpha: isDark ? 0.10 : 0.08,
                          ),
                        ),
                      ),

                      // HUMIDITY
                      LineChartBarData(
                        spots: history.humidityHistory,
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 3,
                        isStrokeCapRound: true,

                        dotData: const FlDotData(
                          show: false,
                        ),

                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.blue.withValues(
                            alpha: isDark ? 0.09 : 0.06,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // LEGEND
              Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: const [
                  _LegendItem(
                    color: Colors.orange,
                    text: "Temperature",
                  ),

                  SizedBox(width: 25),

                  _LegendItem(
                    color: Colors.blue,
                    text: "Humidity",
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


// SENSOR VALUE CARD

class _SensorValue extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SensorValue({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color.withValues(
          alpha: isDark ? 0.12 : 0.08,
        ),
        border: Border.all(
          color: color.withValues(
            alpha: isDark ? 0.16 : 0.08,
          ),
        ),
      ),

      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(
                alpha: isDark ? 0.18 : 0.15,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// LEGEND

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendItem({
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 7),

        Text(
          text,
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}