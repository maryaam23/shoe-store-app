import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoe_store_app/User_Pages/brands_page.dart';
import 'package:shoe_store_app/User_Pages/login_page.dart';
import 'package:shoe_store_app/User_Pages/product_grid.dart';
import 'product_detailes_page.dart';
import 'profile_page.dart';
import 'categories_page.dart';
import 'wishlist_page.dart';
import 'cart_page.dart';
import 'user_notification_page.dart';
import 'product_page.dart'; // Product model
import '../firestore_service.dart'; // FirestoreService class
import 'package:firebase_auth/firebase_auth.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:rxdart/rxdart.dart';

class HomePage extends StatefulWidget {
  final bool isGuest;
  const HomePage({super.key, this.isGuest = false});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  Set<String> allColors = {}; // store unique colors
  final List<String> pageTitles = [
    "Sport Brands",
    "Cart Page",
    "Wishlist Page",
    "My Profile",
  ];

  void logUserEntry() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);

    await userRef.update({
      'lastEnteredAt': FieldValue.serverTimestamp(), // 🕒 track last open time
    });

    // Optional: log every entry in a subcollection
    await userRef.collection('entries').add({
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;
  final TextEditingController searchController = TextEditingController();

  late Stream<QuerySnapshot> cartStream;
  late Stream<QuerySnapshot> wishlistStream;
  String? selectedColor; // null = "All" selected
  String? selectedSize; // null = "All" sizes selected
  Set<String> allSizes = {}; // to store unique sizes

  final Map<String, Color> colorNames = {
    "red": Colors.red,
    "blue": Colors.blue,
    "green": Colors.green,
    "yellow": Colors.yellow,
    "orange": Colors.orange,
    "pink": Colors.pink,
    "purple": Colors.purple,
    "brown": Colors.brown,
    "black": Colors.black,
    "white": Colors.white,
    "grey": Colors.grey,
  };

  @override
  void initState() {
    super.initState();
    cartStream = FirestoreService.getCart();
    wishlistStream = FirestoreService.getWishlist();

    searchController.addListener(() {
      setState(() {});
    });

    logUserEntry();
    fetchAllColorsAndSizes(); // force rebuild // ✅ Fetch colors
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
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
                    if (!widget.isGuest)
                      StreamBuilder<List<Map<String, dynamic>>>(
                        stream: CombineLatestStream.combine2<
                          QuerySnapshot,
                          QuerySnapshot,
                          List<Map<String, dynamic>>
                        >(
                          FirebaseFirestore.instance
                              .collection("UserNotification")
                              .where("isRead", isEqualTo: false)
                              .snapshots(),
                          FirebaseFirestore.instance
                              .collection("users")
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .collection("notification")
                              .where("isRead", isEqualTo: false)
                              .snapshots(),
                          (generalSnap, userSnap) {
                            List<Map<String, dynamic>> allDocs = [
                              ...generalSnap.docs.map(
                                (d) => {'doc': d, 'isUser': false},
                              ),
                              ...userSnap.docs.map(
                                (d) => {'doc': d, 'isUser': true},
                              ),
                            ];
                            return allDocs;
                          },
                        ),
                        builder: (context, snapshot) {
                          int unreadCount =
                              snapshot.hasData ? snapshot.data!.length : 0;

                          return Stack(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.notifications,
                                  color: Colors.black,
                                  size: w * 0.07,
                                ),
                                onPressed: () {
                                  if (widget.isGuest) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Please log in to view notifications.",
                                        ),
                                      ),
                                    );
                                  } else {
                                    final user =
                                        FirebaseAuth.instance.currentUser;
                                    if (user != null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => NotificationScreen(
                                                userId: user.uid,
                                              ),
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                              if (unreadCount > 0)
                                Positioned(
                                  right: w * 0.01,
                                  top: h * 0.008,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          unreadCount > 9
                                              ? w * 0.008
                                              : w * 0.010,
                                      vertical: w * 0.004,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(
                                        w * 0.02,
                                      ),
                                    ),
                                    constraints: BoxConstraints(
                                      minWidth: w * 0.035,
                                      minHeight: w * 0.035,
                                    ),
                                    child: Text(
                                      unreadCount > 99
                                          ? "99+"
                                          : unreadCount.toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: w * 0.027, // smaller text
                                        fontWeight: FontWeight.bold,
                                        height: 1.0,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    IconButton(
                      icon: Icon(
                        Icons.menu,
                        color: Colors.black,
                        size: w * 0.07,
                      ),
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
        body:
            _selectedIndex == 0
                ? buildHomeBody(w, h)
                : _selectedIndex == 1
                ? const CartPage()
                : _selectedIndex == 2
                ? const WishlistPage()
                : ProfilePage(isGuest: widget.isGuest),
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
          // 🔍 Search Bar
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
                    padding: EdgeInsets.only(
                      left: w * 0.02,
                      right: w * 0.01,
                    ), // move right
                    child: Icon(
                      Icons.search,
                      color: Colors.pink,
                      size: w * 0.045, // smaller size
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 🧩 Guest notice box
          if (widget.isGuest)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: w * 0.04,
                vertical: h * 0.01,
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(w * 0.04),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 244, 230),
                  borderRadius: BorderRadius.circular(w * 0.03),
                  border: Border.all(
                    color: Colors.orangeAccent,
                    width: w * 0.003,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange,
                      size: w * 0.06,
                    ),
                    SizedBox(width: w * 0.03),
                    Expanded(
                      child: Text(
                        "You are browsing now without logging in. To buy, please log in.",
                        style: TextStyle(
                          fontSize: w * 0.035,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    SizedBox(width: w * 0.02),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: w * 0.04,
                          vertical: h * 0.015,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(w * 0.02),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginPage(fromProfile: true),
                          ),
                        );
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(fontSize: w * 0.035),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 🟧 BrandsBar
          BrandsBar(),
          // Color Picker
          SizedBox(
            height: h * 0.03, // compact height
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
                              // Reset button
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

                              // Color circles
                              ...allColors.map((hex) {
                                Color color;
                                try {
                                  color = _colorFromHex(hex);
                                } catch (e) {
                                  color = Colors.grey;
                                }

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedColor = hex;
                                    });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(right: w * 0.01),
                                    child: Container(
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
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                ),
              ],
            ),
          ),

          SizedBox(height: h * 0.02),
          // Sizes Picker
          SizedBox(
            height: h * 0.03, // same compact height
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
                              // Reset "All" button
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedSize = null;
                                    searchController
                                        .clear(); // optional, only clear size filter
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

                              // Size buttons
                              ...allSizes.map((size) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedSize = size;
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
                                );
                              }).toList(),
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
              style: TextStyle(fontSize: w * 0.05, fontWeight: FontWeight.bold),
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
                    child: const CircularProgressIndicator(),
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

              final searchText =
                  searchController.text
                      .trim()
                      .replaceAll(RegExp(r'\s+'), ' ')
                      .toLowerCase();

              final filtered =
                  products.where((p) {
                    final searchText =
                        searchController.text.trim().toLowerCase();

                    // 🔎 Search filter
                    final matchesSearch =
                        searchText.isEmpty ||
                        p.name.toLowerCase().contains(searchText) ||
                        p.category.toLowerCase().contains(searchText) ||
                        (p.brand != null &&
                            p.brand!.toLowerCase().contains(searchText));

                    // 🎨 Color + size filter
                    bool matchesFilters = true;

                    if (selectedColor != null && selectedSize != null) {
                      // BOTH color and size selected: strict equality
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
                      // Only color selected: any size under that color counts
                      matchesFilters =
                          p.variants != null &&
                          p.variants!.keys.any(
                            (colorKey) =>
                                colorKey.toLowerCase() ==
                                selectedColor!.toLowerCase(),
                          );
                    } else if (selectedSize != null) {
                      // Only size selected: strict equality for size
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
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Color _colorFromHex(String hex) {
    hex = hex.replaceAll('#', ''); // remove '#' if exists
    if (hex.length == 6) hex = 'FF$hex'; // add alpha if missing
    return Color(int.parse(hex, radix: 16));
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

        // Colors
        colors.addAll(variants.keys.map((k) => k.toUpperCase()));

        // Sizes
        for (var sizeMap in variants.values) {
          final sizesMap = Map<String, dynamic>.from(sizeMap);
          sizes.addAll(sizesMap.keys.map((s) => s.toString()));
        }
      }
    }

    setState(() {
      allColors = SplayTreeSet<String>.from(colors); // automatically sorted
      allSizes = SplayTreeSet<String>.from(sizes);
    });
  }
}
