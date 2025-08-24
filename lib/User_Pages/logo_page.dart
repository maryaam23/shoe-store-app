import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_page.dart'; // replace with your login page import

class LogoScreen extends StatefulWidget {
  const LogoScreen({super.key});

  @override
  State<LogoScreen> createState() => _LogoScreenState();
}

class _LogoScreenState extends State<LogoScreen> with TickerProviderStateMixin {
  AnimationController? _logoController;
  Animation<double>? _logoAnimation;
  Animation<double>? _logoRotation;

  AnimationController? _textController;
  Animation<Offset>? _textAnimation;

  bool _showWelcome = false;

  // Loader Animation Controllers
  late List<AnimationController> _bubbleControllers;
  late List<Animation<double>> _bubbleAnimations;

  @override
  void initState() {
    super.initState();

    // Logo Animation Controller
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Bounce Scale Animation
    _logoAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.2,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 50),
    ]).animate(_logoController!);

    // Rotation Animation
    _logoRotation = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(parent: _logoController!, curve: Curves.easeOutBack),
    );

    // Text Animation Controller
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    // Slide-in Text Animation
    _textAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController!, curve: Curves.easeOut));

    // Bubble loader controllers
    _bubbleControllers = List.generate(
      3,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500),
      ),
    );

    _bubbleAnimations =
        _bubbleControllers.map((controller) {
          return Tween<double>(begin: 1.0, end: 2.0).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeInOut),
          );
        }).toList();

    // Run logo and text animations
    _logoController!.forward().whenComplete(() {
      _textController!.forward().whenComplete(() {
        Timer(const Duration(seconds: 1), () {
          setState(() {
            _showWelcome = true;
          });

          // Start bubble loader animations after welcome
          for (int i = 0; i < _bubbleControllers.length; i++) {
            _bubbleControllers[i].repeat(
              reverse: true,
              period: Duration(milliseconds: 1500 + i * 200),
            );
          }

          // Optional: Navigate to login after some delay
          // Timer(const Duration(seconds: 3), () {
          //   Navigator.pushReplacement(
          //     context,
          //     MaterialPageRoute(builder: (context) => const LoginPage()),
          //   );
          // });
        });
      });
    });
  }

  @override
  void dispose() {
    _logoController?.dispose();
    _textController?.dispose();
    for (var controller in _bubbleControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget buildBubble(int index) {
    return AnimatedBuilder(
      animation: _bubbleAnimations[index],
      builder: (context, child) {
        return Transform.scale(
          scale: _bubbleAnimations[index].value,
          child: Container(
            width: 5,
            height: 5,
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 255, 201, 4),
                  Color.fromARGB(255, 254, 174, 61),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, const Color.fromARGB(255, 30, 29, 29)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo + English Title
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RotationTransition(
                    turns: _logoRotation ?? AlwaysStoppedAnimation(0),
                    child: ScaleTransition(
                      scale: _logoAnimation ?? AlwaysStoppedAnimation(1.0),
                      child: SizedBox(
                        height: screenHeight * 0.35,
                        width: screenWidth * 0.35,
                        child: Image.asset(
                          "assets/logoImage.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: SlideTransition(
                      position:
                          _textAnimation ??
                          const AlwaysStoppedAnimation(Offset.zero),
                      child: Text(
                        "SPORT BRANDS",
                        style: GoogleFonts.robotoCondensed(
                          color: Colors.white,
                          fontSize: screenWidth * 0.07,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Arabic Subtitle
              Transform.translate(
                offset: Offset(0, -screenHeight * 0.12),
                child: Padding(
                  padding: EdgeInsets.only(left: screenWidth * 0.55),
                  child: SlideTransition(
                    position:
                        _textAnimation ??
                        const AlwaysStoppedAnimation(Offset.zero),
                    child: Text(
                      "ماركات عالمية",
                      style: GoogleFonts.cairo(
                        color: Colors.orange,
                        fontSize: screenWidth * 0.05,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.05),

              // Welcome Message with Glow
              AnimatedOpacity(
                opacity: _showWelcome ? 1.0 : 0.0,
                duration: const Duration(seconds: 2),
                child: Column(
                  children: [
                    Text(
                      "Welcome to Sport Brands",
                      style: GoogleFonts.robotoCondensed(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        fontSize: screenWidth * 0.07,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            // ignore: deprecated_member_use
                            color: const Color.fromARGB(255, 240, 225, 3).withOpacity(0.5),
                            offset: const Offset(0, 0),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.08),
                    // Bubble Loader
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) => buildBubble(index)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
