import 'dart:async';
import 'package:flutter/material.dart';

class LogoScreen extends StatefulWidget {
  const LogoScreen({super.key});

  @override
  State<LogoScreen> createState() => _LogoScreenState();
}

class _LogoScreenState extends State<LogoScreen>
    with TickerProviderStateMixin {
  AnimationController? _logoController;
  Animation<double>? _logoAnimation;

  AnimationController? _textController;
  Animation<Offset>? _textAnimation;

  @override
  void initState() {
    super.initState();

    // ✅ Initialize logo animation controller
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // ✅ Animation curve for logo
    _logoAnimation = CurvedAnimation(
      parent: _logoController!,
      curve: Curves.easeInOutBack,
    );

    // ✅ Initialize text animation controller
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    // ✅ Text slides up
    _textAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // starts below screen
      end: Offset.zero, // moves to normal position
    ).animate(CurvedAnimation(
      parent: _textController!,
      curve: Curves.easeOut,
    ));

    // ✅ Start animations
    _logoController!.forward().whenComplete(() {
      _textController!.forward();
    });

    // ✅ Navigate after 4s
    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    });
  }

  @override
  void dispose() {
    _logoController?.dispose();
    _textController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo animation with fallback
            ScaleTransition(
              scale: _logoAnimation ?? const AlwaysStoppedAnimation(1.0),
              child: Image.asset(
                "assets/logo.jpg", // ✅ Make sure this file exists in pubspec.yaml
                height: 120,
                width: 120,
              ),
            ),
            const SizedBox(height: 20),

            // App title animation with fallback
            SlideTransition(
              position: _textAnimation ??
                  const AlwaysStoppedAnimation(Offset.zero),
              child: const Text(
                "SPORT BRANDS",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 5),

            // Arabic subtitle animation with fallback
            SlideTransition(
              position: _textAnimation ??
                  const AlwaysStoppedAnimation(Offset.zero),
              child: const Text(
                "ماركات عالمية",
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ Dummy home screen to test navigation
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          "Welcome to Sport Brands 👟",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
