import 'dart:async'; // To use Timer (delays & scheduled tasks)
import 'package:flutter/material.dart'; // Core Flutter UI toolkit
import 'package:google_fonts/google_fonts.dart'; // To use Google Fonts
import 'login_page.dart'; // Navigate to login screen after splash

// A StatefulWidget allows us to rebuild the UI when state/animations change
class LogoScreen extends StatefulWidget {
  const LogoScreen({super.key});

  @override
  State<LogoScreen> createState() => _LogoScreenState();
}

// TickerProviderStateMixin provides "vsync" → needed for animations
class _LogoScreenState extends State<LogoScreen> with TickerProviderStateMixin {
  AnimationController? _logoController; // controls logo animation (timing)
  Animation<double>? _logoAnimation; // scaling (bounce effect)
  Animation<double>? _logoRotation; // rotation animation

  AnimationController? _textController; // controls text slide-in
  Animation<Offset>? _textAnimation; // animation for sliding text

  bool _showWelcome = false; // flag to show/hide welcome message

  // Loader (3 bouncing bubbles) animations
  late List<AnimationController> _bubbleControllers;
  late List<Animation<double>> _bubbleAnimations;

  @override
  void initState() {
    super.initState();

    // --- LOGO ANIMATION ---
    _logoController = AnimationController(
      vsync: this, // sync with screen refresh to save battery
      duration: const Duration(seconds: 2), // animation lasts 2 seconds
    );

    // Bounce scaling effect for logo (like it pops in)
    _logoAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.2) // grow from invisible → larger
            .chain(CurveTween(curve: Curves.elasticOut)), // bouncy effect
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 1.0), // settle back to normal size
        weight: 50,
      ),
    ]).animate(_logoController!);

    // Small rotation effect when logo appears
    _logoRotation = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(parent: _logoController!, curve: Curves.easeOutBack),
    );

    // --- TEXT ANIMATION ---
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // 1 second slide animation
    );

    // Slide from bottom → to normal position
    _textAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // start off-screen (below)
      end: Offset.zero, // slide into place
    ).animate(
      CurvedAnimation(parent: _textController!, curve: Curves.easeOut),
    );

    // --- BUBBLE LOADER ANIMATION ---
    _bubbleControllers = List.generate(
      3, // 3 bubbles
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500), // each bubble 1.5s cycle
      ),
    );

    // Each bubble grows/shrinks smoothly
    _bubbleAnimations = _bubbleControllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 2.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    // --- RUN SEQUENCE ---
    _logoController!.forward().whenComplete(() {
      _textController!.forward().whenComplete(() {
        // Delay 1s → then show welcome
        Timer(const Duration(seconds: 1), () {
          setState(() {
            _showWelcome = true; // triggers rebuild
          });

          // Start bubbles after welcome appears
          for (int i = 0; i < _bubbleControllers.length; i++) {
            _bubbleControllers[i].repeat(
              reverse: true, // grow/shrink repeatedly
              period: Duration(milliseconds: 1500 + i * 200), // staggered
            );
          }

          // Navigate automatically to LoginPage after 3s
           Timer(const Duration(seconds: 3), () {
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
    // Always dispose controllers → free memory
    _logoController?.dispose();
    _textController?.dispose();
    for (var controller in _bubbleControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Reusable bubble widget (for loader)
  Widget buildBubble(int index) {
    return AnimatedBuilder(
      animation: _bubbleAnimations[index],
      builder: (context, child) {
        return Transform.scale(
          scale: _bubbleAnimations[index].value, // bubble size changes
          child: Container(
            width: 5,
            height: 5,
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              shape: BoxShape.circle, // circle bubble
              gradient: const LinearGradient( // nice glowing gradient
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
    // Get device screen size for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient( // background gradient
            colors: [const Color.fromARGB(255, 0, 0, 0), const Color.fromARGB(234, 5, 5, 5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // center vertically
            children: [
              // --- LOGO + ENGLISH TITLE ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RotationTransition( // rotate logo slightly
                    turns: _logoRotation ?? AlwaysStoppedAnimation(0),
                    child: ScaleTransition( // bounce scale effect
                      scale: _logoAnimation ?? AlwaysStoppedAnimation(1.0),
                      child: SizedBox(
                        height: screenHeight * 0.35,
                        width: screenWidth * 0.35,
                        child: Image.asset(
                          "assets/logoImage.png", // logo file
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  Flexible( // text adjusts to screen size
                    child: SlideTransition(
                      position: _textAnimation ??
                          const AlwaysStoppedAnimation(Offset.zero),
                      child: Text(
                        "SPORT BRANDS",
                        style: GoogleFonts.robotoCondensed(
                          color: Colors.white,
                          fontSize: screenWidth * 0.07,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2, // spacing between letters
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // --- ARABIC SUBTITLE ---
              Transform.translate( // move upwards for alignment
                offset: Offset(0, -screenHeight * 0.12),
                child: Padding(
                  padding: EdgeInsets.only(left: screenWidth * 0.55),
                  child: SlideTransition(
                    position:
                        _textAnimation ?? const AlwaysStoppedAnimation(Offset.zero),
                    child: Text(
                      "ماركات عالمية", // Arabic text
                      style: GoogleFonts.cairo(
                        color: Colors.orange,
                        fontSize: screenWidth * 0.05,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.05),

              // --- WELCOME MESSAGE + LOADER ---
              AnimatedOpacity(
                opacity: _showWelcome ? 1.0 : 0.0, // fade-in welcome
                duration: const Duration(seconds: 2),
                child: Column(
                  children: [
                    Text(
                      "Welcome to Sport Brands",
                      style: GoogleFonts.robotoCondensed(
                        color: Colors.white,
                        fontSize: screenWidth * 0.07,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow( // glowing effect
                            color: const Color.fromARGB(255, 240, 225, 3)
                                .withOpacity(0.5),
                            offset: const Offset(0, 0),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.08),
                    // Bubbles loader (3 animated dots)
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
