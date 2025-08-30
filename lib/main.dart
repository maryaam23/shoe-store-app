import 'package:flutter/material.dart';
import 'User_Pages/logo_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures Flutter engine is ready
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Initializes Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const LogoScreen(),
      // home: Scaffold(
      //   appBar: AppBar(title: const Text('Firebase Connected!')),
      //   body: const Center(child: Text('Hello Firebase 👋')),
      // ),
    );
  }
}