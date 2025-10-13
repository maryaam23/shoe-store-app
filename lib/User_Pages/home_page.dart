import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoe_store_app/User_Pages/brands_page.dart';
import 'package:shoe_store_app/User_Pages/login_page.dart';
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
                          // Combine both collections into a single list
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
                                final user = FirebaseAuth.instance.currentUser;
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
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Please log in first"),
                                    ),
                                  );
                                }
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

          // 🧩 Guest notice box (show only if guest)
          if (widget.isGuest)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: 8),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(w * 0.04),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 244, 230),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orangeAccent, width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange),
                    SizedBox(width: w * 0.03),
                    Expanded(
                      child: Text(
                        "You are browsing now without logging in. To buy, please log in.",
                        style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                      ),
                    ),
                    SizedBox(width: w * 0.02),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: w * 0.04,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
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
                      child: const Text(
                        "Login",
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
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

                        //itemCount: products.length,
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          //final product = products[index];

                          final product = filtered[index];
                          final bool isOutOfStock = product.quantity == 0;

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
                                    child: Stack(
                                      children: [
                                        product.image.startsWith('http')
                                            ? Image.network(
                                              product.image,
                                              height: h * 0.2,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              color:
                                                  isOutOfStock
                                                      ? Colors.black
                                                          .withOpacity(0.4)
                                                      : null,
                                              colorBlendMode:
                                                  isOutOfStock
                                                      ? BlendMode.darken
                                                      : BlendMode.srcIn,
                                            )
                                            : Image.asset(
                                              product.image,
                                              height: h * 0.2,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              color:
                                                  isOutOfStock
                                                      ? Colors.black
                                                          .withOpacity(0.4)
                                                      : null,
                                              colorBlendMode:
                                                  isOutOfStock
                                                      ? BlendMode.darken
                                                      : BlendMode.srcIn,
                                            ),
                                        if (isOutOfStock)
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 3,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.redAccent
                                                    .withOpacity(0.9),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: const Text(
                                                "Out of Stock",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
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
                                        // Cart button

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

                                          //Mariam edit
                                          onPressed: () async {
                                            // 🚫 Prevent adding if out of stock
                                            if (isOutOfStock) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    "This product is currently out of stock.",
                                                  ),
                                                  backgroundColor: Colors.red,
                                                  duration: Duration(
                                                    seconds: 2,
                                                  ),
                                                ),
                                              );
                                              return;
                                            }
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

                                            final outerContext = context;

                                            showModalBottomSheet(
                                              context: outerContext,
                                              isScrollControlled: true,
                                              shape:
                                                  const RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.vertical(
                                                          top: Radius.circular(
                                                            20,
                                                          ),
                                                        ),
                                                  ),
                                              builder: (modalContext) {
                                                int? selectedSize;
                                                Color? selectedColor;

                                                double w =
                                                    MediaQuery.of(
                                                      modalContext,
                                                    ).size.width;
                                                double h =
                                                    MediaQuery.of(
                                                      modalContext,
                                                    ).size.height;

                                                return StatefulBuilder(
                                                  builder: (
                                                    context,
                                                    setModalState,
                                                  ) {
                                                    return Padding(
                                                      padding: EdgeInsets.only(
                                                        left: w * 0.05,
                                                        right: w * 0.05,
                                                        top: h * 0.02,
                                                        bottom:
                                                            MediaQuery.of(
                                                                  modalContext,
                                                                )
                                                                .viewInsets
                                                                .bottom +
                                                            h * 0.03,
                                                      ),
                                                      child: SingleChildScrollView(
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Center(
                                                              child: Text(
                                                                "Choose Size & Color",
                                                                style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      w * 0.05,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: h * 0.02,
                                                            ),

                                                            // Size choices
                                                            Text(
                                                              "Size:",
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize:
                                                                    w * 0.04,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: h * 0.01,
                                                            ),
                                                            Wrap(
                                                              spacing: w * 0.02,
                                                              runSpacing:
                                                                  h * 0.01,
                                                              children:
                                                                  (product.sizes ?? []).map((
                                                                    size,
                                                                  ) {
                                                                    return ChoiceChip(
                                                                      label: Text(
                                                                        size.toString(),
                                                                        style: TextStyle(
                                                                          fontSize:
                                                                              w *
                                                                              0.035,
                                                                        ),
                                                                      ),
                                                                      selected:
                                                                          selectedSize ==
                                                                          size,
                                                                      onSelected:
                                                                          (
                                                                            _,
                                                                          ) => setModalState(() {
                                                                            selectedSize =
                                                                                size;
                                                                          }),
                                                                      selectedColor: Colors
                                                                          .deepOrange
                                                                          .withOpacity(
                                                                            0.8,
                                                                          ),
                                                                    );
                                                                  }).toList(),
                                                            ),
                                                            SizedBox(
                                                              height: h * 0.025,
                                                            ),

                                                            // Color choices
                                                            Text(
                                                              "Color:",
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize:
                                                                    w * 0.04,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: h * 0.01,
                                                            ),
                                                            Wrap(
                                                              spacing: w * 0.03,
                                                              runSpacing:
                                                                  h * 0.01,
                                                              children:
                                                                  (product.colors ??
                                                                          [])
                                                                      .map((
                                                                        color,
                                                                      ) {
                                                                        return GestureDetector(
                                                                          onTap:
                                                                              () => setModalState(
                                                                                () =>
                                                                                    selectedColor =
                                                                                        color,
                                                                              ),
                                                                          child: Container(
                                                                            decoration: BoxDecoration(
                                                                              shape:
                                                                                  BoxShape.circle,
                                                                              border: Border.all(
                                                                                color:
                                                                                    selectedColor ==
                                                                                            color
                                                                                        ? Colors.deepOrange
                                                                                        : Colors.grey,
                                                                                width:
                                                                                    w *
                                                                                    0.007,
                                                                              ),
                                                                            ),
                                                                            child: CircleAvatar(
                                                                              backgroundColor:
                                                                                  color,
                                                                              radius:
                                                                                  w *
                                                                                  0.045,
                                                                            ),
                                                                          ),
                                                                        );
                                                                      })
                                                                      .toList(),
                                                            ),
                                                            SizedBox(
                                                              height: h * 0.04,
                                                            ),

                                                            // Add to cart button
                                                            SizedBox(
                                                              width:
                                                                  double
                                                                      .infinity,
                                                              height: h * 0.06,
                                                              child: ElevatedButton.icon(
                                                                style: ElevatedButton.styleFrom(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .deepOrange,
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          w *
                                                                              0.03,
                                                                        ),
                                                                  ),
                                                                ),
                                                                icon: Icon(
                                                                  Icons
                                                                      .shopping_cart_outlined,
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                  size:
                                                                      w * 0.06,
                                                                ),
                                                                label: Text(
                                                                  "Add to Cart",
                                                                  style: TextStyle(
                                                                    color:
                                                                        Colors
                                                                            .white,
                                                                    fontSize:
                                                                        w *
                                                                        0.04,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                                onPressed: () async {
                                                                  if (selectedSize ==
                                                                          null ||
                                                                      selectedColor ==
                                                                          null) {
                                                                    Flushbar(
                                                                      message:
                                                                          "Please choose size and color before adding.",
                                                                      backgroundColor:
                                                                          const Color.fromARGB(
                                                                            255,
                                                                            251,
                                                                            54,
                                                                            54,
                                                                          ),
                                                                      duration: const Duration(
                                                                        seconds:
                                                                            2,
                                                                      ),
                                                                      margin:
                                                                          const EdgeInsets.all(
                                                                            8,
                                                                          ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            12,
                                                                          ),
                                                                      flushbarPosition:
                                                                          FlushbarPosition
                                                                              .TOP,
                                                                    ).show(
                                                                      outerContext,
                                                                    );
                                                                    return;
                                                                  }

                                                                  await FirestoreService.addOrUpdateCart(
                                                                    product,
                                                                    size:
                                                                        selectedSize!,
                                                                    color:
                                                                        selectedColor!,
                                                                  );

                                                                  Navigator.pop(
                                                                    modalContext,
                                                                  );

                                                                  Flushbar(
                                                                    message:
                                                                        "Product added to cart!",
                                                                    backgroundColor:
                                                                        Colors
                                                                            .green,
                                                                    duration:
                                                                        const Duration(
                                                                          seconds:
                                                                              2,
                                                                        ),
                                                                    margin:
                                                                        const EdgeInsets.all(
                                                                          8,
                                                                        ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          12,
                                                                        ),
                                                                    flushbarPosition:
                                                                        FlushbarPosition
                                                                            .TOP,
                                                                    icon: const Icon(
                                                                      Icons
                                                                          .check,
                                                                      color:
                                                                          Colors
                                                                              .white,
                                                                    ),
                                                                  ).show(
                                                                    outerContext,
                                                                  );
                                                                },
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
                                        ),

                                        SizedBox(width: w * 0.04),

                                        const Spacer(), // 👈 pushes the next widget (wishlist) to the right

                                        // Wishlist button
                                        // Wishlist button
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

                                            // ❤️ Toggle wishlist state
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
