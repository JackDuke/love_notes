import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:love_notes/exception/auth_exception_handler.dart';

class AuthService {
  late AuthResultStatus status;

  // Login with Email and Password
  Future<AuthResultStatus> loginWithEmailAndPassword({
    required String email, 
    required String password
  }) async {
    try {
      final UserCredential authResult = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email, 
        password: password
      );

      if (authResult.user != null) { 
        status = AuthResultStatus.successful;
      } else {
        status = AuthResultStatus.undefined;
      }
      return status;
    } catch (msg) {
      status = AuthExceptionHandler.handleException(msg);
    }

    return status;
  }

  Future<AuthResultStatus> signupWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential authResult = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );

      if (authResult.user != null) { 
        saveUserDetails(
          name: name,
          email: email,
          userId: authResult.user!.uid,
        );
        status = AuthResultStatus.successful;
      } else {
        status = AuthResultStatus.undefined;
      }
      return status;
    } catch (msg) {
      status = AuthExceptionHandler.handleException(msg);
    }

    return status;
  }

  void saveUserDetails({required String name, email, userId}) {
    // Add user details to Firestore
    FirebaseFirestore.instance.collection('users').doc(userId).set({
      'name': name,
      'email': email,
      'role': 'user',
      'userId': userId,
      'lessonsRemaining': 10
    });
  }
}