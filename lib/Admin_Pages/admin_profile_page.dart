import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'users_mangment_page.dart';
import 'report_page.dart';
import 'add_admin_page.dart';
import 'package:shoe_store_app/User_Pages/login_page.dart';

class AdminProfilePage extends StatelessWidget {
  const AdminProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        title: const Text(
          'Admin Profile',
          style: TextStyle(
            color: Color(0xFF0d141c),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          children: [
            // Logo
            Center(
              child: CircleAvatar(
                radius: 64,
                backgroundImage: NetworkImage(
                    "https://your-logo-url.com/logo.png"), // replace with your logo
              ),
            ),
            const SizedBox(height: 16),
            // Admin Name
            Center(
              child: Text(
                user?.displayName ?? 'Admin Name',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0d141c),
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Admin Email
            Center(
              child: Text(
                user?.email ?? 'admin@example.com',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF49709c),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Action Buttons
            _actionButton(
              context,
              icon: Icons.person_add,
              label: 'Add Admin',
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddAdminPage()),
                    
                  );
              },
            ),
            _actionButton(
              context,
              icon: Icons.group,
              label: 'Users Page',
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UsersManagementPage()),
                    
                  );
              },
            ),
            _actionButton(
              context,
              icon: Icons.bar_chart,
              label: 'Reports Page',
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
                    
                  );
              },
            ),
            _actionButton(
              context,
              icon: Icons.logout,
              label: 'Logout',
              onTap: () async {
                  await FirebaseAuth.instance.signOut(); // 👈 actually sign out

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                },
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap,
      Color color = const Color(0xFF0D78F2)}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 28),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onTap,
      ),
    );
  }
}
