import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreUser {
  final String userId;
  final String name;
  final String email;
  final String nickname;
  final String role;
  final int lessonsRemaining;

  FirestoreUser({required this.userId, required this.name, required this.email, required this.nickname, required this.role, required this.lessonsRemaining});

  factory FirestoreUser.fromMap(String userId, Map<String, dynamic> data) {
    return FirestoreUser(
      userId: userId,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      nickname: data['nickname'] ?? '',
      role: data['role'] ?? '',
      lessonsRemaining: data['lessonsRemaining'] ?? 10,
    );
  }

  factory FirestoreUser.fromDocument(DocumentSnapshot doc) {
    return FirestoreUser(
      userId: doc.id,
      name: doc['name'],
      email: doc['email'],
      nickname: doc['nickname'],
      role: doc['role'], 
      lessonsRemaining: doc['lessonsRemaining'],
    );
  }

  @override
  String toString() {
    return 'FirestoreUser {userId: $userId, name: $name, email: $email, nickname: $nickname, role: $role, lessonsRemaining: $lessonsRemaining}';
  }
}