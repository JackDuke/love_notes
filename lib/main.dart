import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import 'package:love_notes/auth/auth.dart';
import 'package:love_notes/firebase_options.dart';
import 'package:love_notes/pages/splash_screen.dart';
import 'package:love_notes/theme/dark_mode.dart';
import 'package:love_notes/theme/light_mode.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      theme: lightMode,
      darkTheme: darkMode,
    );
  }
}
