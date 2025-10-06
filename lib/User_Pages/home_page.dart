import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_detailes_page.dart';
import 'profile_page.dart';
import 'categories_page.dart';
import 'brands_page.dart';
import 'wishlist_page.dart';
import 'cart_page.dart';
import 'user_notification_page.dart';
import 'product_page.dart'; // Product model
import '../firestore_service.dart'; // FirestoreService class
import 'package:firebase_auth/firebase_auth.dart';

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

  late Stream<QuerySnapshot> cartStream;
  late Stream<QuerySnapshot> wishlistStream;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController searchController = TextEditingController();

  // Map of color names for search
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

    // Listen to search changes
    searchController.addListener(() {
      setState(() {}); // rebuild to apply filter
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
              height: h * 0.08, // 👈 control height
              child: TextField(
                controller: searchController,
                style: TextStyle(
                  // 👈 text font size
                  fontSize: 16, // change as you like
                ),
                decoration: InputDecoration(
                  hintText: "Search by name, brand, category, size, color ...",
                  hintStyle: const TextStyle(
                    fontSize: 11,
                  ), // 👈 hint text font size
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 7,
                  ), // 👈 padding inside box
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), // 👈 rounded edges
                    borderSide: const BorderSide(color: Colors.pink),
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.pink),
                ),
              ),
            ),
          ),

          // 🟧 BrandsPage (horizontal circle)
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

              // Remove leading/trailing spaces and collapse multiple spaces, then lowercase
              final searchText =
                  searchController.text
                      .trim()
                      .replaceAll(RegExp(r'\s+'), ' ')
                      .toLowerCase();

              // 🔎 Filter products
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
                            p.sizes != null &&
                            p.sizes!.any(
                              (s) => s.toString().contains(searchText),
                            );
                        final matchesColors =
                            p.colors != null &&
                            p.colors!.any((c) {
                              final hex =
                                  '#${c.value.toRadixString(16).substring(2).toLowerCase()}';
                              final nameMatch = colorNames.entries.any(
                                (entry) =>
                                    entry.key.contains(searchText) &&
                                    entry.value.value == c.value,
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
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final product = filtered[index];
                          final isInCart = cartIds.contains(product.id);
                          final isInWishlist = wishlistIds.contains(product.id);

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) =>
                                          ProductDetailPage(product: product),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(w * 0.01),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      w * 0.01,
                                    ),
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
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: w * 0.02,
                                    ),
                                    child: Text(
                                      "₪${product.price.toStringAsFixed(2)}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: w * 0.04,
                                        color: Colors.deepOrange,
                                      ),
                                    ),
                                  ),
                                  // 🛒 Cart + ❤️ Wishlist buttons
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: w * 0.02,
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      children: [
                                        // 🛒 Cart button (left)
                                        IconButton(
                                          iconSize: w * 0.06,
                                          icon: Icon(
                                            Icons.shopping_bag,
                                            color:
                                                isInCart
                                                    ? Colors.deepOrange
                                                    : Colors.black,
                                          ),
                                          onPressed: () async {
                                            // 🚫 Prevent guest from adding to cart
                                            if (widget.isGuest) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    "Please login first",
                                                  ),
                                                  backgroundColor: Colors.red,
                                                  duration: Duration(
                                                    seconds: 2,
                                                  ),
                                                ),
                                              );
                                              return;
                                            }

                                            if (isInCart) {
                                              await FirestoreService.removeFromCart(
                                                product.id,
                                              );
                                            } else {
                                              int defaultSize =
                                                  (product.sizes != null &&
                                                          product
                                                              .sizes!
                                                              .isNotEmpty)
                                                      ? product.sizes!.first
                                                      : 0;
                                              Color defaultColor =
                                                  (product.colors != null &&
                                                          product
                                                              .colors!
                                                              .isNotEmpty)
                                                      ? product.colors!.first
                                                      : Colors.black;

                                              await FirestoreService.addToCart(
                                                product,
                                                size: defaultSize,
                                                color: defaultColor,
                                              );
                                            }
                                          },
                                        ),

                                        const Spacer(),

                                        // ❤️ Wishlist button (right)
                                        IconButton(
                                          iconSize: w * 0.065,
                                          icon: Icon(
                                            isInWishlist
                                                ? Icons.favorite
                                                : Icons
                                                    .favorite_border, // 👈 Border when false
                                            color:
                                                isInWishlist
                                                    ? const Color.fromARGB(
                                                      255,
                                                      255,
                                                      17,
                                                      0,
                                                    )
                                                    : Colors
                                                        .black, // 👈 Red when pressed
                                          ),
                                          onPressed: () async {
                                            // 🚫 Prevent guest from adding to wishlist
                                            if (widget.isGuest) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    "Please login first",
                                                  ),
                                                  backgroundColor: Colors.red,
                                                  duration: Duration(
                                                    seconds: 2,
                                                  ),
                                                ),
                                              );
                                              return;
                                            }

                                            if (isInWishlist) {
                                              await FirestoreService.removeFromWishlist(
                                                product.id,
                                              );
                                            } else {
                                              await FirestoreService.addToWishlist(
                                                product,
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
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
}
