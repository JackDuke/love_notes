import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:love_notes/model/app_user.dart';

class UserRepository {
  final FirebaseFirestore _db;

  UserRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  Stream<AppUser?> watchUser(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      final data = snap.data();
      if (data == null) return null;
      return AppUser.fromMap(data);
    });
  }

  Future<AppUser?> getUser(String uid) async {
    final snap = await _db.collection('users').doc(uid).get();
    if (!snap.exists) return null;
    final data = snap.data();
    if (data == null) return null;
    return AppUser.fromMap(data);
  }
}
