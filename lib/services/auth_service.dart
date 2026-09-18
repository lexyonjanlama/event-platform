import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<AppUser?> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    User? firebaseUser;

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      firebaseUser = credential.user;

      if (firebaseUser == null) {
        return null;
      }

      final appUser = AppUser(
        uid: firebaseUser.uid,
        name: name.trim(),
        email: email.trim(),
        role: role,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set(appUser.toMap());

      return appUser;
    } catch (e) {
      // If Firebase Auth account was created but the Firestore
      // profile failed, remove the Auth account so the user
      // can safely try again.
      if (firebaseUser != null) {
        try {
          await firebaseUser.delete();
        } catch (_) {}
      }

      rethrow;
    }
  }

  Future<AppUser?> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final firebaseUser = credential.user;

    if (firebaseUser == null) {
      return null;
    }

    return getUser(firebaseUser.uid);
  }

  Future<AppUser?> getUser(String uid) async {
    final document = await _firestore
        .collection('users')
        .doc(uid)
        .get();

    if (!document.exists || document.data() == null) {
      return null;
    }

    return AppUser.fromMap(document.data()!);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}