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
  final List<String> pageTitles = [
    "Sport Brands",
    "Cart Page",
    "Wishlist Page",
    "My Profile",
  ];

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;
  final TextEditingController searchController = TextEditingController();

  late Stream<QuerySnapshot> cartStream;
  late Stream<QuerySnapshot> wishlistStream;

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
  }

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
                                  right: w * 0.02,
                                  top: h * 0.015,
                                  child: Container(
                                    padding: EdgeInsets.all(w * 0.015),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      unreadCount.toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: w * 0.035,
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
            padding: EdgeInsets.all(w * 0.03),
            child: SizedBox(
              height: h * 0.08,
              child: TextField(
                controller: searchController,
                style: TextStyle(fontSize: w * 0.04),
                decoration: InputDecoration(
                  hintText: "Search by name, brand, category, size, color ...",
                  hintStyle: TextStyle(fontSize: w * 0.035),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: h * 0.015,
                    horizontal: w * 0.03,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(w * 0.03),
                    borderSide: const BorderSide(color: Colors.pink),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.pink,
                    size: w * 0.06,
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
          const BrandsBar(),

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
                  searchText.isEmpty
                      ? products
                      : products.where((p) {
                        final matchesName = p.name.toLowerCase().contains(
                          searchText,
                        );
                        final matchesCategory = p.category
                            .toLowerCase()
                            .contains(searchText);
                        final matchesBrand =
                            p.brand != null &&
                            p.brand!.toLowerCase().contains(searchText);

                        final matchesSizes =
                            p.variants != null &&
                            p.variants!.values.any(
                              (sizeMap) => sizeMap.keys.any(
                                (s) => s.toString().contains(searchText),
                              ),
                            );

                        final matchesColors =
                            p.variants != null &&
                            p.variants!.keys.any((c) {
                              final hex =
                                  c.toLowerCase(); // already a hex string like "#f436ee"
                              final nameMatch = colorNames.entries.any(
                                (entry) =>
                                    entry.key.contains(searchText) &&
                                    entry.value ==
                                        _colorFromHex(
                                          c,
                                        ), // convert string to Color
                              );
                              return hex.contains(searchText) || nameMatch;
                            });

                        return matchesName ||
                            matchesCategory ||
                            matchesBrand ||
                            matchesSizes ||
                            matchesColors;
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
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
