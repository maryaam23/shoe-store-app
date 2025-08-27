import 'package:flutter/material.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0D141C)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Color(0xFF0D141C),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // Profile Header
          Column(
            children: [
              const CircleAvatar(
                radius: 55,
                backgroundImage: NetworkImage(
                  "https://lh3.googleusercontent.com/aida-public/AB6AXuClA9ZzDGAJn6TGGWK0e9mPOdj0iu92cnh0KuPFC3sGbEPUuqit4iMNCObSlNcKfmnJo34JT92ozYlV7eFoI3nj7-9xjgigCYfnVO6tEmSc1DyenOnhPAB0pjvvV_dj5Obtrk4BLWXx1wzX8_1Xl8Bphw6XPdzxuEg31pnvIs05jd1hHuOMV6xp6WQisQi5vYDZ-MKrBYVH1GW8bHS1vQrAr9yU21d-ZCaRbkeK4oLigv1efgIuHib-D7uSnx27n6814CYKDyBnZzT9",
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Sophia Carter",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D141C),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "sophia.carter@email.com",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF49709C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Options List
          Expanded(
            child: ListView(
              children: [
                _buildOption(context, "Edit Profile"),
                _buildOption(context, "Saved Addresses"),
                _buildOption(context, "Payment Methods"),
                _buildOption(context, "Order History"),
                _buildOption(context, "Logout"),
              ],
            ),
          ),
        ],
      ),
      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0D141C),
        unselectedItemColor: const Color(0xFF49709C),
        currentIndex: 3,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Categories"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Wishlist"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, String title) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF0D141C),
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Color(0xFF0D141C)),
          onTap: () {
            // Handle navigation for each option
          },
        ),
        const Divider(height: 1, color: Color(0xFFE7EDF4)),
      ],
    );
  }
}
