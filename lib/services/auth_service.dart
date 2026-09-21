import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final AuthService instance = AuthService._();

  AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  // ============================================================
  // SIGN UP
  // ============================================================

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        return false;
      }

      await user.updateDisplayName(name);

      await _firestore.collection('users').doc(user.uid).set({
        'name': name,
        'email': email.trim(),
        'role': 'user',
        'settings': {
          'notifications': true,
          'autoMode': true,
          'darkMode': false,
        },
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });

      return true;
    } on FirebaseAuthException catch (e) {
      print(
        'Firebase Auth Sign Up Error: ${e.code} - ${e.message}',
      );
      return false;
    } catch (e) {
      print('Sign Up Error: $e');
      return false;
    }
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        return false;
      }

      await _firestore.collection('users').doc(user.uid).set(
        {
          'email': user.email ?? email.trim(),
          'name': user.displayName ?? 'User',
          'lastLogin': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      return true;
    } on FirebaseAuthException catch (e) {
      print(
        'Firebase Auth Login Error: ${e.code} - ${e.message}',
      );
      return false;
    } catch (e) {
      print('Login Error: $e');
      return false;
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    await _auth.signOut();
  }

  // ============================================================
  // CHECK LOGIN
  // ============================================================

  Future<bool> isLoggedIn() async {
    return _auth.currentUser != null;
  }

  // ============================================================
  // GET USER NAME
  // ============================================================

  Future<String> getUserName() async {
    final user = _auth.currentUser;

    if (user == null) {
      return 'User';
    }

    if (user.displayName != null &&
        user.displayName!.trim().isNotEmpty) {
      return user.displayName!;
    }

    try {
      final document =
      await _firestore.collection('users').doc(user.uid).get();

      final data = document.data();

      if (data != null) {
        final name = data['name'];

        if (name is String && name.trim().isNotEmpty) {
          return name;
        }
      }
    } catch (e) {
      print('Get User Name Error: $e');
    }

    return 'User';
  }

  // ============================================================
  // GET USER EMAIL
  // ============================================================

  Future<String> getUserEmail() async {
    return _auth.currentUser?.email ?? '';
  }

  // ============================================================
  // GET USER ROLE
  // ============================================================

  Future<String> getUserRole() async {
    final user = _auth.currentUser;

    if (user == null) {
      return 'user';
    }

    try {
      final document =
      await _firestore.collection('users').doc(user.uid).get();

      final data = document.data();

      if (data == null) {
        return 'user';
      }

      final role = data['role'];

      if (role is String && role.trim().isNotEmpty) {
        return role.trim().toLowerCase();
      }

      return 'user';
    } catch (e) {
      print('Get User Role Error: $e');
      return 'user';
    }
  }

  // ============================================================
  // CHECK ADMIN
  // ============================================================

  Future<bool> isAdmin() async {
    final role = await getUserRole();

    return role == 'admin';
  }
}