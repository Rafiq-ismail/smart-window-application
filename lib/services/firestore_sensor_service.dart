import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreSensorService {
  FirestoreSensorService._();

  static final FirestoreSensorService instance =
  FirestoreSensorService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  String? get currentUserId =>
      _auth.currentUser?.uid;

  // =========================================================
  // USER - GET OWN SENSORS
  // =========================================================

  Stream<QuerySnapshot<Map<String, dynamic>>>
  getUserSensors() {
    final userId = currentUserId;

    if (userId == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('sensors')
        .where(
      'userId',
      isEqualTo: userId,
    )
        .snapshots();
  }

  // =========================================================
  // ADMIN - GET ALL SENSORS
  // =========================================================

  Stream<QuerySnapshot<Map<String, dynamic>>>
  getAllSensors() {
    return _firestore
        .collection('sensors')
        .snapshots();
  }

  // =========================================================
  // CREATE SENSOR
  // =========================================================

  Future<String?> addSensor({
    required String name,
    required String type,
    required String unit,
    String? roomId,
    String? deviceId,
  }) async {
    final userId = currentUserId;

    if (userId == null) {
      return null;
    }

    final cleanName = name.trim();

    if (cleanName.isEmpty) {
      return null;
    }

    try {
      final document = await _firestore
          .collection('sensors')
          .add({
        'userId': userId,
        'roomId': roomId,
        'deviceId': deviceId,
        'name': cleanName,
        'type': type.trim(),
        'currentValue': null,
        'unit': unit.trim(),
        'status': 'offline',
        'createdAt':
        FieldValue.serverTimestamp(),
        'updatedAt':
        FieldValue.serverTimestamp(),
      });

      return document.id;
    } catch (e) {
      print('Add Sensor Error: $e');
      return null;
    }
  }

  // =========================================================
// CREATE DEFAULT SMART WINDOW SENSORS
// =========================================================

  Future<bool> createDefaultSensors({
    String? deviceId,
  }) async {
    final userId = currentUserId;

    if (userId == null) {
      return false;
    }

    try {
      // Check existing sensors first.
      // This prevents duplicate sensors every time
      // the application starts.
      final existingSensors = await _firestore
          .collection('sensors')
          .where(
        'userId',
        isEqualTo: userId,
      )
          .get();

      if (existingSensors.docs.isNotEmpty) {
        return true;
      }

      final batch = _firestore.batch();

      final sensors = [
        {
          'name': 'Temperature Sensor',
          'type': 'temperature',
          'unit': '°C',
          'currentValue': null,
        },
        {
          'name': 'Humidity Sensor',
          'type': 'humidity',
          'unit': '%',
          'currentValue': null,
        },
        {
          'name': 'Rain Sensor',
          'type': 'rain',
          'unit': 'boolean',
          'currentValue': null,
        },
        {
          'name': 'Smoke Sensor',
          'type': 'smoke',
          'unit': 'boolean',
          'currentValue': null,
        },
      ];

      for (final sensor in sensors) {
        final sensorRef =
        _firestore.collection('sensors').doc();

        batch.set(
          sensorRef,
          {
            'userId': userId,
            'roomId': null,
            'deviceId': deviceId,

            'name': sensor['name'],
            'type': sensor['type'],
            'unit': sensor['unit'],
            'currentValue':
            sensor['currentValue'],

            // No physical hardware yet.
            'status': 'simulated',

            'createdAt':
            FieldValue.serverTimestamp(),
            'updatedAt':
            FieldValue.serverTimestamp(),
          },
        );
      }

      await batch.commit();

      return true;
    } catch (e) {
      print(
        'Create Default Sensors Error: $e',
      );

      return false;
    }
  }

  // =========================================================
  // UPDATE CURRENT SENSOR VALUE
  // =========================================================

  Future<bool> updateSensorValue({
    required String sensorId,
    required dynamic value,
    String status = 'online',
  }) async {
    final userId = currentUserId;

    if (userId == null) {
      return false;
    }

    try {
      final sensorRef = _firestore
          .collection('sensors')
          .doc(sensorId);

      final sensorDocument =
      await sensorRef.get();

      if (!sensorDocument.exists) {
        return false;
      }

      final data = sensorDocument.data();

      if (data == null ||
          data['userId'] != userId) {
        return false;
      }

      await sensorRef.update({
        'currentValue': value,
        'status': status,
        'updatedAt':
        FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print(
        'Update Sensor Value Error: $e',
      );
      return false;
    }
  }
}
