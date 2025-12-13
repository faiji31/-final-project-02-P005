// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Stream to track the user's sign-in status in real-time
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // 1. Sign Up with Email and Password
  Future<String?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Success, no error message
      return null;
    } on FirebaseAuthException catch (e) {
      // Return a user-friendly error message
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      }
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // 2. Login with Email and Password
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Success, no error message
      return null;
    } on FirebaseAuthException catch (e) {
      // Return a user-friendly error message
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user.';
      }
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // 3. Log Out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // Get current user (can be null)
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }
}