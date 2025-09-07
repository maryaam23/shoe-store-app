import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'profile_page.dart'; // Import the separate profile page
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🔹 Banner images
  final List<String> banners = [
    "https://picsum.photos/500/200?1",
    "https://picsum.photos/500/200?2",
    "https://picsum.photos/500/200?3",
  ];

  // 🔹 Featured products
  final List<Map<String, String>> featured = [
    {"title": "Running Shoes", "img": "https://picsum.photos/200?1"},
    {"title": "Basketball Shoes", "img": "https://picsum.photos/200?2"},
    {"title": "Casual Shoes", "img": "https://picsum.photos/200?3"},
    {"title": "Training Shoes", "img": "https://picsum.photos/200?4"},
  ];

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    Widget bodyContent() {
      switch (_selectedIndex) {
        case 0:
          return buildHomeBody(w, h);
        case 1:
          return Center(
              child:
                  Text("Categories Page", style: TextStyle(fontSize: w * 0.05)));
        case 2:
          return Center(
              child:
                  Text("Wishlist Page", style: TextStyle(fontSize: w * 0.05)));
        case 3:
          return ProfilePage(); // Navigate to separate ProfilePage class
        default:
          return buildHomeBody(w, h);
      }
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey[50],
        centerTitle: true,
        title: Text(
          _selectedIndex == 3 ? "Profile" : "Sport Brands",
          style: TextStyle(color: Colors.black, fontSize: w * 0.05),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await _auth.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false);
            },
            icon: Icon(Icons.logout, color: Colors.black, size: w * 0.07),
          ),
        ],
      ),
      body: bodyContent(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home, size: w * 0.06), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.list, size: w * 0.06), label: "Categories"),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border, size: w * 0.06),
              label: "Wishlist"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person, size: w * 0.06), label: "Profile"),
        ],
      ),
    );
  }

  // 🔹 Home Body
  Widget buildHomeBody(double w, double h) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banners
          SizedBox(
            height: h * 0.2,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.all(w * 0.03),
              itemCount: banners.length,
              separatorBuilder: (_, __) => SizedBox(width: w * 0.03),
              itemBuilder: (_, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(w * 0.03),
                  child: Image.network(
                    banners[index],
                    width: w * 0.6,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: h * 0.02),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.04),
            child: Text(
              "Featured",
              style: TextStyle(fontSize: w * 0.05, fontWeight: FontWeight.bold),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: w * 0.04),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: h * 0.015,
              crossAxisSpacing: w * 0.03,
              childAspectRatio: 0.8,
            ),
            itemCount: featured.length,
            itemBuilder: (context, index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(w * 0.03),
                    child: Image.network(
                      featured[index]["img"]!,
                      height: h * 0.15,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: h * 0.01),
                  Text(
                    featured[index]["title"]!,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: w * 0.04,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
