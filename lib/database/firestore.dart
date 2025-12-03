import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreDatabase {

  User? user = FirebaseAuth.instance.currentUser;

  final CollectionReference posts = FirebaseFirestore.instance.collection('Posts');

  Future<void> addPost(String message) {
    return posts.add({
      'email' : user!.email,
      'message' : message,
      'date': Timestamp.now(),
    });
  }

  Stream<QuerySnapshot> getPosts() {
    final posts = FirebaseFirestore.instance.collection('Posts').orderBy('date').snapshots();

    return posts;
  }

}