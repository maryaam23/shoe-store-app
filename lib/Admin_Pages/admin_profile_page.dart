import 'package:flutter/material.dart';

void main() => runApp(const AdminProfilePage());

class AdminProfilePage extends StatelessWidget {
  const AdminProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey[50],
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.grey[50],
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF0d141c)),
                      onPressed: () {},
                    ),
                    const Expanded(
                      child: Text(
                        'Admin Profile',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF0d141c),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // placeholder to center title
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Profile Info
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 64,
                    backgroundImage: NetworkImage(
                        "https://lh3.googleusercontent.com/aida-public/AB6AXuBOCQ2cEYrJ7vVqtoE_Jk961EPKaZDm_ELcXTlr5pdydBxYl0asGdDcJ6M-C5TTnOfJUjho7nyEWRVPuMsDc22w2rBnSBNURGczS-MG2bhUihOQFwzbnJwwSyeHgafGSRk0OLvNqoz3XI1PO0CEA4skn7xgLW4OXBxNfLxzdG4jCF2s9xt3g-OtkM6BjKNuaxx0rAjmQY30S20xKP-sL9pscSGXv7cuzsZkxeiF45P4jsU_2zUhHH6-ycoPs1IgCRG9sIltTGl_6L-R"),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Ethan Carter',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0d141c)),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'ethan.carter@email.com',
                    style: TextStyle(fontSize: 16, color: Color(0xFF49709c)),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '+1 (555) 123-4567',
                    style: TextStyle(fontSize: 16, color: Color(0xFF49709c)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Account Input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Account',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0d141c)),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Enter account info',
                        filled: true,
                        fillColor: Color(0xFFe7edf4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Preferences',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0d141c)),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Notifications',
                            style: TextStyle(
                                fontSize: 16, color: Color(0xFF0d141c))),
                        Switch(
                          value: true,
                          onChanged: (val) {},
                          activeColor: Color(0xFF0d78f2),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Professional Enhancements',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0d141c)),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Dark Mode',
                            style: TextStyle(
                                fontSize: 16, color: Color(0xFF0d141c))),
                        Switch(
                          value: false,
                          onChanged: (val) {},
                          activeColor: Color(0xFF0d78f2),
                        )
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Activity Log',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0d141c)),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: [
                        activityItem('Product added: Air Zoom Pegasus 38',
                            '2024-01-20 14:30'),
                        activityItem('Inventory updated: Air Zoom Pegasus 38',
                            '2024-01-19 11:15'),
                        activityItem('Order processed: #12345', '2024-01-18 09:45'),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: const Color(0xFF0d141c),
          unselectedItemColor: const Color(0xFF49709c),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.sports_handball), label: 'Products'),
            BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long), label: 'Orders'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget activityItem(String title, String date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
          color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0d141c))),
          const SizedBox(height: 2),
          Text(date,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Color(0xFF49709c))),
        ],
      ),
    );
  }
}
