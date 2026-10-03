import 'package:http/http.dart' as http;

class Esp32ControlService {
  Esp32ControlService._();

  static final Esp32ControlService instance = Esp32ControlService._();

  static const String _esp32BaseUrl = 'http://10.88.162.125';

  Future<bool> openWindow1() async {
    try {
      final response = await http
          .get(Uri.parse('$_esp32BaseUrl/window1/open'))
          .timeout(const Duration(seconds: 5));

      print('ESP32 OPEN response: ${response.statusCode}');
      print('ESP32 OPEN body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('ESP32 OPEN error: $e');
      return false;
    }
  }

  Future<bool> closeWindow1() async {
    try {
      final response = await http
          .get(Uri.parse('$_esp32BaseUrl/window1/close'))
          .timeout(const Duration(seconds: 5));

      print('ESP32 CLOSE response: ${response.statusCode}');
      print('ESP32 CLOSE body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('ESP32 CLOSE error: $e');
      return false;
    }
  }
}