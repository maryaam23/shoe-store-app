import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_detailes_page.dart';
import 'profile_page.dart';
import 'categories_page.dart';
import 'wishlist_page.dart';
import 'cart_page.dart';
import 'user_notification_page.dart';
import 'product_page.dart'; // your Product model
import '../firestore_service.dart'; // FirestoreService class

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

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Local state to track added items
  Set<String> cartItems = {};
  Set<String> wishlistItems = {};

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child:Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey[50],
        centerTitle: true,
        title: Text(
          pageTitles[_selectedIndex],
          style: TextStyle(
            color: Colors.black,
            fontSize: w * 0.05,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions:
            _selectedIndex == 0
                ? [
                  StreamBuilder<QuerySnapshot>(
                    stream:
                        firestore
                            .collection("UserNotification")
                            .where("isRead", isEqualTo: false)
                            .snapshots(),
                    builder: (context, snapshot) {
                      int unreadCount =
                          snapshot.hasData ? snapshot.data!.docs.length : 0;

                      return Stack(
                        children: [
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
                                  builder: (_) => const NotificationScreen(),
                                ),
                              );
                            },
                          ),
                          if (unreadCount > 0)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  unreadCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.list, color: Colors.black, size: w * 0.07),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CategoriesPage(),
                        ),
                      );
                    },
                  ),
                ]
                : null,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          buildHomeBody(w, h),
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
      ),
    );
    
  }

  Widget buildHomeBody(double w, double h) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner example
          SizedBox(
            height: h * 0.2,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.all(w * 0.03),
              itemCount: 3,
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
          // Firestore Products
          StreamBuilder<QuerySnapshot>(
            stream: firestore.collection('Nproducts').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No products found."));
              }

              final products =
                  snapshot.data!.docs
                      .map((doc) => Product.fromFirestore(doc))
                      .toList();

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: w * 0.04,
                  vertical: h * 0.02,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: h * 0.015,
                  crossAxisSpacing: w * 0.03,
                  childAspectRatio: 0.7,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];

                  final isInCart = cartItems.contains(product.id);
                  final isInWishlist = wishlistItems.contains(product.id);

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailPage(product: product),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(w * 0.01),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(w * 0.01),
                              child:
                                  product.image.startsWith('http')
                                      ? Image.network(
                                        product.image,
                                        height: h * 0.2,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      )
                                      : Image.asset(
                                        product.image,
                                        height: h * 0.2,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                            ),
                            SizedBox(height: h * 0.01),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: w * 0.02,
                              ),
                              child: Text(
                                product.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: w * 0.05,
                                ),
                              ),
                            ),
                            SizedBox(height: h * 0.005),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: w * 0.02,
                              ),
                              child: Text(
                                "₪${product.price.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: w * 0.04,
                                  color: const Color.fromARGB(
                                    255,
                                    254,
                                    111,
                                    68,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: h * 0.02),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: w * 0.02,
                              ),
                              child: Row(
                                children: [
                                  SizedBox(width: w * 0.06),
                                  // Add to Cart icon
                                  Container(
                                    width: w * 0.12,
                                    height: h * 0.05,
                                    decoration: BoxDecoration(
                                      color:
                                          isInCart
                                              ? Colors.green
                                              : const Color.fromARGB(
                                                255,
                                                246,
                                                79,
                                                67,
                                              ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      iconSize: w * 0.06,
                                      icon: const Icon(
                                        Icons.add_shopping_cart_outlined,
                                        color: Colors.white,
                                      ),
                                      onPressed: () async {
                                        await FirestoreService.addToCart(
                                          product,
                                        );
                                        setState(() {
                                          cartItems.add(product.id);
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(width: w * 0.04),
                                  // Wishlist love icon
                                  Container(
                                    width: w * 0.12,
                                    height: h * 0.05,
                                    decoration: BoxDecoration(
                                      color:
                                          isInWishlist
                                              ? Colors.pink
                                              : const Color.fromARGB(
                                                255,
                                                246,
                                                79,
                                                67,
                                              ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      iconSize: w * 0.055,
                                      icon: const Icon(
                                        Icons.favorite,
                                        color: Colors.white,
                                      ),
                                      onPressed: () async {
                                        await FirestoreService.addToWishlist(
                                          product,
                                        );
                                        setState(() {
                                          wishlistItems.add(product.id);
                                        });
                                      },
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
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
