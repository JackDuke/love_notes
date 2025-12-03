import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:love_notes/model/firestore_user.dart';
import 'package:love_notes/pages/admin_page.dart';
import 'package:love_notes/pages/home_page.dart';
import 'package:love_notes/pages/login_or_signup.dart';

class Auth extends StatelessWidget {
  const Auth({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(), 
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else {
            if (snapshot.hasData) {
              return FutureBuilder(
                future: getUserData(snapshot.data!.uid),
                builder: (context, AsyncSnapshot<FirestoreUser?> userDataSnapshot) {
                  if (userDataSnapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else {
                    if (userDataSnapshot.hasData) {
                      if (userDataSnapshot.data!.role == 'admin') {
                        return AdminPage(user: userDataSnapshot.data!);
                      } else {
                        return HomePage(user: userDataSnapshot.data!);
                      }
                    } else {
                      // Handle error or show loading indicator
                      return const Text('Error retrieving user data');
                    }
                  }
                },
              );
            } else {
              return const LoginOrSignup();
            }
          }
        } 
      ),
    );
  }

  Future<FirestoreUser?> getUserData(String uid) async {
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userSnapshot.exists) {
      return FirestoreUser.fromMap(uid, userSnapshot.data() as Map<String, dynamic>);
    }
    return null;
  }
}