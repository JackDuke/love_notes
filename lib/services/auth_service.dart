import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'user_profile_service.dart';

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
  final UserProfileService _profile;

  AuthService({
    FirebaseAuth? auth,
    GoogleSignIn? google,
    UserProfileService? profile,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _google = google ?? GoogleSignIn(scopes: const ['email']),
        _profile = profile ?? UserProfileService();

  Stream<User?> authStateChanges() => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth
          .signInWithEmailAndPassword(
            email: email.trim(),
            password: password,
          )
          .timeout(
            const Duration(seconds: 20),
            onTimeout: () => throw const AuthFailure(
              'timeout',
              'Timeout di rete durante il login. Controlla la connessione.',
            ),
          );

      final user = cred.user;
      if (user != null) {
        try {
          await _profile
              .upsertFromAuthUser(user)
              .timeout(const Duration(seconds: 10));
        } catch (e) {
          // non bloccare il login se Firestore dà problemi
          // ignore: avoid_print
          print('Profile upsert failed: $e');
        }
      }

      return cred;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(e.code, e.message ?? 'Errore login');
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      await _google.signOut();

      final account = await _google.signIn();
      if (account == null) {
        throw const AuthFailure('cancelled', 'Accesso annullato');
      }

      final gAuth = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: gAuth.idToken,
        accessToken: gAuth.accessToken,
      );

      final cred = await _auth.signInWithCredential(credential);

      final user = cred.user;
      if (user != null) {
        _profile.upsertFromAuthUser(user).catchError((e) {
          // non bloccare il login
          // ignore: avoid_print
          print('Profile upsert failed: $e');
        });
      }

      return cred;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(e.code, e.message ?? 'Errore login Google');
    }
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _google.signOut(),
    ]);
  }
}
