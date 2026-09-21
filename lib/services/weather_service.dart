import 'dart:math';

class WeatherService {
  static final WeatherService instance = WeatherService._();

  WeatherService._();

  final Random random = Random();

  double temperature = 30;
  double humidity = 70;
  double windSpeed = 8;

  String condition = "Sunny";

  void updateWeather() {
    temperature = 27 + random.nextInt(8).toDouble();

    humidity = 60 + random.nextInt(30).toDouble();

    windSpeed = 3 + random.nextInt(12).toDouble();

    final conditions = [
      "Sunny",
      "Cloudy",
      "Rainy",
      "Windy",
    ];

    condition = conditions[random.nextInt(conditions.length)];
  }
}