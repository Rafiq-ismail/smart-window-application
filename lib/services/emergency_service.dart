import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmergencyService {
  EmergencyService._();

  static final EmergencyService instance =
  EmergencyService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // =========================================================
  // TEST EMERGENCY
  // Temporary function for manual testing
  // =========================================================

  Future<bool> createTestEmergency({
    String alertType = 'Smoke Detected',
    String description =
    'Test emergency generated from SmartWindow application.',
    String? roomId,
    String? sensorId,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      return false;
    }

    try {
      await _firestore.collection('emergencies').add({
        'userId': user.uid,
        'roomId': roomId,
        'sensorId': sensorId,
        'alertType': alertType,
        'description': description,
        'status': 'active',
        'acknowledged': false,
        'acknowledgedAt': null,
        'triggeredAt': FieldValue.serverTimestamp(),
        'resolvedAt': null,
        'responseLogs': [],
      });

      return true;
    } catch (e) {
      print('Create Emergency Error: $e');
      return false;
    }
  }

  // =========================================================
  // AUTOMATIC SMOKE EMERGENCY
  // Called when smoke changes FALSE -> TRUE
  // =========================================================

  Future<bool> createSmokeEmergency({
    required int roomNumber,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      return false;
    }

    try {
      final String roomKey = 'room$roomNumber';

      final emergencyRef = _firestore
          .collection('emergencies')
          .doc('smoke_${user.uid}_$roomKey');

      await emergencyRef.set({
        'userId': user.uid,
        'roomId': roomKey,
        'sensorId': 'mq$roomNumber',
        'alertType': 'Smoke Detected',
        'description':
        'Smoke or gas has been detected by the Room $roomNumber sensor.',
        'status': 'active',
        'acknowledged': false,
        'acknowledgedAt': null,
        'triggeredAt': FieldValue.serverTimestamp(),
        'resolvedAt': null,
        'responseLogs': [
          {
            'time': Timestamp.now(),
            'action':
            'Smoke detected automatically in Room $roomNumber',
            'performedBy': 'system',
          },
        ],
      });

      print(
        'ROOM $roomNumber SMOKE EMERGENCY CREATED SUCCESSFULLY',
      );

      return true;
    } catch (e) {
      print(
        'Create Room $roomNumber Smoke Emergency Error: $e',
      );

      return false;
    }
  }

  // =========================================================
  // AUTO RESOLVE SMOKE EMERGENCY
  // Called when smoke changes TRUE -> FALSE
  // =========================================================

  Future<bool> resolveActiveSmokeEmergency({
    required int roomNumber,
    required String ownerUid,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      return false;
    }

    try {
      final String roomKey = 'room$roomNumber';

      final emergencyRef = _firestore
          .collection('emergencies')
          .doc('smoke_${ownerUid}_$roomKey');

      final emergencyDoc = await emergencyRef.get();

      if (!emergencyDoc.exists) {
        print(
          'Room $roomNumber emergency not found for owner $ownerUid',
        );
        return true;
      }

      final data = emergencyDoc.data();

      if (data == null || data['status'] != 'active') {
        print(
          'Room $roomNumber emergency is not active',
        );
        return true;
      }

      await emergencyRef.update({
        'status': 'resolved',
        'resolvedAt': FieldValue.serverTimestamp(),
        'responseLogs': FieldValue.arrayUnion([
          {
            'time': Timestamp.now(),
            'action':
            'Smoke condition in Room $roomNumber returned to normal',
            'performedBy': 'system',
          },
        ]),
      });

      print(
        'ROOM $roomNumber SMOKE EMERGENCY RESOLVED: ${emergencyRef.id}',
      );

      return true;
    } catch (e) {
      print(
        'Resolve Room $roomNumber Smoke Emergency Error: $e',
      );

      return false;
    }
  }
}