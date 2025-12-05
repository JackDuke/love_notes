import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:love_notes/app.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart'; // Generato da flutterfire

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const App());
}

