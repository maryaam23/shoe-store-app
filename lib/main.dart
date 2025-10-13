import 'package:flutter/material.dart';
import 'User_Pages/logo_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'User_Pages/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

late final FirebaseFirestore firestore; // Make it globally accessible

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Use the default Firestore database
  firestore = FirebaseFirestore.instance;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const LogoScreen(),
    );
  }
}
