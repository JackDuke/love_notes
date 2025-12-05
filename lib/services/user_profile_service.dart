import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileService {
  final FirebaseFirestore _db;

  UserProfileService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  Future<void> upsertFromAuthUser(User user, {String? name}) async {
    final ref = _db.collection('users').doc(user.uid);

    final provider = user.providerData.isNotEmpty
        ? user.providerData.first.providerId
        : 'unknown';

    await ref.set({
      'uid': user.uid,
      'email': user.email,
      'displayName': name ?? user.displayName,
      'provider': provider,
      // Lo mettiamo sempre: è semplice e non blocca
      'createdAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
