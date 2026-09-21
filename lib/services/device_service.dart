import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DeviceService {
  DeviceService._();

  static final DeviceService instance =
  DeviceService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // =========================================================
  // CURRENT USER
  // =========================================================

  String? get currentUserId =>
      _auth.currentUser?.uid;

  // =========================================================
  // ADMIN - GET ALL DEVICES
  // =========================================================

  Stream<QuerySnapshot<Map<String, dynamic>>>
  getAllDevices() {
    return _firestore
        .collection('devices')
        .snapshots();
  }

  // =========================================================
  // USER - GET OWN DEVICES
  // =========================================================

  Stream<QuerySnapshot<Map<String, dynamic>>>
  getUserDevices() {
    final userId = currentUserId;

    if (userId == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('devices')
        .where(
      'userId',
      isEqualTo: userId,
    )
        .snapshots();
  }

  // =========================================================
  // ADD DEVICE
  // =========================================================

  Future<bool> addDevice({
    required String deviceName,
    required String deviceType,
    String? roomId,
    String? ipAddress,
    String? firmwareVersion,
  }) async {
    final userId = currentUserId;

    if (userId == null) {
      return false;
    }

    final cleanName = deviceName.trim();

    if (cleanName.isEmpty) {
      return false;
    }

    try {
      await _firestore
          .collection('devices')
          .add({
        'userId': userId,
        'roomId': roomId,
        'deviceName': cleanName,
        'deviceType': deviceType.trim(),
        'ipAddress': ipAddress,
        'firmwareVersion': firmwareVersion,

        // Device status
        'connectionStatus': 'offline',
        'signalStrength': null,
        'uptime': 0,

        // ESP32 memory information
        'memoryUsage': {
          'freeHeap': null,
          'totalHeap': null,
        },

        // Relationships
        'managedWindows': <String>[],
        'managedSensors': <String>[],

        // Timestamps
        'createdAt':
        FieldValue.serverTimestamp(),
        'updatedAt':
        FieldValue.serverTimestamp(),
        'lastSeen': null,
      });

      return true;
    } catch (e) {
      print('Add Device Error: $e');
      return false;
    }
  }

  // =========================================================
  // UPDATE DEVICE
  // =========================================================

  Future<bool> updateDevice({
    required String deviceId,
    String? deviceName,
    String? roomId,
    String? ipAddress,
    String? firmwareVersion,
  }) async {
    final userId = currentUserId;

    if (userId == null) {
      return false;
    }

    try {
      final deviceRef =
      _firestore
          .collection('devices')
          .doc(deviceId);

      final deviceDocument =
      await deviceRef.get();

      if (!deviceDocument.exists) {
        return false;
      }

      final data = deviceDocument.data();

      if (data == null ||
          data['userId'] != userId) {
        return false;
      }

      final updateData =
      <String, dynamic>{
        'updatedAt':
        FieldValue.serverTimestamp(),
      };

      if (deviceName != null &&
          deviceName.trim().isNotEmpty) {
        updateData['deviceName'] =
            deviceName.trim();
      }

      if (roomId != null) {
        updateData['roomId'] = roomId;
      }

      if (ipAddress != null) {
        updateData['ipAddress'] =
            ipAddress;
      }

      if (firmwareVersion != null) {
        updateData['firmwareVersion'] =
            firmwareVersion;
      }

      await deviceRef.update(
        updateData,
      );

      return true;
    } catch (e) {
      print('Update Device Error: $e');
      return false;
    }
  }

  // =========================================================
  // UPDATE DEVICE STATUS
  // Future ESP32 integration
  // =========================================================

  Future<bool> updateDeviceStatus({
    required String deviceId,
    required String connectionStatus,
    int? signalStrength,
    int? uptime,
    int? freeHeap,
    int? totalHeap,
  }) async {
    try {
      final updateData =
      <String, dynamic>{
        'connectionStatus':
        connectionStatus,
        'updatedAt':
        FieldValue.serverTimestamp(),
      };

      if (signalStrength != null) {
        updateData['signalStrength'] =
            signalStrength;
      }

      if (uptime != null) {
        updateData['uptime'] = uptime;
      }

      if (freeHeap != null ||
          totalHeap != null) {
        updateData['memoryUsage'] = {
          'freeHeap': freeHeap,
          'totalHeap': totalHeap,
        };
      }

      if (connectionStatus
          .toLowerCase() ==
          'online') {
        updateData['lastSeen'] =
            FieldValue.serverTimestamp();
      }

      await _firestore
          .collection('devices')
          .doc(deviceId)
          .update(updateData);

      return true;
    } catch (e) {
      print(
        'Update Device Status Error: $e',
      );
      return false;
    }
  }

  // =========================================================
  // DELETE DEVICE
  // =========================================================

  Future<bool> deleteDevice(
      String deviceId,
      ) async {
    final userId = currentUserId;

    if (userId == null) {
      return false;
    }

    try {
      final deviceRef =
      _firestore
          .collection('devices')
          .doc(deviceId);

      final deviceDocument =
      await deviceRef.get();

      if (!deviceDocument.exists) {
        return false;
      }

      final data = deviceDocument.data();

      if (data == null ||
          data['userId'] != userId) {
        return false;
      }

      await deviceRef.delete();

      return true;
    } catch (e) {
      print('Delete Device Error: $e');
      return false;
    }
  }
}