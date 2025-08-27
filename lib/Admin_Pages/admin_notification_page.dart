import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample notifications list
    final notifications = [
      {
        'title': 'Low Stock Alert',
        'subtitle': '10 pairs of sneakers are running low',
        'icon': Icons.local_shipping,
        'color': Colors.blueGrey[100]
      },
      {
        'title': 'New Orders',
        'subtitle': 'You have 3 new orders to process',
        'icon': Icons.receipt_long,
        'color': Colors.blueGrey[100]
      },
      {
        'title': 'Customer Message',
        'subtitle': 'Customer: Sarah has a question about her order',
        'icon': Icons.chat_bubble_outline,
        'color': Colors.blueGrey[100]
      },
      {
        'title': 'Professional Enhancements',
        'subtitle': 'New feature: Enhanced analytics dashboard',
        'icon': Icons.bar_chart,
        'color': Colors.blueGrey[100]
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Color(0xFF0D141C),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0D141C)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.grey[50],
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: notification['color'] as Color?,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  notification['icon'] as IconData,
                  color: const Color(0xFF0D141C),
                ),
              ),
              title: Text(
                notification['title'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0D141C),
                ),
              ),
              subtitle: Text(
                notification['subtitle'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  color: Color(0xFF49709C),
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.close, color: Color(0xFF0D141C)),
                onPressed: () {},
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0D141C),
        unselectedItemColor: const Color(0xFF49709C),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping_outlined),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
