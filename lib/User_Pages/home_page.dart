import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_detailes_page.dart';
import 'profile_page.dart';
import 'categories_page.dart';
import 'wishlist_page.dart';
import 'cart_page.dart';
import 'user_notification_page.dart';
import 'product_page.dart'; // your Product model

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<String> pageTitles = [
    "Sport Brands",
    "Cart Page",
    "Wishlist Page",
    "My Profile",
  ];

  // Remove pages initialization from initState
  // We'll build pages lazily in IndexedStack

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
          style: TextStyle(
              color: Colors.black,
              fontSize: w * 0.05,
              fontWeight: FontWeight.bold),
        ),
        actions: _selectedIndex == 0
            ? [
                IconButton(
                  icon: Icon(Icons.notifications, color: Colors.black, size: w * 0.07),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const NotificationScreen()));
                  },
                ),
                IconButton(
                  icon: Icon(Icons.list, color: Colors.black, size: w * 0.07),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CategoriesPage()));
                  },
                ),
              ]
            : null,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          buildHomeBody(), // Home page lazily built here
          const CartPage(),
          const WishlistPage(),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home, size: w * 0.06), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart, size: w * 0.06), label: "Cart"),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border, size: w * 0.06), label: "Wishlist"),
          BottomNavigationBarItem(icon: Icon(Icons.person, size: w * 0.06), label: "Profile"),
        ],
      ),
    );
  }

  // Home Body with Firestore Products
  Widget buildHomeBody() {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Optional banners
          SizedBox(
            height: h * 0.2,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.all(w * 0.03),
              itemCount: 3, // example banner count
              separatorBuilder: (_, __) => SizedBox(width: w * 0.03),
              itemBuilder: (_, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(w * 0.03),
                  child: Image.network(
                    "https://picsum.photos/500/200?${index + 1}",
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

          // Firestore Products Grid
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('products').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No products found."));
              }

              List<Product> products = snapshot.data!.docs
                  .map((doc) => Product.fromFirestore(doc))
                  .toList();

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: w * 0.04),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: h * 0.015,
                  crossAxisSpacing: w * 0.03,
                  childAspectRatio: 0.7,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailPage(product: product),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(w * 0.03),
                          child: product.image.startsWith('http')
                              ? Image.network(
                                  product.image,
                                  height: h * 0.15,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  product.image,
                                  height: h * 0.15,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        SizedBox(height: h * 0.01),
                        Text(
                          product.name,
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: w * 0.04),
                        ),
                        Text(
                          "\$${product.price.toStringAsFixed(2)}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: w * 0.04,
                              color: Colors.deepOrange),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
