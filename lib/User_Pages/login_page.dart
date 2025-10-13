import 'package:flutter/material.dart';
//import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart'; // For SVG icons
import 'package:shoe_store_app/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';
import 'signup_page.dart';
import 'package:shoe_store_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoe_store_app/Admin_Pages/admin_overview_page.dart';

class LoginPage extends StatefulWidget {
  final bool fromProfile;

  const LoginPage({super.key, this.fromProfile = false});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerUsername = TextEditingController();
  final FocusNode _focusNodePassword = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool _obscurePassword = true;
  bool _isLoading = false;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void dispose() {
    _focusNodePassword.dispose();
    _controllerUsername.dispose();
    _controllerPassword.dispose();
    super.dispose();
  }

  bool isGuest = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double padding = size.width * 0.06;
    final double spacing = size.height * 0.02;
    final double logoSize = size.width * 0.2;
    final double inputFontSize = size.width * 0.045;
    final double buttonHeight = size.height * 0.065;
    final double buttonFontSize = size.width * 0.05;

    // If user is already logged in, check role
    // If user is already logged in, check role in real-time
    if (user != null) {
      return StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .snapshots(), // 🔹 real-time stream
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError ||
              !snapshot.hasData ||
              !snapshot.data!.exists) {
            return const Scaffold(
              body: Center(child: Text("Error fetching user data")),
            );
          }

          final userRole = snapshot.data!['role'];

          // Navigate only once using a post-frame callback
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (userRole == 'admin') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => AdminOverviewScreen()),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            }
          });

          // While waiting for navigation
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading:
            widget.fromProfile
                ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    // Go back to HomePage as guest
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HomePage(isGuest: true),
                      ),
                    );
                  },
                )
                : null,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // dismiss keyboard
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(236, 170, 104, 0.047),
                Color.fromARGB(224, 187, 179, 167),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: SizedBox(
                width:
                    size.width *
                    0.92, // <-- increase width here (95% of screen)
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: size.height * 0.97,
                    maxHeight: size.height * 1,
                  ),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(size.width * 0.06),
                    ),
                    shadowColor: Colors.black45,

                    child: Padding(
                      padding: EdgeInsets.all(padding),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Logo and welcome
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Welcome Back!",
                                    style: TextStyle(
                                      fontSize: size.width * 0.075,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                Image.asset(
                                  "assets/logoImage.png",
                                  width: logoSize,
                                  height: logoSize,
                                ),
                              ],
                            ),
                            SizedBox(height: spacing / 2),
                            Text(
                              "Login to your account",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: inputFontSize,
                              ),
                            ),
                            SizedBox(height: spacing * 1.5),

                            // Username field
                            TextFormField(
                              controller: _controllerUsername,
                              style: TextStyle(fontSize: inputFontSize),
                              decoration: InputDecoration(
                                labelText: "Username",
                                prefixIcon: Icon(
                                  Icons.person_outline,
                                  size: inputFontSize * 1.2,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    size.width * 0.04,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    size.width * 0.04,
                                  ),
                                  borderSide: const BorderSide(
                                    color: Color.fromARGB(255, 1, 1, 1),
                                  ),
                                ),
                              ),
                              onEditingComplete:
                                  () =>
                                      _focusNodePassword
                                          .requestFocus(), // Move focus to password field when done
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter email.";
                                } else if (!RegExp(
                                  r'^[^@]+@[^@]+\.[^@]+',
                                ).hasMatch(value)) {
                                  return "Enter a valid email.";
                                }

                                return null;
                              },
                            ),

                            SizedBox(height: spacing),

                            // Password field
                            TextFormField(
                              controller: _controllerPassword,
                              focusNode: _focusNodePassword,
                              obscureText: _obscurePassword,
                              style: TextStyle(fontSize: inputFontSize),
                              decoration: InputDecoration(
                                labelText: "Password",
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  size: inputFontSize * 1.2,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons
                                            .visibility_off_outlined // closed eye when password hidden
                                        : Icons
                                            .visibility_outlined, // open eye when password visible
                                    size: inputFontSize * 1.2,
                                  ),
                                  onPressed: () {
                                    setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    );
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    size.width * 0.04,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    size.width * 0.04,
                                  ),
                                  borderSide: const BorderSide(
                                    color: Color.fromARGB(255, 0, 0, 0),
                                  ),
                                ),
                              ),
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter password.";
                                }
                                return null; // No manual password check needed
                              },
                            ),

                            // Forgot Password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  _showForgotPasswordDialog(context);
                                },
                                child: Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                    fontSize: inputFontSize * 0.9,
                                    color: const Color.fromARGB(255, 0, 0, 0),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: spacing / 2),

                            // Login + Guest Buttons
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Login Button
                                  SizedBox(
                                    height: buttonHeight,
                                    width: 140, // you can adjust width
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                          255,
                                          0,
                                          0,
                                          0,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            size.width * 0.05,
                                          ),
                                        ),
                                        shadowColor: const Color.fromARGB(
                                          255,
                                          0,
                                          0,
                                          0,
                                        ),
                                        elevation: 5,
                                      ),
                                      onPressed: () async {
                                        if (_formKey.currentState?.validate() ??
                                            false) {
                                          try {
                                            final userCredential =
                                                await FirebaseAuth.instance
                                                    .signInWithEmailAndPassword(
                                                      email:
                                                          _controllerUsername
                                                              .text
                                                              .trim(),
                                                      password:
                                                          _controllerPassword
                                                              .text
                                                              .trim(),
                                                    );

                                            User? user = userCredential.user;
                                            await user?.reload();

                                            if (user != null &&
                                                user.emailVerified) {
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => HomePage(),
                                                ),
                                              );
                                            } else {
                                              await FirebaseAuth.instance
                                                  .signOut();
                                              showSnackBar(
                                                "Please verify your email before logging in.",
                                                color: Colors.red,
                                              );

                                              try {
                                                await user?.sendEmailVerification(
                                                  ActionCodeSettings(
                                                    url:
                                                        'https://sport-brands-42c8a.web.app',
                                                    handleCodeInApp: false,
                                                    androidPackageName:
                                                        'com.example.shoe_store_app',
                                                    androidInstallApp: true,
                                                    androidMinimumVersion: '21',
                                                    iOSBundleId:
                                                        'com.example.shoeStoreApp',
                                                  ),
                                                );
                                                showSnackBar(
                                                  "Verification email resent! Check your inbox.",
                                                  color: Colors.green,
                                                );
                                              } catch (e) {
                                                print(
                                                  "❌ Failed to resend verification email: $e",
                                                );
                                              }
                                            }
                                          } on FirebaseAuthException catch (e) {
                                            showSnackBar(
                                              "Login failed: ${e.message}",
                                            );
                                          }
                                        }
                                      },
                                      child: Text(
                                        "Login",
                                        style: TextStyle(
                                          fontSize: buttonFontSize,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 15),

                                  // Guest Button
                                  SizedBox(
                                    height: buttonHeight,
                                    width:
                                        140, // same width as login for symmetry
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                          255,
                                          0,
                                          0,
                                          0,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            size.width * 0.05,
                                          ),
                                        ),
                                        shadowColor: const Color.fromARGB(
                                          255,
                                          0,
                                          0,
                                          0,
                                        ),
                                        elevation: 5,
                                      ),
                                      onPressed: () {
                                        isGuest = true; // ✅ Guest login mode
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) =>
                                                    HomePage(isGuest: isGuest),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        "Guest",
                                        style: TextStyle(
                                          fontSize: buttonFontSize,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: spacing / 2),

                            // Signup link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account?",
                                  style: TextStyle(
                                    fontSize: inputFontSize * 0.9,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    _formKey.currentState?.reset();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => const SignupPage(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Signup",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: inputFontSize,
                                      color: const Color.fromARGB(
                                        255,
                                        0,
                                        0,
                                        0,
                                      ), // orange-like
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: spacing / 2),

                            // Social login
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Or sign in with",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: inputFontSize * 0.9,
                                  ),
                                ),
                                SizedBox(height: spacing / 2),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Google button
                                    _socialIconButton(
                                      color: Colors.white,
                                      svg: _googleSvg,
                                      size: size.width * 0.12,
                                      onPressed: () async {
                                        final user =
                                            await AuthService()
                                                .signInWithGoogle();
                                        if (user != null) {
                                          await _saveSocialUserToFirestore(
                                            user,
                                          );
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => HomePage(),
                                            ),
                                          );
                                        } else {
                                          print("❌ Google login failed");
                                        }
                                      },
                                    ),
                                    SizedBox(width: spacing),
                                    //facebook button
                                    _socialIconButton(
                                      color: const Color.fromARGB(
                                        255,
                                        7,
                                        109,
                                        242,
                                      ),
                                      svg: _facebookSvg,
                                      size: size.width * 0.12,
                                      onPressed: () async {
                                        final user =
                                            await AuthService()
                                                .signInWithFacebook();
                                        if (user != null) {
                                          await _saveSocialUserToFirestore(
                                            user,
                                          );
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => HomePage(),
                                            ),
                                          );
                                        } else {
                                          print("❌ Facebook login failed");
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveSocialUserToFirestore(User user) async {
    final userDoc = FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid);
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      await userDoc.set({
        "fullName": user.displayName ?? "",
        "dob": "",
        "phone": "",
        "gender": null,
        "city": null,
        "email": user.email ?? "",
        "country": "Palestine",
        "createdAt": FieldValue.serverTimestamp(),
        "photoURL": user.photoURL ?? "",
        "selectedPaymentMethod": {"type": "Cash on Delivery"},
        "savedAddress": {
          "latitude": null,
          "longitude": null,
          "address": "No address saved",
        },
        "role": "user",
      });
    }
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    final size = MediaQuery.of(context).size;
    final double titleFontSize = size.width * 0.045;
    final double inputFontSize = size.width * 0.04;
    final double buttonFontSize = size.width * 0.04;
    final double iconSize = size.width * 0.06;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              "Reset Password",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: titleFontSize,
              ),
            ),
            content: SizedBox(
              width: size.width * 0.8,
              child: Form(
                key: _formKey,
                child: TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(
                    fontSize: inputFontSize,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white, // ensures background is white
                    labelText: "Enter your email",
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: inputFontSize * 0.95,
                    ),
                    floatingLabelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: inputFontSize,
                    ),
                    hintStyle: TextStyle(color: Colors.black54),
                    prefixIcon: Icon(
                      Icons.email,
                      size: iconSize,
                      color: Colors.black,
                    ),
                    errorStyle: TextStyle(
                      fontSize: inputFontSize * 0.8,
                      height: 1.2,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: size.height * 0.025,
                      horizontal: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter email";
                    }
                    if (!RegExp(
                      r"^[\w\.-]+@([\w-]+\.)+[a-zA-Z]{2,}$",
                    ).hasMatch(value)) {
                      return "Invalid email format";
                    }
                    if (!value.endsWith(".com")) {
                      return "Email must end with .com";
                    }
                    return null;
                  },
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: TextStyle(fontSize: buttonFontSize),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      await FirebaseAuth.instance.sendPasswordResetEmail(
                        email: emailController.text.trim(),
                      );

                      Navigator.pop(context); // Close dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Password reset link sent! Check your email inbox.",
                          ),
                        ),
                      );
                    } catch (e) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: ${e.toString()}")),
                      );
                    }
                  }
                },
                child: Text(
                  "Send Reset Link",
                  style: TextStyle(fontSize: buttonFontSize),
                ),
              ),
            ],
          ),
    );
  }

  Widget _socialIconButton({
    required Color color,
    required String svg,
    required double size,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: IconButton(
        icon: SvgPicture.string(svg, width: size * 0.5, height: size * 0.5),
        onPressed: onPressed,
      ),
    );
  }

  void showSnackBar(String message, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color ?? Colors.red),
    );
  }

  // SVGs for social icons
  final String _googleSvg = '''
  <svg xmlns="http://www.w3.org/2000/svg" height="24" viewBox="0 0 488 512">
    <path d="M488 261.8C488 403.3 391.1 504 248 504 110.8 504 0 393.2 0 256S110.8 8 248 8c66.8 0 123 24.5 166.3 64.9l-67.5 64.9C258.5 52.6 94.3 116.6 94.3 256c0 86.5 69.1 156.6 153.7 156.6 98.2 0 135-70.4 140.8-106.9H248v-85.3h236.1c2.3 12.7 3.9 24.9 3.9 41.4z"/>
  </svg>
  ''';

  final String _facebookSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 320 512">
  <path fill="white" d="M279.14 288l14.22-92.66h-88.91V117.36c0-25.35 12.42-50.06 52.24-50.06h40.42V6.26S293.67 0 262.4 0c-73.22 0-121.12 44.38-121.12 124.72v70.62H83.88V288h57.4v224h104.1V288z"/>
</svg>
''';
}
