import 'package:flutter/material.dart';
<<<<<<< HEAD
//import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart'; // For SVG icons
import 'package:shoe_store_app/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

=======
import 'package:flutter_svg/flutter_svg.dart';
>>>>>>> 40c735af4a5446fe8114d61d2afaa6fb5712668b

import 'home_page.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
<<<<<<< HEAD
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
=======
  final Map<String, dynamic> _boxAccounts = {
    "test": "1234", // dummy account
  };
  final Map<String, dynamic> _boxLogin = {};
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerUsername = TextEditingController();
  final FocusNode _focusNodePassword = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _focusNodePassword.dispose();
    _controllerUsername.dispose();
    _controllerPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double padding = size.width * 0.06;
    final double spacing = size.height * 0.02;
    final double logoSize = size.width * 0.2;
    final double inputFontSize = size.width * 0.045;
    final double buttonHeight = size.height * 0.065;
    final double buttonFontSize = size.width * 0.05;

    if (_boxLogin["loginStatus"] ?? false) {
>>>>>>> 40c735af4a5446fe8114d61d2afaa6fb5712668b
      return HomePage();
    }

    return Scaffold(
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
                width: size.width * 0.92, // <-- increase width here (95% of screen)
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: size.height * 0.97,
                    maxHeight: size.height * 1,
                  ),
<<<<<<< HEAD
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
=======
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
>>>>>>> 40c735af4a5446fe8114d61d2afaa6fb5712668b

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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter username.";
                                } else if (!_boxAccounts.containsKey(value)) {
                                  return "Username is not registered.";
                                }
                                return null;
                              },
                              onEditingComplete:
                                  () => _focusNodePassword.requestFocus(),
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter password.";
                                } else if (value !=
                                    _boxAccounts[_controllerUsername.text]) {
                                  return "Wrong password.";
                                }
                                return null;
                              },
                            ),

<<<<<<< HEAD
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
=======
                            // Forgot Password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: const Text(
                                            "Forgot Password",
                                            style: TextStyle(
                                              color: Color.fromRGBO(
                                                1,
                                                1,
                                                1,
                                                1,
                                              ), // change to any color you want
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),

                                          content: const Text(
                                            "Password reset functionality is not implemented yet.",
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(context),
                                              child: const Text("Close"),
                                            ),
                                          ],
                                        ),
                                  );
                                },
                                child: Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                    fontSize: inputFontSize * 0.9,
                                    color: const Color.fromARGB(
                                      255,
                                      0,
                                      0,
                                      0,
                                    ), // change to any color you want
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: spacing / 2),

                            // Login Button
                            Center(
                              child: SizedBox(
                                height: buttonHeight,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(255, 0, 0, 0), // professional blue
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        size.width * 0.05,
                                      ),
                                    ),
                                    shadowColor: Colors.black45,
                                    elevation: 5,
                                  ),
                                  onPressed: () {
                                    if (_formKey.currentState?.validate() ??
                                        false) {
                                      _boxLogin["loginStatus"] = true;
                                      _boxLogin["userName"] =
                                          _controllerUsername.text;
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => HomePage(),
                                        ),
                                      );
                                    }
                                  },
                                  child: Text(
                                    "Login",
                                    style: TextStyle(
                                      fontSize: buttonFontSize,
                                      color: const Color.fromARGB(
                                        255,
                                        255,
                                        255,
                                        255,
                                      ),
                                    ),
                                  ),
                                ),
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
                                      fontSize: inputFontSize ,
                                      color: const Color.fromARGB(255, 0, 0, 0), // orange-like
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
                                    _socialIconButton(
                                      color: Colors.white,
                                      svg: _googleSvg,
                                      size: size.width * 0.12,
                                      onPressed: () {},
                                    ),
                                    SizedBox(width: spacing),
                                    _socialIconButton(
                                      color: const Color.fromARGB(
                                        255,
                                        7,
                                        109,
                                        242,
                                      ),
                                      svg: _facebookSvg,
                                      size: size.width * 0.12,
                                      onPressed: () {},
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
>>>>>>> 40c735af4a5446fe8114d61d2afaa6fb5712668b
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
