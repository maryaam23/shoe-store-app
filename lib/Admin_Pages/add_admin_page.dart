import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class AddAdminPage extends StatefulWidget {
  const AddAdminPage({super.key});

  @override
  State<AddAdminPage> createState() => _AddAdminPageState();
}

class _AddAdminPageState extends State<AddAdminPage> {
  final _formKey = GlobalKey<FormState>();
  final _controllerEmail = TextEditingController();
  final _controllerPassword = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
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
      final FirebaseApp secondaryApp = await Firebase.initializeApp(
        name: 'Secondary',
        options: Firebase.app().options,
      );

      final auth = FirebaseAuth.instanceFor(app: secondaryApp);

      UserCredential userCred = await auth.createUserWithEmailAndPassword(
        email: _controllerEmail.text.trim(),
        password: _controllerPassword.text.trim(),
      );

      User newUser = userCred.user!;
      await newUser.sendEmailVerification();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(newUser.uid)
          .set({
            "fullName": _nameController.text.trim(),
            "email": newUser.email,
            "role": "admin",
            "createdAt": FieldValue.serverTimestamp(),
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Admin added successfully! Verification email sent."),
          ),
        );
      }

      _controllerEmail.clear();
      _controllerPassword.clear();
      _nameController.clear();

      await auth.signOut();
      await secondaryApp.delete();
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

  // Helper functions for responsive sizing
  double w(BuildContext context, double fraction) =>
      MediaQuery.of(context).size.width * fraction;
  double h(BuildContext context, double fraction) =>
      MediaQuery.of(context).size.height * fraction;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true, // ✅ allows resizing when keyboard opens
      appBar: AppBar(
        title: const Text(""),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
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
        // ✅ Make the inner container scrollable
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            width: w(context, 0.92),
            margin: EdgeInsets.all(w(context, 0.04)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(w(context, 0.06)),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
              color: Colors.white,
            ),
            padding: EdgeInsets.all(w(context, 0.05)),
            // ✅ Wrap column in SafeArea so it doesn’t go under keyboard/notch
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Add Another Admin",
                        style: TextStyle(
                          fontSize: w(context, 0.065),
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(width: w(context, 0.02)),
                      Image.asset(
                        "assets/logoImage.png",
                        width: w(context, 0.15),
                        height: w(context, 0.15),
                      ),
                    ],
                  ),
                  SizedBox(height: h(context, 0.02)),

                  _waitingForVerification
                      ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          SizedBox(height: h(context, 0.02)),
                          Text(
                            "Waiting for the new admin to verify their email...",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: w(context, 0.04)),
                          ),
                        ],
                      )
                      : Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Full Name
                            TextFormField(
                              controller: _nameController,
                              style: TextStyle(fontSize: w(context, 0.045)),
                              decoration: InputDecoration(
                                labelText: "Full Name",
                                prefixIcon: Icon(
                                  Icons.badge_outlined,
                                  size: w(context, 0.06),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    w(context, 0.04),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    w(context, 0.04),
                                  ),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter full name.";
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: h(context, 0.02)),

                            // Email
                            TextFormField(
                              controller: _controllerEmail,
                              style: TextStyle(fontSize: w(context, 0.045)),
                              decoration: InputDecoration(
                                labelText: "Username",
                                prefixIcon: Icon(
                                  Icons.person_outline,
                                  size: w(context, 0.06),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    w(context, 0.04),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    w(context, 0.04),
                                  ),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              onEditingComplete:
                                  () => _focusNodePassword.requestFocus(),
                              validator: (value) {
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
                            SizedBox(height: h(context, 0.02)),

                            // Password
                            TextFormField(
                              controller: _controllerPassword,
                              focusNode: _focusNodePassword,
                              obscureText: _obscurePassword,
                              style: TextStyle(fontSize: w(context, 0.045)),
                              decoration: InputDecoration(
                                labelText: "Password",
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  size: w(context, 0.06),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: w(context, 0.06),
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
                                    w(context, 0.04),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    w(context, 0.04),
                                  ),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter password.";
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: h(context, 0.03)),

                            // Add Admin button
                            SizedBox(
                              width: w(context, 0.6),
                              height: h(context, 0.06),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      w(context, 0.05),
                                    ),
                                  ),
                                  elevation: 5,
                                ),
                                onPressed: _isLoading ? null : _addAdmin,
                                child:
                                    _isLoading
                                        ? SizedBox(
                                          width: w(context, 0.05),
                                          height: w(context, 0.05),
                                          child:
                                              const CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                        )
                                        : Text(
                                          "Add Admin",
                                          style: TextStyle(
                                            fontSize: w(context, 0.04),
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
        ),
      ),
    );
  }
}
