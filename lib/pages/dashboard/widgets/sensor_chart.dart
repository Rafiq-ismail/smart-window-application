import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../services/sensor_service.dart';

class SensorChart extends StatefulWidget {
  const SensorChart({super.key});

  @override
  State<SensorChart> createState() => _SensorChartState();
}

class _SensorChartState extends State<SensorChart> {

  final List<FlSpot> points = [];

  @override
  void initState() {
    super.initState();

    SensorService.instance.stream.listen((_) {

      if (!mounted) return;

      setState(() {

        if (points.length > 15) {
          points.removeAt(0);
        }

        points.add(
          FlSpot(
            points.length.toDouble(),
            SensorService.instance.temperature,
          ),
        );

      });

    });
  }

  @override
  Widget build(BuildContext context) {

    return Card(

      elevation: 5,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),

      child: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const Text(
              "Temperature History",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(

              height: 220,

              child: LineChart(

                LineChartData(

                  borderData: FlBorderData(show: false),

                  gridData: const FlGridData(show: true),

                  titlesData: const FlTitlesData(show: false),

                  minY: 20,

                  maxY: 35,

                  lineBarsData: [

                    LineChartBarData(

                      spots: points,

                      isCurved: true,

                      barWidth: 4,

                      dotData: const FlDotData(show: false),

                    ),

                  ],

                ),

              ),

            ),

          ],

        ),

      ),

    );

  }

}