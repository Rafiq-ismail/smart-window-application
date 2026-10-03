import 'package:http/http.dart' as http;

class Esp32ControlService {
  Esp32ControlService._();

  static final Esp32ControlService instance =
  Esp32ControlService._();

  static const String _esp32BaseUrl =
      'http://10.88.162.125';

  // ============================================================
  // WINDOW 1
  // ============================================================

  Future<bool> openWindow1() async {
    try {
      final response = await http
          .get(
        Uri.parse('$_esp32BaseUrl/window1/open'),
      )
          .timeout(const Duration(seconds: 5));

      print(
        'ESP32 OPEN response: ${response.statusCode}',
      );
      print(
        'ESP32 OPEN body: ${response.body}',
      );

      return response.statusCode == 200;
    } catch (e) {
      print('ESP32 OPEN error: $e');
      return false;
    }
  }

  Future<bool> closeWindow1() async {
    try {
      final response = await http
          .get(
        Uri.parse('$_esp32BaseUrl/window1/close'),
      )
          .timeout(const Duration(seconds: 5));

      print(
        'ESP32 CLOSE response: ${response.statusCode}',
      );
      print(
        'ESP32 CLOSE body: ${response.body}',
      );

      return response.statusCode == 200;
    } catch (e) {
      print('ESP32 CLOSE error: $e');
      return false;
    }
  }

  Future<bool> setWindow1Position(int percent) async {
    try {
      final safePercent = percent.clamp(0, 100);

      final response = await http
          .get(
        Uri.parse(
          '$_esp32BaseUrl/window1/position?percent=$safePercent',
        ),
      )
          .timeout(const Duration(seconds: 5));

      print(
        'ESP32 WINDOW 1 POSITION response: ${response.statusCode}',
      );
      print(
        'ESP32 WINDOW 1 POSITION body: ${response.body}',
      );

      return response.statusCode == 200;
    } catch (e) {
      print('ESP32 WINDOW 1 POSITION error: $e');
      return false;
    }
  }

  // ============================================================
  // WINDOW 2
  // ============================================================

  Future<bool> openWindow2() async {
    try {
      final response = await http
          .get(
        Uri.parse('$_esp32BaseUrl/window2/open'),
      )
          .timeout(const Duration(seconds: 5));

      print(
        'ESP32 WINDOW 2 OPEN response: ${response.statusCode}',
      );
      print(
        'ESP32 WINDOW 2 OPEN body: ${response.body}',
      );

      return response.statusCode == 200;
    } catch (e) {
      print('ESP32 WINDOW 2 OPEN error: $e');
      return false;
    }
  }

  Future<bool> closeWindow2() async {
    try {
      final response = await http
          .get(
        Uri.parse('$_esp32BaseUrl/window2/close'),
      )
          .timeout(const Duration(seconds: 5));

      print(
        'ESP32 WINDOW 2 CLOSE response: ${response.statusCode}',
      );
      print(
        'ESP32 WINDOW 2 CLOSE body: ${response.body}',
      );

      return response.statusCode == 200;
    } catch (e) {
      print('ESP32 WINDOW 2 CLOSE error: $e');
      return false;
    }
  }

  Future<bool> setWindow2Position(int percent) async {
    try {
      final safePercent = percent.clamp(0, 100);

      final response = await http
          .get(
        Uri.parse(
          '$_esp32BaseUrl/window2/position?percent=$safePercent',
        ),
      )
          .timeout(const Duration(seconds: 5));

      print(
        'ESP32 WINDOW 2 POSITION response: ${response.statusCode}',
      );
      print(
        'ESP32 WINDOW 2 POSITION body: ${response.body}',
      );

      return response.statusCode == 200;
    } catch (e) {
      print('ESP32 WINDOW 2 POSITION error: $e');
      return false;
    }
  }

  // ============================================================
  // WINDOW 3
  // ============================================================

  Future<bool> openWindow3() async {
    try {
      final response = await http
          .get(
        Uri.parse('$_esp32BaseUrl/window3/open'),
      )
          .timeout(const Duration(seconds: 5));

      print(
        'ESP32 WINDOW 3 OPEN response: ${response.statusCode}',
      );
      print(
        'ESP32 WINDOW 3 OPEN body: ${response.body}',
      );

      return response.statusCode == 200;
    } catch (e) {
      print('ESP32 WINDOW 3 OPEN error: $e');
      return false;
    }
  }

  Future<bool> setWindow3Position(int percent) async {
    try {
      final safePercent = percent.clamp(0, 100);

      final response = await http
          .get(
        Uri.parse(
          '$_esp32BaseUrl/window3/position?percent=$safePercent',
        ),
      )
          .timeout(const Duration(seconds: 5));

      print(
        'ESP32 WINDOW 3 POSITION response: ${response.statusCode}',
      );
      print(
        'ESP32 WINDOW 3 POSITION body: ${response.body}',
      );

      return response.statusCode == 200;
    } catch (e) {
      print('ESP32 WINDOW 3 POSITION error: $e');
      return false;
    }
  }

  Future<bool> closeWindow3() async {
    try {
      final response = await http
          .get(
        Uri.parse('$_esp32BaseUrl/window3/close'),
      )
          .timeout(const Duration(seconds: 5));

      print(
        'ESP32 WINDOW 3 CLOSE response: ${response.statusCode}',
      );
      print(
        'ESP32 WINDOW 3 CLOSE body: ${response.body}',
      );

      return response.statusCode == 200;
    } catch (e) {
      print('ESP32 WINDOW 3 CLOSE error: $e');
      return false;
    }
  }
}