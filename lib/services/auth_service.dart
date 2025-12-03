// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:love_notes/exception/auth_exception_handler.dart';

// class AuthService {
//   late AuthResultStatus status;

//   // Login with Email and Password
//   Future<AuthResultStatus> loginWithEmailAndPassword({
//     required String email, 
//     required String password
//   }) async {
//     try {
//       final UserCredential authResult = await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: email, 
//         password: password
//       );

//       if (authResult.user != null) { 
//         status = AuthResultStatus.successful;
//       } else {
//         status = AuthResultStatus.undefined;
//       }
//       return status;
//     } catch (msg) {
//       status = AuthExceptionHandler.handleException(msg);
//     }

//     return status;
//   }

//   Future<AuthResultStatus> signupWithEmailAndPassword({
//     required String name,
//     required String email,
//     required String password,
//   }) async {
//     try {
//       final UserCredential authResult = await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: email, 
//         password: password
//       );

//       if (authResult.user != null) { 
//         saveUserDetails(
//           name: name,
//           email: email,
//           userId: authResult.user!.uid,
//         );
//         status = AuthResultStatus.successful;
//       } else {
//         status = AuthResultStatus.undefined;
//       }
//       return status;
//     } catch (msg) {
//       status = AuthExceptionHandler.handleException(msg);
//     }

//     return status;
//   }

//   void saveUserDetails({required String name, email, userId}) {
//     // Add user details to Firestore
//     FirebaseFirestore.instance.collection('users').doc(userId).set({
//       'name': name,
//       'email': email,
//       'role': 'user',
//       'userId': userId,
//       'lessonsRemaining': 10
//     });
//   }
// }
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthFailure implements Exception {
  final String code;
  final String message;
  const AuthFailure(this.code, this.message);

  @override
  String toString() => 'AuthFailure($code): $message';
}

class AuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _google;

  AuthService({
    FirebaseAuth? auth,
    GoogleSignIn? google,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _google = google ?? GoogleSignIn(scopes: const ['email']);

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(e.code, e.message ?? 'Errore login');
    }
  }

  Future<UserCredential> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(e.code, e.message ?? 'Errore registrazione');
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      // Garantisce che non resti “appeso” un account precedente
      await _google.signOut();

      final account = await _google.signIn();
      if (account == null) {
        throw const AuthFailure('cancelled', 'Accesso annullato');
      }

      final auth = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: auth.idToken,
        accessToken: auth.accessToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(e.code, e.message ?? 'Errore login Google');
    }
  }

  Future<void> signOut() async {
    // Importante: fai signOut sia da Firebase che da GoogleSignIn
    await Future.wait([
      _auth.signOut(),
      _google.signOut(),
    ]);
  }
}
