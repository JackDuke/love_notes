import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String? email;
  final String? displayName;
  // final String? photoUrl;
  final String? provider;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  const AppUser({
    required this.uid,
    this.email,
    this.displayName,
    // this.photoUrl,
    this.provider,
    this.createdAt,
    this.lastLoginAt,
  });

  static DateTime? _toDate(dynamic v) {
    if (v == null) return null;
    if (v is Timestamp) return v.toDate();
    return null;
  }

  factory AppUser.fromMap(Map<String, dynamic> data) {
    return AppUser(
      uid: (data['uid'] ?? '') as String,
      email: data['email'] as String?,
      displayName: data['displayName'] as String?,
      // photoUrl: data['photoUrl'] as String?,
      provider: data['provider'] as String?,
      createdAt: _toDate(data['createdAt']),
      lastLoginAt: _toDate(data['lastLoginAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        // 'photoUrl': photoUrl,
        'provider': provider,
        // i timestamp di solito li setti dal server, quindi qui non li mettiamo
      };
}
