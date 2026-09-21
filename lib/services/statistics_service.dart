import 'package:flutter/foundation.dart';

class StatisticsService extends ChangeNotifier {
  static final StatisticsService instance = StatisticsService._();

  StatisticsService._();

  int windowOpenCount = 0;
  int rainCount = 0;
  int smokeCount = 0;

  double totalTemperature = 0;
  int temperatureReadings = 0;

  void addTemperature(double value) {
    totalTemperature += value;
    temperatureReadings++;
    notifyListeners();
  }

  double get averageTemperature {
    if (temperatureReadings == 0) {
      return 0;
    }

    return totalTemperature / temperatureReadings;
  }

  void windowOpened() {
    windowOpenCount++;
    notifyListeners();
  }

  void rainDetected() {
    rainCount++;
    notifyListeners();
  }

  void smokeDetected() {
    smokeCount++;
    notifyListeners();
  }
}