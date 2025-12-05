import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:love_notes/pages/home_page.dart';
import 'package:love_notes/pages/login_page.dart';

class AuthGuard extends StatelessWidget {
  const AuthGuard({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Se l'utente è loggato, mostra la Home
        if (snapshot.hasData) {
          return const HomePage();
        }
        // Altrimenti mostra il Login
        return const LoginPage();
      },
    );
  }
}