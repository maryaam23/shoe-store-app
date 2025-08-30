import 'package:flutter/material.dart';
//import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart'; // For SVG icons
import 'package:shoe_store_app/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';


import 'home_page.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final FocusNode _focusNodePassword = FocusNode();
  final TextEditingController _controllerUsername = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  bool _obscurePassword = true; // Flag to show/hide password
  //final Box _boxLogin = Hive.box("login");
  //final Box _boxAccounts = Hive.box("accounts");

  final user = FirebaseAuth.instance.currentUser;
 

  @override
  Widget build(BuildContext context) {
    // If user is already logged in, go directly to HomePage
    if (user != null) {
      return HomePage();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          //✅ Allows scrolling when keyboard opens
          padding: const EdgeInsets.all(30.0),
          child: Column(
            // Main vertical layout
            children: [
              // ---------------- Welcome Text + Logo ----------------
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Align all children to left
                children: [
                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .end, // Align logo and text at baseline
                    children: [
                      Text(
                        "Welcome Back!",
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(width: 8), // small gap between text & logo
                      Image.asset(
                        "assets/logoImage.png",
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ), // Spacing between welcome row and subtitle
                  Text(
                    "Login to your account",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),

              const SizedBox(height: 60),

              // ---------------- Username Field ----------------
              TextFormField(
                controller: _controllerUsername, // Controller to get input
                keyboardType: TextInputType.name, // Keyboard type
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: const Icon(
                    Icons.person_outline,
                  ), // Icon on the left
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded border
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onEditingComplete:
                    () =>
                        _focusNodePassword
                            .requestFocus(), // Move focus to password field when done
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter email.";
                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return "Enter a valid email.";
                  }

                  return null;
                },
              ),
              const SizedBox(height: 10),
              // ---------------- Password Field ----------------
              TextFormField(
                controller: _controllerPassword,
                focusNode: _focusNodePassword,
                obscureText: _obscurePassword, // Hide or show password
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.password_outlined),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword =
                            !_obscurePassword; // Toggle visibility
                      });
                    },
                    icon:
                        _obscurePassword
                            ? const Icon(Icons.visibility_outlined)
                            : const Icon(Icons.visibility_off_outlined),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter password.";
                  } return null; // No manual password check needed

                },
              ),
              const SizedBox(height: 60),
              // ---------------- Login Button + Signup ----------------
              Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(
                        50,
                      ), // Full-width button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          20,
                        ), // Rounded corners
                      ),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        try {
                          // Call Firebase email login
                          final user = await AuthService().signInWithEmail(
                            _controllerUsername.text.trim(), // email
                            _controllerPassword.text.trim(), // password
                          );

                          if (user != null) {
                            // ✅ Login successful
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => HomePage()),
                            );
                          }
                        } catch (e) {
                          // ❌ Show error if login fails
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Login failed: ${e.toString()}"),
                            ),
                          );
                        }
                      }
                    },

                    child: const Text("Login"),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          _formKey.currentState?.reset();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const SignupPage();
                              },
                            ),
                          );
                        },
                        child: const Text("Signup"),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // ---------------- Social login section ----------------
              Column(
                children: [
                  const Text(
                    "Or Sign in with",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Center all social icons
                    children: [
                      // Google
                      IconButton(
                        onPressed: () async {
                          final user = await AuthService().signInWithGoogle();
                          if (user != null) {
                            print("✅ Google login: ${user.displayName}");
                            // You can navigate to your home page here
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => HomePage()),
                            );
                          } else {
                            print("❌ Google login failed");
                          }
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Colors.grey),
                        ),
                        icon: SvgPicture.string(
                          '''
                          <svg xmlns="http://www.w3.org/2000/svg" height="24" viewBox="0 0 488 512">
                            <path d="M488 261.8C488 403.3 391.1 504 
                            248 504 110.8 504 0 393.2 0 256S110.8 
                            8 248 8c66.8 0 123 24.5 166.3 
                            64.9l-67.5 64.9C258.5 52.6 94.3 
                            116.6 94.3 256c0 86.5 69.1 156.6 
                            153.7 156.6 98.2 0 135-70.4 
                            140.8-106.9H248v-85.3h236.1c2.3 
                            12.7 3.9 24.9 3.9 41.4z"/>
                          </svg>
                          ''',
                          width: 24,
                          height: 24,
                        ),
                      ),
                      const SizedBox(width: 15),

                      // Facebook
                      IconButton(
                        onPressed: () async {
                          final user = await AuthService().signInWithFacebook();
                          if (user != null) {
                            print("✅ Facebook login: ${user.displayName}");
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => HomePage()),
                            );
                          } else {
                            print("❌ Facebook login failed");
                          }
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: Color.fromARGB(
                            255,
                            0,
                            0,
                            0,
                          ), // Facebook blue
                        ),
                        icon: SvgPicture.string(
                          '''
                        <svg xmlns="http://www.w3.org/2000/svg" height="24" viewBox="0 0 320 512">
                          <path fill="white" d="M279.14 288l14.22-92.66h-88.91V127.41c0-25.35 
                          12.42-50.06 52.24-50.06h40.42V6.26S293.3 
                          0 268.1 0c-73.22 0-121.07 44.38-121.07 
                          124.72V195.3H86.41V288h60.62v224h92.66V288z"/>
                        </svg>
                        ''',
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose focus nodes and controllers to free memory
    _focusNodePassword.dispose();
    _controllerUsername.dispose();
    _controllerPassword.dispose();
    super.dispose();
  }
}
