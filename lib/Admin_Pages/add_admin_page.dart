import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'admin_profile_page.dart';

class AddAdminPage extends StatefulWidget {
  const AddAdminPage({super.key});

  @override
  State<AddAdminPage> createState() => _AddAdminPageState();
}

class _AddAdminPageState extends State<AddAdminPage> {
  final _formKey = GlobalKey<FormState>();
  final _controllerEmail = TextEditingController();
  final _controllerPassword = TextEditingController();
  final FocusNode _focusNodePassword = FocusNode();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _waitingForVerification = false;

  @override
  void dispose() {
    _controllerEmail.dispose();
    _controllerPassword.dispose();
    _focusNodePassword.dispose();
    super.dispose();
  }

  Future<void> _addAdmin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Initialize secondary app
      final FirebaseApp secondaryApp = await Firebase.initializeApp(
        name: 'Secondary',
        options: Firebase.app().options,
      );

      final auth = FirebaseAuth.instanceFor(app: secondaryApp);

      // Create new admin user
      UserCredential userCred = await auth.createUserWithEmailAndPassword(
        email: _controllerEmail.text.trim(),
        password: _controllerPassword.text.trim(),
      );

      User newUser = userCred.user!;

      // Send email verification
      await newUser.sendEmailVerification();

      // Add user info to Firestore immediately
      await FirebaseFirestore.instance
          .collection('users')
          .doc(newUser.uid)
          .set({
            "email": newUser.email,
            "role": "admin",
            "createdAt": FieldValue.serverTimestamp(),
          });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Admin added successfully! Verification email sent."),
          ),
        );
      }

      // Clear the text fields
      _controllerEmail.clear();
      _controllerPassword.clear();

      // Sign out secondary app
      await auth.signOut();
      await secondaryApp.delete();

      // Do NOT navigate or pop, stay on page
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Failed to add admin")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double buttonHeight = size.height * 0.065;
    final double buttonFontSize = size.width * 0.035;
    final double inputFontSize = size.width * 0.045;
    final double spacing = size.height * 0.02;
    final double logoSize = size.width * 0.2;

    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        // no leading here → back arrow appears automatically
      ),

      body: Container(
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

        child: Container(
          width: size.width * 0.92,
          height: double.infinity,
          margin: EdgeInsets.all(size.width * 0.04),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size.width * 0.06),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
            color: Colors.white,
          ),
          padding: EdgeInsets.all(size.width * 0.05),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title and logo row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Add Another Admin",
                    style: TextStyle(
                      fontSize: size.width * 0.065,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
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

              _waitingForVerification
                  ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        "Waiting for the new admin to verify their email...",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  )
                  : Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Username field
                        TextFormField(
                          controller: _controllerEmail,
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
                                  () => _obscurePassword = !_obscurePassword,
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
                        SizedBox(height: spacing),

                        // Add Admin button
                        SizedBox(
                          height: buttonHeight,
                          width: 170, // adjust width as needed
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
                              shadowColor: const Color.fromARGB(255, 0, 0, 0),
                              elevation: 5,
                            ),
                            onPressed: _isLoading ? null : _addAdmin,
                            child:
                                _isLoading
                                    ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : Text(
                                      "Add Admin",
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
            ],
          ),
        ),
      ),
    );
  }
}
