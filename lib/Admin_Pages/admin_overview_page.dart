import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shoe_store_app/Admin_Pages/admin_notification_screen.dart';
import 'package:shoe_store_app/Admin_Pages/orders_mangment_page.dart';
import 'package:shoe_store_app/Admin_Pages/product_mangment_page.dart';
import 'package:shoe_store_app/Admin_Pages/admin_profile_page.dart';
import 'package:shoe_store_app/User_Pages/brands_page.dart';
import 'package:shoe_store_app/User_Pages/product_grid.dart';
import 'package:shoe_store_app/firestore_service.dart';
import 'package:shoe_store_app/User_Pages/product_page.dart'; // Product, ProductGrid

void main() => runApp(AdminOverviewApp());

class AdminOverviewApp extends StatelessWidget {
  const AdminOverviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AdminOverviewScreen(),
    );
  }
}

class AdminOverviewScreen extends StatefulWidget {
  const AdminOverviewScreen({super.key});

  @override
  _AdminOverviewScreenState createState() => _AdminOverviewScreenState();
}

class _AdminOverviewScreenState extends State<AdminOverviewScreen> {
  int _currentIndex = 0;
  Set<String> allColors = {};
  Set<String> allSizes = {};
  String? selectedColor;
  String? selectedSize;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;
  final TextEditingController searchController = TextEditingController();

  late Stream<QuerySnapshot> cartStream;
  late Stream<QuerySnapshot> wishlistStream;
  late Stream<QuerySnapshot> unreadNotificationsStream;

  String currentUserRole = 'user'; // default

  @override
  void initState() {
    super.initState();
    fetchUserRole();
    cartStream = FirestoreService.getCart();
    wishlistStream = FirestoreService.getWishlist();

    unreadNotificationsStream =
        FirebaseFirestore.instance
            .collection('admin_noti')
            .where('isRead', isEqualTo: false)
            .snapshots();

    searchController.addListener(() {
      setState(() {});
    });

    fetchAllColorsAndSizes();
  }

  Future<void> fetchUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      if (doc.exists) {
        setState(() {
          currentUserRole = doc.data()?['role'] ?? 'user';
        });
      }
    }
  }

  Future<void> fetchAllColorsAndSizes() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('Nproducts')
            .where('visible', isEqualTo: true)
            .get();

    Set<String> colors = {};
    Set<String> sizes = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data['variants'] != null) {
        final variants = Map<String, dynamic>.from(data['variants']);
        colors.addAll(variants.keys.map((k) => k.toUpperCase()));

        for (var sizeMap in variants.values) {
          final sizesMap = Map<String, dynamic>.from(sizeMap);
          sizes.addAll(sizesMap.keys.map((s) => s.toString()));
        }
      }
    }

    setState(() {
      allColors = SplayTreeSet<String>.from(colors);
      allSizes = SplayTreeSet<String>.from(sizes);
    });
  }

  Color _colorFromHex(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  final List<Widget> _pages = [];

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    // Initialize pages with proper buildHomeBody
    final _pages = [
      buildHomeBody(w, h),
      OrderManagementScreen(),
      ProductManagementScreen(),
      AdminProfilePage(),
    ];

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.blueGrey,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: "Orders"),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: "Products",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Profile"),
        ],
      ),
    );
  }

  Widget buildHomeBody(double w, double h) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink.shade400,
        title: const Text(
          "Admin Overview",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 4,
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: unreadNotificationsStream,
            builder: (context, snapshot) {
              int unreadCount = 0;
              if (snapshot.hasData) {
                unreadCount = snapshot.data!.docs.length;
              }

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminNotificationScreen(),
                        ),
                      );
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 10,
                      top: 10,
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
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            Padding(
              padding: EdgeInsets.all(w * 0.02),
              child: SizedBox(
                height: h * 0.05,
                child: TextField(
                  controller: searchController,
                  style: TextStyle(fontSize: w * 0.04),
                  decoration: InputDecoration(
                    hintText: "Search by name, brand, category",
                    hintStyle: TextStyle(fontSize: w * 0.035),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: h * 0.015,
                      horizontal: w * 0.05,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(w * 0.03),
                      borderSide: const BorderSide(color: Colors.pink),
                    ),
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: w * 0.02, right: w * 0.01),
                      child: Icon(
                        Icons.search,
                        color: Colors.pink,
                        size: w * 0.045,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            BrandsBar(),

            // Color picker
            SizedBox(
              height: h * 0.03,
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: w * 0.04, right: w * 0.02),
                    child: Text(
                      "Colors:",
                      style: TextStyle(
                        fontSize: w * 0.025,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child:
                        allColors.isEmpty
                            ? Center(child: CircularProgressIndicator())
                            : ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      searchController.clear();
                                      selectedColor = null;
                                    });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(right: w * 0.01),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: w * 0.015,
                                      vertical: h * 0.008,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                        168,
                                        224,
                                        224,
                                        224,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        w * 0.08,
                                      ),
                                      border: Border.all(
                                        color:
                                            selectedColor == null
                                                ? Colors.black
                                                : Colors.black12,
                                        width: selectedColor == null ? 2 : 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "All",
                                        style: TextStyle(
                                          fontSize: w * 0.018,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                ...allColors.map((hex) {
                                  Color color;
                                  try {
                                    color = _colorFromHex(hex);
                                  } catch (e) {
                                    color = Colors.grey;
                                  }
                                  return GestureDetector(
                                    onTap:
                                        () =>
                                            setState(() => selectedColor = hex),
                                    child: Container(
                                      margin: EdgeInsets.only(right: w * 0.01),
                                      width: w * 0.03,
                                      height: w * 0.03,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color:
                                              selectedColor == hex
                                                  ? Colors.black
                                                  : Colors.black12,
                                          width: selectedColor == hex ? 2 : 1,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                  ),
                ],
              ),
            ),

            // Size picker
            SizedBox(
              height: h * 0.03,
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: w * 0.04, right: w * 0.02),
                    child: Text(
                      "Sizes:",
                      style: TextStyle(
                        fontSize: w * 0.025,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child:
                        allSizes.isEmpty
                            ? Center(child: CircularProgressIndicator())
                            : ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                GestureDetector(
                                  onTap:
                                      () => setState(() => selectedSize = null),
                                  child: Container(
                                    margin: EdgeInsets.only(right: w * 0.01),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: w * 0.015,
                                      vertical: h * 0.008,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                        168,
                                        224,
                                        224,
                                        224,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        w * 0.08,
                                      ),
                                      border: Border.all(
                                        color:
                                            selectedSize == null
                                                ? Colors.black
                                                : Colors.black12,
                                        width: selectedSize == null ? 2 : 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "All",
                                        style: TextStyle(
                                          fontSize: w * 0.018,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                ...allSizes.map(
                                  (size) => GestureDetector(
                                    onTap:
                                        () =>
                                            setState(() => selectedSize = size),
                                    child: Container(
                                      margin: EdgeInsets.only(right: w * 0.01),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: w * 0.015,
                                        vertical: h * 0.008,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                          168,
                                          224,
                                          224,
                                          224,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          w * 0.08,
                                        ),
                                        border: Border.all(
                                          color:
                                              selectedSize == size
                                                  ? Colors.black
                                                  : Colors.black12,
                                          width: selectedSize == size ? 2 : 1,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          size,
                                          style: TextStyle(
                                            fontSize: w * 0.018,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
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

            // Firestore Products
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('Nproducts')
                      .where('visible', isEqualTo: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: SizedBox(
                      height: h * 0.05,
                      width: h * 0.05,
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      "No products found.",
                      style: TextStyle(fontSize: w * 0.04),
                    ),
                  );
                }

                final products =
                    snapshot.data!.docs
                        .map((doc) => Product.fromFirestore(doc))
                        .toList();

                final filtered =
                    products.where((p) {
                      final searchText =
                          searchController.text.trim().toLowerCase();
                      final matchesSearch =
                          searchText.isEmpty ||
                          p.name.toLowerCase().contains(searchText) ||
                          p.category.toLowerCase().contains(searchText) ||
                          (p.brand != null &&
                              p.brand!.toLowerCase().contains(searchText));

                      bool matchesFilters = true;

                      if (selectedColor != null && selectedSize != null) {
                        matchesFilters =
                            p.variants != null &&
                            p.variants!.keys.any(
                              (colorKey) =>
                                  colorKey.toUpperCase() ==
                                      selectedColor!.toUpperCase() &&
                                  p.variants![colorKey]!.keys.any(
                                    (s) => s.toString() == selectedSize,
                                  ),
                            );
                      } else if (selectedColor != null) {
                        matchesFilters =
                            p.variants != null &&
                            p.variants!.keys.any(
                              (colorKey) =>
                                  colorKey.toLowerCase() ==
                                  selectedColor!.toLowerCase(),
                            );
                      } else if (selectedSize != null) {
                        matchesFilters =
                            p.variants != null &&
                            p.variants!.values.any(
                              (sizeMap) => sizeMap.keys.any(
                                (s) => s.toString() == selectedSize,
                              ),
                            );
                      }

                      return matchesSearch && matchesFilters;
                    }).toList();

                return StreamBuilder<QuerySnapshot>(
                  stream: wishlistStream,
                  builder: (context, wishlistSnap) {
                    final wishlistIds =
                        wishlistSnap.hasData
                            ? wishlistSnap.data!.docs.map((d) => d.id).toSet()
                            : <String>{};

                    return StreamBuilder<QuerySnapshot>(
                      stream: cartStream,
                      builder: (context, cartSnap) {
                        final cartIds =
                            cartSnap.hasData
                                ? cartSnap.data!.docs.map((d) => d.id).toSet()
                                : <String>{};

                        return ProductGrid(
                          products: filtered,
                          cartIds: cartIds,
                          wishlistIds: wishlistIds,
                          w: w,
                          h: h,
                          role: currentUserRole, // <-- pass the role here
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
