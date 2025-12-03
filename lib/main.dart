import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:love_notes/app.dart';
// import 'package:love_notes/auth/auth.dart';
import 'package:love_notes/firebase_options.dart';
// import 'package:love_notes/pages/splash_screen.dart';
// import 'package:love_notes/theme/dark_mode.dart';
// import 'package:love_notes/theme/light_mode.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

Future<void> main() async {
  final bindings = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: bindings);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const App());
}

// class MainApp extends StatelessWidget {
//   const MainApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: const SplashScreen(),
//       theme: lightMode,
//       darkTheme: darkMode,
//     );
//   }
// }
