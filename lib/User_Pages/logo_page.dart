import 'dart:async'; // ✅ Import for Timer, used for delaying actions
import 'package:flutter/material.dart'; // ✅ Flutter framework for UI components
import 'login_page.dart'; // ✅ Import your login page to navigate after splash screen

// ✅ StatefulWidget because we have animations and state changes
class LogoScreen extends StatefulWidget {
  const LogoScreen({super.key}); // ✅ const constructor for performance

  @override
  State<LogoScreen> createState() => _LogoScreenState(); // ✅ Creates mutable state
}

// ✅ State class for LogoScreen
class _LogoScreenState extends State<LogoScreen> with TickerProviderStateMixin {
  // ✅ TickerProvider needed for animations
  AnimationController? _logoController; // ✅ Controls logo animation timing
  Animation<double>?
  _logoAnimation; // ✅ Defines the type of animation for logo (scale)

  AnimationController? _textController; // ✅ Controls text animation timing
  Animation<Offset>? _textAnimation; // ✅ Animation for text movement (slide)

  bool _showWelcome = false; // ✅ Controls fade-in of welcome message

  @override
  void initState() {
    super.initState(); // ✅ Always call super.initState in StatefulWidget

    // ✅ Logo animation controller: duration is 2 seconds
    _logoController = AnimationController(
      vsync: this, // ✅ Provides ticker for animation frames
      duration: const Duration(seconds: 2),
    );

    // ✅ Logo animation with easing curve
    _logoAnimation = CurvedAnimation(
      parent: _logoController!, // ✅ Connect controller to animation
      curve: Curves.easeInOutBack, // ✅ Easing effect for smooth scaling
    );

    // ✅ Text animation controller: duration is 1 second
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    // ✅ Slide animation: starts off-screen (Offset(0,1)) and moves to center (Offset.zero)
    _textAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // ✅ Offset(x, y) → 1 = 100% of widget height
      end: Offset.zero, // ✅ Ends at original position
    ).animate(
      CurvedAnimation(
        parent: _textController!, // ✅ Connect controller
        curve: Curves.easeOut, // ✅ Smooth deceleration
      ),
    );

    // ✅ Run animations in sequence
    _logoController!.forward().whenComplete(() {
      // ✅ Starts logo animation
      _textController!.forward().whenComplete(() {
        // ✅ Starts text animation after logo
        // ✅ Show welcome message after text animation
        Timer(const Duration(seconds: 1), () {
          // ✅ Delay before showing welcome
          setState(() {
            _showWelcome = true; // ✅ Trigger AnimatedOpacity
          });

          // ✅ Navigate to LoginPage after welcome message fades in
          Timer(const Duration(seconds: 2), () {
            // ✅ Wait 2 sec before navigation
            Navigator.pushReplacement(
              context, // ✅ Current context of the widget tree
              MaterialPageRoute(
                builder: (context) => const LoginPage(),
              ), // ✅ Navigate to LoginPage
            );
          });
        });
      });
    });
  }

  @override
  void dispose() {
    _logoController?.dispose(); // ✅ Free resources when widget removed
    _textController?.dispose(); // ✅ Same for text animation controller
    super.dispose(); // ✅ Always call super.dispose
  }

  @override
  Widget build(BuildContext context) {
// Inside build method
final screenWidth = MediaQuery.of(context).size.width;
final screenHeight = MediaQuery.of(context).size.height;

return Scaffold(
  backgroundColor: Colors.black,
  body: Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Logo + title row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo animation
            ScaleTransition(
              scale: _logoAnimation ?? const AlwaysStoppedAnimation(1.0),
              child: Image.asset(
                "assets/logoImage.png",
                height: screenHeight * 0.25, // ✅ 25% of screen height
                width: screenWidth * 0.25,   // ✅ 25% of screen width
              ),
            ),
            SizedBox(width: screenWidth * 0.03), // ✅ 3% of screen width
            // English title
            SlideTransition(
              position:
                  _textAnimation ?? const AlwaysStoppedAnimation(Offset.zero),
              child: Text(
                "SPORT BRANDS",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.07, // ✅ 7% of screen width
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),

        // Arabic subtitle (responsive)
        Transform.translate(
          offset: Offset(0, -screenHeight * 0.08), // ✅ negative 8% of height
          child: Padding(
            padding: EdgeInsets.only(left: screenWidth * 0.45), // ✅ 45% of width
            child: SlideTransition(
              position:
                  _textAnimation ?? const AlwaysStoppedAnimation(Offset.zero),
              child: Text(
                "ماركات عالمية",
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: screenWidth * 0.04, // ✅ 4% of screen width
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: screenHeight * 0.05), // ✅ 5% of screen height

        // Welcome message
        AnimatedOpacity(
          opacity: _showWelcome ? 1.0 : 0.0,
          duration: const Duration(seconds: 2),
          child: Text(
            "Welcome to Sport Brands 👟",
            style: TextStyle(
              color: Colors.white70,
              fontSize: screenWidth * 0.06, // ✅ responsive font size
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
