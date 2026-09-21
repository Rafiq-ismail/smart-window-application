import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WindowService {
  WindowService._();

  static final WindowService instance =
  WindowService._();

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
  // ADMIN - GET ALL WINDOWS
  // =========================================================

  Stream<QuerySnapshot<Map<String, dynamic>>>
  getAllWindows() {
    return _firestore
        .collection('windows')
        .snapshots();
  }

  // =========================================================
  // USER - GET OWN WINDOWS
  // =========================================================

  Stream<QuerySnapshot<Map<String, dynamic>>>
  getUserWindows() {
    final userId = currentUserId;

    if (userId == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('windows')
        .where(
      'userId',
      isEqualTo: userId,
    )
        .snapshots();
  }

  // =========================================================
  // ADD WINDOW
  // =========================================================

  Future<bool> addWindow({
    required String name,
    String? roomId,
    String? assignedDeviceId,
  }) async {
    final userId = currentUserId;

    if (userId == null) {
      return false;
    }

    final cleanName = name.trim();

    if (cleanName.isEmpty) {
      return false;
    }

    try {
      await _firestore
          .collection('windows')
          .add({
        'userId': userId,
        'roomId': roomId,
        'name': cleanName,

        // Window state
        'status': 'CLOSED',
        'openingPercentage': 0,

        // ESP32 relationship
        'assignedDeviceId':
        assignedDeviceId,

        // Timestamps
        'createdAt':
        FieldValue.serverTimestamp(),
        'updatedAt':
        FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Add Window Error: $e');
      return false;
    }
  }

  // =========================================================
  // UPDATE WINDOW INFORMATION
  // =========================================================

  Future<bool> updateWindow({
    required String windowId,
    String? name,
    String? roomId,
    String? assignedDeviceId,
  }) async {
    final userId = currentUserId;

    if (userId == null) {
      return false;
    }

    try {
      final windowRef =
      _firestore
          .collection('windows')
          .doc(windowId);

      final windowDocument =
      await windowRef.get();

      if (!windowDocument.exists) {
        return false;
      }

      final data = windowDocument.data();

      if (data == null ||
          data['userId'] != userId) {
        return false;
      }

      final updateData =
      <String, dynamic>{
        'updatedAt':
        FieldValue.serverTimestamp(),
      };

      if (name != null &&
          name.trim().isNotEmpty) {
        updateData['name'] =
            name.trim();
      }

      if (roomId != null) {
        updateData['roomId'] =
            roomId;
      }

      if (assignedDeviceId != null) {
        updateData['assignedDeviceId'] =
            assignedDeviceId;
      }

      await windowRef.update(
        updateData,
      );

      return true;
    } catch (e) {
      print('Update Window Error: $e');
      return false;
    }
  }

  // =========================================================
  // UPDATE WINDOW STATE
  // Future ESP32 integration
  // =========================================================

  Future<bool> updateWindowState({
    required String windowId,
    required int openingPercentage,
  }) async {
    final userId = currentUserId;

    if (userId == null) {
      return false;
    }

    try {
      final windowRef =
      _firestore
          .collection('windows')
          .doc(windowId);

      final windowDocument =
      await windowRef.get();

      if (!windowDocument.exists) {
        return false;
      }

      final data = windowDocument.data();

      if (data == null ||
          data['userId'] != userId) {
        return false;
      }

      final safePercentage =
      openingPercentage.clamp(0, 100);

      String status;

      if (safePercentage == 0) {
        status = 'CLOSED';
      } else {
        status = 'OPEN';
      }

      await windowRef.update({
        'openingPercentage':
        safePercentage,
        'status': status,
        'updatedAt':
        FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print(
        'Update Window State Error: $e',
      );
      return false;
    }
  }

  // =========================================================
  // DELETE WINDOW
  // =========================================================

  Future<bool> deleteWindow(
      String windowId,
      ) async {
    final userId = currentUserId;

    if (userId == null) {
      return false;
    }

    try {
      final windowRef =
      _firestore
          .collection('windows')
          .doc(windowId);

      final windowDocument =
      await windowRef.get();

      if (!windowDocument.exists) {
        return false;
      }

      final data = windowDocument.data();

      if (data == null ||
          data['userId'] != userId) {
        return false;
      }

      await windowRef.delete();

      return true;
    } catch (e) {
      print('Delete Window Error: $e');
      return false;
    }
  }
}