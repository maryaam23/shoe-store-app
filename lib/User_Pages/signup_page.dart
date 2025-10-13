import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:flutter_svg/flutter_svg.dart'; // For SVG icons
import 'package:shoe_store_app/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shoe_store_app/main.dart';
import 'home_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Dropdowns
  String? _selectedGender;
  String? _selectedCity;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _isLoading = false; // For loading indicator
  String? _passwordError; // live validation feedback
  String? _confirmPasswordError;

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return "Please enter a password";
    if (value.length < 8) return "Password must be at least 8 characters long";
    if (value.length > 20) return "Password cannot exceed 20 characters";
    if (!RegExp(r'[A-Z]').hasMatch(value))
      return "Password must contain at least 1 uppercase letter";
    if (!RegExp(r'[a-z]').hasMatch(value))
      return "Password must contain at least 1 lowercase letter";
    if (!RegExp(r'\d').hasMatch(value))
      return "Password must contain at least 1 number";
    if (!RegExp(r'[\W_]').hasMatch(value))
      return "Password must contain at least 1 special character";
    if (value.contains(' ')) return "Password cannot contain spaces";
    return null;
  }

  final List<String> _genders = ["Male", "Female", "Other"];
  final List<String> _cities = [
    "Ramallah",
    "Nablus",
    "Hebron",
    "Gaza",
    "Jenin",
    "Tulkarm",
    "Bethlehem",
    "Qalqilya",
    "Jericho",
    "Salfit",
    "Tubas",
    "East Jerusalem",
  ];

  String _selectedPayment = "Cash on Delivery"; // default

  // Helper function inside the state class
  Future<bool> checkDomainExists(String email) async {
    try {
      final domain = email.split('@').last;

      final url = Uri.parse('https://dns.google/resolve?name=$domain&type=MX');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['Answer'] != null;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // SnackBar helper
  void showSnackBar(String message, {Color color = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Helper function
  Future<void> waitForEmailVerification(User user) async {
    while (!user.emailVerified) {
      await Future.delayed(const Duration(seconds: 3));
      await user.reload();
      user = FirebaseAuth.instance.currentUser!;
    }
  }

  // Launch URL helper
  void launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Responsive scaling factors
    final double padding = size.width * 0.05;
    final double spacing = size.height * 0.03;
    final double titleFontSize = size.width * 0.07;
    final double subtitleFontSize = size.width * 0.04;
    final double inputFontSize = size.width * 0.048;
    final double buttonHeight = size.height * 0.065;
    final double buttonFontSize = size.width * 0.05;
    final double iconSize = size.width * 0.06;
    final double socialIconSize = size.width * 0.08;

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
                Color.fromRGBO(238, 182, 126, 0.047),
                Color.fromARGB(223, 175, 172, 167),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(padding),
                constraints: BoxConstraints(maxWidth: size.width * 0.92),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(size.width * 0.05),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: iconSize * 2),
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                fontSize: titleFontSize,
                                color: const Color.fromARGB(255, 0, 0, 0),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            top: iconSize / 2,
                            child: Container(
                              width: iconSize,
                              height: iconSize,
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 0, 0, 0),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: spacing),

                      Text(
                        "Create your account below",
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: spacing),

                      // Input fields
                      //name
                      //Should not be empty.  Must contain only letters and spaces.  Minimum length (e.g., 3 characters)
                      _buildTextField(
                        "Full Name",
                        Icons.person,
                        inputFontSize,
                        controller: _nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return "Enter your full name";
                          if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value)) {
                            return "Name must contain only letters";
                          }
                          if (value.length < 3)
                            return "Name must be at least 3 characters";
                          return null;
                        },
                      ),
                      SizedBox(height: spacing / 2),

                      //email
                      _buildTextField(
                        "Email",
                        Icons.email,
                        inputFontSize,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return "Enter email";

                          // General email format check
                          if (!RegExp(
                            r"^[\w\.-]+@([\w-]+\.)+[a-zA-Z]{2,}$",
                          ).hasMatch(value)) {
                            return "Invalid email format";
                          }

                          // Ensure it ends with .com
                          if (!value.endsWith(".com"))
                            return "Email must end with .com";

                          return null;
                        },
                      ),

                      SizedBox(height: spacing / 2),

                      _buildTextField(
                        "Phone Number",
                        Icons.phone,
                        inputFontSize,
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter phone number";
                          }
                          if (!RegExp(r"^05\d{8}$").hasMatch(value)) {
                            return "Phone must start with 05 and be 10 digits";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: spacing / 2),

                      // Date of Birth
                      TextFormField(
                        controller: _dobController,
                        readOnly: true,
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime(2000),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              _dobController.text =
                                  "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter Date of Birth";
                          }
                          try {
                            final parts = value.split("/");
                            final dob = DateTime(
                              int.parse(parts[2]),
                              int.parse(parts[1]),
                              int.parse(parts[0]),
                            );

                            final today = DateTime.now();

                            // 🔹 Limit future dates
                            if (dob.isAfter(today)) {
                              return "Date of Birth cannot be in the future";
                            }

                            // 🔹 Minimum age check (>= 13)
                            final age =
                                today.year -
                                dob.year -
                                ((today.month < dob.month ||
                                        (today.month == dob.month &&
                                            today.day < dob.day))
                                    ? 1
                                    : 0);

                            if (age < 13) {
                              return "You must be at least 13 years old";
                            }
                          } catch (e) {
                            return "Invalid date format";
                          }
                          return null;
                        },

                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.calendar_today,
                            color: Colors.grey,
                            size: iconSize,
                          ),
                          labelText: "Date of Birth",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              size.width * 0.03,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ), // same height
                        ),
                        style: TextStyle(fontSize: inputFontSize),
                      ),
                      SizedBox(height: spacing / 2),

                      // Gender dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        hint: Text("Select Gender"),
                        items:
                            _genders
                                .map(
                                  (g) => DropdownMenuItem(
                                    value: g,
                                    child: Text(g),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (val) => setState(() => _selectedGender = val),
                        validator:
                            (value) => value == null ? "Select Gender" : null,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: Colors.grey,
                            size: iconSize,
                          ),
                          labelText: "Gender",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              size.width * 0.03,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ), // same height
                        ),
                        style: TextStyle(
                          fontSize: inputFontSize,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: spacing / 2),

                      // Country fixed
                      DropdownButtonFormField<String>(
                        value: "Palestine",
                        items: const [
                          DropdownMenuItem(
                            value: "Palestine",
                            child: Text("Palestine"),
                          ),
                        ],
                        onChanged: null,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.flag,
                            color: Colors.grey,
                            size: iconSize,
                          ),
                          labelText: "Country",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              size.width * 0.03,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ), // same height
                        ),
                        style: TextStyle(
                          fontSize: inputFontSize,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: spacing / 2),

                      // City dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedCity,
                        hint: Text("Select City"),
                        items:
                            _cities
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (val) => setState(() => _selectedCity = val!),
                        validator: (val) => val == null ? "Select City" : null,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.location_city,
                            color: Colors.grey,
                            size: iconSize,
                          ),
                          labelText: "City",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              size.width * 0.03,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ), // same height
                        ),
                        style: TextStyle(
                          fontSize: inputFontSize,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: spacing / 2),

                      // Password fields
                      _buildTextField(
                        "Password",
                        Icons.lock,
                        inputFontSize,
                        isPassword: true,
                        controller: _passwordController,
                        validator: _validatePassword,
                        passwordVisible: _passwordVisible,
                        togglePasswordVisibility: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                        onChanged: (value) {
                          setState(() {
                            _passwordError = _validatePassword(
                              value,
                            ); // ✅ call function directly
                          });
                        },
                        errorText: _passwordError,
                      ),

                      SizedBox(height: spacing / 2),
                      _buildTextField(
                        "Confirm Password",
                        Icons.lock_outline,
                        inputFontSize,
                        isPassword: true,
                        controller: _confirmPasswordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter Confirm Password";
                          }
                          if (value != _passwordController.text) {
                            return "Passwords do not match";
                          }
                          return null;
                        },
                        passwordVisible: _confirmPasswordVisible,
                        togglePasswordVisibility: () {
                          setState(() {
                            _confirmPasswordVisible = !_confirmPasswordVisible;
                          });
                        },
                        onChanged: (value) {
                          setState(() {
                            _confirmPasswordError =
                                value != _passwordController.text
                                    ? "Passwords do not match"
                                    : null;
                          });
                        },
                        errorText: _confirmPasswordError,
                      ),

                      SizedBox(height: spacing),

                      // Submit button
                      Center(
                        child: SizedBox(
                          width: size.width * 0.4,
                          height: buttonHeight,
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
                            ),

                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() => _isLoading = true);

                                try {
                                  // 1️⃣ Create user with email & password
                                  UserCredential userCredential =
                                      await FirebaseAuth.instance
                                          .createUserWithEmailAndPassword(
                                            email: _emailController.text.trim(),
                                            password:
                                                _passwordController.text.trim(),
                                          );

                                  User? user = userCredential.user;

                                  if (user != null) {
                                    // 2️⃣ Update display name
                                    await user.updateDisplayName(
                                      _nameController.text.trim(),
                                    );

                                    // 3️⃣ Send verification email
                                    await user.sendEmailVerification(
                                      ActionCodeSettings(
                                        url:
                                            'https://sport-brands-42c8a.web.app',
                                        handleCodeInApp: false,
                                        androidPackageName:
                                            'com.example.shoe_store_app',
                                        androidInstallApp: true,
                                        androidMinimumVersion: '21',
                                        iOSBundleId: 'com.example.shoeStoreApp',
                                      ),
                                    );

                                    showSnackBar(
                                      "📩 Verification email sent! Please check your inbox.",
                                      color: Colors.green,
                                    );

                                    // 4️⃣ Build payment method dynamically
                                    Map<String, dynamic> paymentMethod;
                                    if (_selectedPayment == "Visa") {
                                      paymentMethod = {
                                        "type": "Visa",
                                        "name": null,
                                        "cardNumber": null,
                                        "expiry": null,
                                        "cvv": null,
                                      };
                                    } else {
                                      paymentMethod = {
                                        "type": "Cash on Delivery",
                                      };
                                    }

                                    // 5️⃣ Save user info to Firestore immediately
                                    await FirebaseFirestore.instance
                                        .collection("users")
                                        .doc(user.uid)
                                        .set({
                                          "fullName":
                                              _nameController.text.trim(),
                                          "dob": _dobController.text.trim(),
                                          "phone": _phoneController.text.trim(),
                                          "gender": _selectedGender,
                                          "city": _selectedCity,
                                          "email": _emailController.text.trim(),
                                          "country": "Palestine",
                                          "createdAt":
                                              FieldValue.serverTimestamp(),
                                          "photoURL": null,
                                          "selectedPaymentMethod":
                                              paymentMethod,
                                          "savedAddress": {
                                            "latitude": null,
                                            "longitude": null,
                                            "address": "No address saved",
                                          },
                                        });

                                    // 6️⃣ Sign out so user can log in fresh
                                    await FirebaseAuth.instance.signOut();

                                    // 7️⃣ Navigate to LoginPage
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const LoginPage(fromProfile: false),
                                      ),
                                    );
                                  }
                                } on FirebaseAuthException catch (e) {
                                  String message;
                                  if (e.code == 'email-already-in-use') {
                                    message =
                                        "This email is already registered";
                                  } else if (e.code == 'weak-password') {
                                    message = "Password is too weak";
                                  } else if (e.code == 'invalid-email') {
                                    message = "Invalid email address";
                                  } else {
                                    message =
                                        e.message ??
                                        "An unexpected error occurred";
                                  }
                                  showSnackBar(message);
                                } finally {
                                  setState(() => _isLoading = false);
                                }
                              }
                            },

                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                fontSize: buttonFontSize,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: spacing),

                      // Sign in link
                      Center(
                        child: GestureDetector(
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginPage(fromProfile: false),
                                ),
                              ),
                          child: RichText(
                            text: TextSpan(
                              text: "Already have an account? ",
                              style: TextStyle(
                                fontSize: subtitleFontSize,
                                color: Colors.black54,
                              ),
                              children: [
                                TextSpan(
                                  text: "Sign In",
                                  style: TextStyle(
                                    color: const Color.fromARGB(255, 0, 0, 0),
                                    fontWeight: FontWeight.bold,
                                    fontSize: inputFontSize,
                                  ),
                                  recognizer:
                                      TapGestureRecognizer()
                                        ..onTap = () {
                                          // Navigate to Sign In page
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      const LoginPage(), // your Sign In page
                                            ),
                                          );
                                        },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: spacing),

                      // Social Login
                      Column(
                        children: [
                          Text(
                            "Or Sign in with",
                            style: TextStyle(
                              fontSize: inputFontSize,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: spacing * 0.75),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Google
                              IconButton(
                                onPressed: () async {
                                  final user =
                                      await AuthService().signInWithGoogle();
                                  if (user != null) {
                                    print(
                                      "✅ Google login: ${user.displayName}",
                                    );
                                    // You can navigate to your home page here
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

                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(
                                    color: Color.fromARGB(176, 198, 196, 196),
                                  ),
                                  padding: EdgeInsets.all(socialIconSize * 0.3),
                                ),
                                icon: SvgPicture.string(
                                  '''
                                  <svg xmlns="http://www.w3.org/2000/svg" height="24" viewBox="0 0 488 512">
                                  <path d="M488 261.8C488 403.3 391.1 504 248 504 110.8 504 0 393.2 0 256S110.8 8 248 8c66.8 0 123 24.5 166.3 64.9l-67.5 64.9C258.5 52.6 94.3 116.6 94.3 256c0 86.5 69.1 156.6 153.7 156.6 98.2 0 135-70.4 140.8-106.9H248v-85.3h236.1c2.3 12.7 3.9 24.9 3.9 41.4z"/>
                                  </svg>
                                  ''',
                                  width: socialIconSize,
                                  height: socialIconSize,
                                ),
                              ),
                              SizedBox(width: spacing / 1.5),
                              // facebook
                              IconButton(
                                onPressed: () async {
                                  final user =
                                      await AuthService().signInWithFacebook();
                                  if (user != null) {
                                    print(
                                      "✅ Facebook login: ${user.displayName}",
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

                                style: IconButton.styleFrom(
                                  backgroundColor: Color.fromARGB(
                                    255,
                                    7,
                                    109,
                                    242,
                                  ),
                                  padding: EdgeInsets.all(socialIconSize * 0.3),
                                ),
                                icon: SvgPicture.string(
                                  '''
                                  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 320 512">
  <path fill="white" d="M279.14 288l14.22-92.66h-88.91V117.36c0-25.35 12.42-50.06 52.24-50.06h40.42V6.26S293.67 0 262.4 0c-73.22 0-121.12 44.38-121.12 124.72v70.62H83.88V288h57.4v224h104.1V288z"/>
</svg>
''',
                                  width: socialIconSize,
                                  height: socialIconSize,
                                ),
                              ),
                              SizedBox(width: spacing / 1.5),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: spacing * 0.5),

                      // Terms & Conditions
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: "By signing up, you agree to our ",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                            children: [
                              TextSpan(
                                text: "Terms & Conditions",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer:
                                    TapGestureRecognizer()
                                      ..onTap = () {
                                        launchURL("https://your-terms-url.com");
                                      },
                              ),
                              const TextSpan(
                                text: " and ",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                              TextSpan(
                                text: "Privacy Policy",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer:
                                    TapGestureRecognizer()
                                      ..onTap = () {
                                        launchURL(
                                          "https://your-privacy-url.com",
                                        );
                                      },
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: spacing),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    IconData icon,
    double fontSize, {
    bool isPassword = false,
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool? passwordVisible,
    Function()? togglePasswordVisibility,
    String? errorText,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? !(passwordVisible ?? false) : false,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey, size: fontSize * 1.2),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        errorText: errorText,
        errorStyle: const TextStyle(
          fontSize: 8, // 👈 smaller error font
          height: 1.2, // 👈 adjust spacing
          color: Colors.red,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(fontSize),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(fontSize),
          borderSide: const BorderSide(color: Colors.black, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 12,
        ),
        suffixIcon:
            isPassword
                ? IconButton(
                  icon: Icon(
                    (passwordVisible ?? false)
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: togglePasswordVisibility,
                )
                : null,
      ),
      style: TextStyle(fontSize: fontSize, color: Colors.black),
    );
  }
}
