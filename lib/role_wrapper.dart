import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shoe_store_app/Admin_Pages/admin_overview_page.dart';
import 'package:shoe_store_app/User_Pages/home_page.dart';
import 'package:shoe_store_app/User_Pages/login_page.dart';

class RoleWrapper extends StatelessWidget {
  const RoleWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Not logged in → show login page
      return const LoginPage();
    }

    // Logged in → listen to Firestore for role changes
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text("Error fetching user data")),
          );
        }

        final data = snapshot.data!;
        final role = data['role'];

        if (role == 'admin') {
          return  AdminOverviewScreen();
        } else {
          return HomePage();
        }
      },
    );
  }
}
