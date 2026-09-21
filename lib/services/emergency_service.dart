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

  Future<bool> createSmokeEmergency() async {
    final user = _auth.currentUser;

    if (user == null) {
      return false;
    }

    try {
      // Prevent duplicate ACTIVE smoke emergencies.
      final existing =
      await _firestore
          .collection('emergencies')
          .where(
        'userId',
        isEqualTo: user.uid,
      )
          .get();

      final alreadyActive = existing.docs.any((doc) {
        final data = doc.data();

        return data['alertType'] == 'Smoke Detected' &&
            data['status'] == 'active';
      });

      if (alreadyActive) {
        return true;
      }

      await _firestore.collection('emergencies').add({
        'userId': user.uid,

        // Temporary until dynamic rooms are connected.
        'roomId': null,
        'sensorId': null,

        'alertType': 'Smoke Detected',
        'description':
        'Smoke has been detected by the SmartWindow sensor simulation.',

        'status': 'active',

        'acknowledged': false,
        'acknowledgedAt': null,

        'triggeredAt':
        FieldValue.serverTimestamp(),

        'resolvedAt': null,

        'responseLogs': [
          {
            'time': Timestamp.now(),
            'action':
            'Smoke detected automatically by system',
            'performedBy': 'system',
          },
        ],
      });

      return true;
    } catch (e) {
      print('Create Smoke Emergency Error: $e');
      return false;
    }
  }

  // =========================================================
  // AUTO RESOLVE SMOKE EMERGENCY
  // Called when smoke changes TRUE -> FALSE
  // =========================================================

  Future<bool> resolveActiveSmokeEmergency() async {
    final user = _auth.currentUser;

    if (user == null) {
      return false;
    }

    try {
      final query =
      await _firestore
          .collection('emergencies')
          .where(
        'userId',
        isEqualTo: user.uid,
      )
          .get();

      final activeSmokeEmergencies =
      query.docs.where((doc) {
        final data = doc.data();

        return data['alertType'] == 'Smoke Detected' &&
            data['status'] == 'active';
      }).toList();

      if (activeSmokeEmergencies.isEmpty) {
        return true;
      }

      for (final document
      in activeSmokeEmergencies) {
        await document.reference.update({
          'status': 'resolved',
          'resolvedAt':
          FieldValue.serverTimestamp(),
          'responseLogs':
          FieldValue.arrayUnion([
            {
              'time': Timestamp.now(),
              'action':
              'Smoke condition returned to normal',
              'performedBy': 'system',
            },
          ]),
        });
      }

      return true;
    } catch (e) {
      print('Resolve Smoke Emergency Error: $e');
      return false;
    }
  }
}