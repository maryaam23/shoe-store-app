import 'dart:async';
import 'package:flutter/material.dart';
import 'login_page.dart';

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

  bool _showWelcome = false; // ✅ to control welcome message fade-in

  @override
  void initState() {
    super.initState();

    // ✅ Logo animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _logoAnimation = CurvedAnimation(
      parent: _logoController!,
      curve: Curves.easeInOutBack,
    );

    // ✅ Text animation
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _textAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController!,
      curve: Curves.easeOut,
    ));

    // ✅ Run animations in sequence
    _logoController!.forward().whenComplete(() {
      _textController!.forward().whenComplete(() {
        // ✅ Show welcome message after text appears
        Timer(const Duration(seconds: 1), () {
          setState(() {
            _showWelcome = true;
          });
        // ✅ Navigate to LoginPage after welcome message fades in
        Timer(const Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        });
      });
    });
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
            // ✅ Logo + English title in one row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo animation
                ScaleTransition(
                  scale: _logoAnimation ?? const AlwaysStoppedAnimation(1.0),
                  child: Image.asset(
                    "assets/logoImage.png",
                    height: 200,
                    width: 200,
                  ),
                ),
                const SizedBox(width: 12),

                // English Title
                SlideTransition(
                  position:
                      _textAnimation ?? const AlwaysStoppedAnimation(Offset.zero),
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
              ],
            ),

            const SizedBox(height: 8),

            // ✅ Arabic subtitle more to the right
            Padding(
              padding: const EdgeInsets.only(left: 250.0),
              child: SlideTransition(
                position:
                    _textAnimation ?? const AlwaysStoppedAnimation(Offset.zero),
                child: const Text(
                  "ماركات عالمية",
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ✅ Welcome message fades in after everything
            AnimatedOpacity(
              opacity: _showWelcome ? 1.0 : 0.0,
              duration: const Duration(seconds: 2),
              child: const Text(
                "Welcome to Sport Brands 👟",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
