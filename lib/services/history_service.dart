import 'package:fl_chart/fl_chart.dart';

class HistoryService {
  static final HistoryService instance = HistoryService._();

  HistoryService._();

  final List<FlSpot> temperatureHistory = [];

  final List<FlSpot> humidityHistory = [];

  double index = 0;

  void addData(double temperature, double humidity) {
    temperatureHistory.add(
      FlSpot(index, temperature),
    );

    humidityHistory.add(
      FlSpot(index, humidity),
    );

    index++;

    if (temperatureHistory.length > 20) {
      temperatureHistory.removeAt(0);
    }

    if (humidityHistory.length > 20) {
      humidityHistory.removeAt(0);
    }
  }
}