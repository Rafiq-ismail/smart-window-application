import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RoomService {
  RoomService._();

  static final RoomService instance = RoomService._();

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
  // GET USER ROOMS - REAL TIME
  // =========================================================

  Stream<QuerySnapshot<Map<String, dynamic>>>
  getUserRooms() {
    final userId = currentUserId;

    if (userId == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('rooms')
        .where(
      'userId',
      isEqualTo: userId,
    )
        .snapshots();
  }

  // =========================================================
  // ADD ROOM
  // =========================================================

  Future<bool> addRoom({
    required String name,
    String icon = 'room',
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
          .collection('rooms')
          .add({
        'userId': userId,
        'name': cleanName,
        'icon': icon,
        'createdAt':
        FieldValue.serverTimestamp(),
        'updatedAt':
        FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Add Room Error: $e');
      return false;
    }
  }

  // =========================================================
  // UPDATE ROOM
  // =========================================================

  Future<bool> updateRoom({
    required String roomId,
    required String name,
    String? icon,
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
      final roomRef =
      _firestore
          .collection('rooms')
          .doc(roomId);

      final roomDocument =
      await roomRef.get();

      if (!roomDocument.exists) {
        return false;
      }

      final data = roomDocument.data();

      if (data == null ||
          data['userId'] != userId) {
        return false;
      }

      final updateData =
      <String, dynamic>{
        'name': cleanName,
        'updatedAt':
        FieldValue.serverTimestamp(),
      };

      if (icon != null) {
        updateData['icon'] = icon;
      }

      await roomRef.update(updateData);

      return true;
    } catch (e) {
      print('Update Room Error: $e');
      return false;
    }
  }

  // =========================================================
  // DELETE ROOM
  // =========================================================

  Future<bool> deleteRoom(
      String roomId,
      ) async {
    final userId = currentUserId;

    if (userId == null) {
      return false;
    }

    try {
      final roomRef =
      _firestore
          .collection('rooms')
          .doc(roomId);

      final roomDocument =
      await roomRef.get();

      if (!roomDocument.exists) {
        return false;
      }

      final data = roomDocument.data();

      if (data == null ||
          data['userId'] != userId) {
        return false;
      }

      await roomRef.delete();

      return true;
    } catch (e) {
      print('Delete Room Error: $e');
      return false;
    }
  }
}