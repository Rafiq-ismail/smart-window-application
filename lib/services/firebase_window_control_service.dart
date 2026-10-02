import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseWindowControlService {
  FirebaseWindowControlService._();

  static final FirebaseWindowControlService instance =
  FirebaseWindowControlService._();

  final DatabaseReference _commandsRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
    'https://smartwindow-131e5-default-rtdb.asia-southeast1.firebasedatabase.app',
  ).ref('devices/esp32_01/commands');

  Future<void> sendWindow1Command(String action) async {
    try {
      await _commandsRef.child('window1/action').set(action);

      print('Firebase Window1 Command Sent: $action');
    } catch (e) {
      print('Firebase Window1 Command Error: $e');
      rethrow;
    }
  }

  Future<void> openWindow1() async {
    await sendWindow1Command('extend');
  }

  Future<void> closeWindow1() async {
    await sendWindow1Command('retract');
  }

  Future<void> stopWindow1() async {
    await sendWindow1Command('stop');
  }
}