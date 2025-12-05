import 'package:flutter/material.dart';
import 'package:love_notes/auth/auth_guard.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Noi Due',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink), // Un po' di tema romantico
        useMaterial3: true,
      ),
      home: const AuthGuard(),
    );
  }
}