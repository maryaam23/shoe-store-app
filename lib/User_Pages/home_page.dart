import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_page.dart';
import 'categories_page.dart';
import 'product_page.dart';
import 'wishlist_page.dart';
import 'cart_page.dart';
import 'user_notification_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Example banners & featured products
  final List<String> banners = [
    "https://picsum.photos/500/200?1",
    "https://picsum.photos/500/200?2",
    "https://picsum.photos/500/200?3",
  ];

  final List<Map<String, String>> featured = [
    {"title": "Running Shoes", "img": "https://picsum.photos/200?1"},
    {"title": "Basketball Shoes", "img": "https://picsum.photos/200?2"},
    {"title": "Casual Shoes", "img": "https://picsum.photos/200?3"},
    {"title": "Training Shoes", "img": "https://picsum.photos/200?4"},
  ];

  final List<String> pageTitles = [
    "Sport Brands",
    "Cart Page",
    "Wishlist Page",
    "Profile",
  ];

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      buildHomeBody(), // Home
      const CartPage(), // Cart
      const WishlistPage(), // Wishlist
      const ProfilePage(), // Profile
    ];
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey[50],
        centerTitle: true,
        title: Text(
          pageTitles[_selectedIndex],
          style: TextStyle(color: Colors.black, fontSize: w * 0.05),
        ),
        actions: _selectedIndex == 0
            ? [
                // Only show these icons on Home
                IconButton(
                  icon: Icon(
                    Icons.notifications,
                    color: Colors.black,
                    size: w * 0.07,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const NotificationScreen()),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.list, color: Colors.black, size: w * 0.07),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CategoriesPage()),
                    );
                  },
                ),
              ]
            : null, // No icons on other tabs
      ),
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: w * 0.06),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart, size: w * 0.06),
            label: "Cart",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border, size: w * 0.06),
            label: "Wishlist",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: w * 0.06),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  // Home Body
  Widget buildHomeBody() {
    return Builder(
      builder: (context) {
        double w = MediaQuery.of(context).size.width;
        double h = MediaQuery.of(context).size.height;

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
                  style: TextStyle(
                    fontSize: w * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
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
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProductPage()),
                      );
                    },
                    child: Column(
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
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
