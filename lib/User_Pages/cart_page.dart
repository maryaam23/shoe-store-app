import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shoe_store_app/User_Pages/product_page.dart';
import 'package:shoe_store_app/firestore_service.dart';
import 'checkout_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final user = FirebaseAuth.instance.currentUser;

  void _increaseQty(String cartId, int currentQty, String productId) async {
    final userId = user!.uid;

    print("---- INCREASE QTY DEBUG ----");
    print("CartId: $cartId, ProductId: $productId, CurrentQty: $currentQty");

    // Step 1: Get total quantity of this product in user's cart
    final cartSnapshot =
        await FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .collection("cart")
            .where("id", isEqualTo: productId)
            .get();

    int totalProductQtyInCart = 0;
    for (var doc in cartSnapshot.docs) {
      int qty = ((doc["quantity"] ?? 0) as num).toInt();
      totalProductQtyInCart += qty;
      print(
        "Cart DocId: ${doc.id}, Qty in Cart: $qty, Running Total: $totalProductQtyInCart",
      );
    }

    print("Total quantity in cart for this product: $totalProductQtyInCart");

    // Step 2: Get product stock from Nproducts
    final productDoc =
        await FirebaseFirestore.instance
            .collection("Nproducts")
            .doc(productId)
            .get();

    if (!productDoc.exists) {
      print("Product $productId does not exist in Nproducts!");
      return;
    }

    final availableStock = ((productDoc["quantity"] ?? 0) as num).toInt();
    print("Available stock for product: $availableStock");

    // Step 3: Check if adding exceeds stock
    if (totalProductQtyInCart < availableStock) {
      print("Can increase quantity. Updating cart...");
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("cart")
          .doc(cartId)
          .update({"quantity": currentQty + 1});
      print("Quantity updated successfully.");
    } else {
      print(
        "Cannot increase quantity. Total in cart ($totalProductQtyInCart) >= Stock ($availableStock)",
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Not enough stock available for this product."),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        ),
      );
    }

    print("------------------------------");
  }

  void _decreaseQty(String cartId, int currentQty) {
    if (currentQty > 1) {
      FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .collection("cart")
          .doc(cartId)
          .update({"quantity": currentQty - 1});
    }
  }

  void _updateSize(String cartId, int newSize) {
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .collection("cart")
        .doc(cartId)
        .update({"size": newSize});
  }

  void _updateColor(String cartId, int newColor) {
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .collection("cart")
        .doc(cartId)
        .update({"color": newColor});
  }

  double _calculateSubtotal(List<QueryDocumentSnapshot> cartDocs) {
    return cartDocs.fold(
      0,
      (sum, doc) => sum + (doc["price"] * doc["quantity"]),
    );
  }

  Future<void> _selectSize(String cartId, List<dynamic> sizes) async {
    int? selectedSize = await showDialog<int>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Select Size"),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: sizes.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(sizes[index].toString()),
                    onTap: () {
                      Navigator.pop(context, sizes[index]);
                    },
                  );
                },
              ),
            ),
          ),
    );

    if (selectedSize != null) {
      _updateSize(cartId, selectedSize);
    }
  }

  Future<void> _selectColor(String cartId, List<dynamic> colors) async {
    int? selectedColor = await showDialog<int>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Select Color"),
            content: Wrap(
              spacing: 10,
              runSpacing: 10,
              children:
                  colors.map<Widget>((colorValue) {
                    return GestureDetector(
                      onTap:
                          () => Navigator.pop(
                            context,
                            int.parse(
                              colorValue.toString().replaceFirst("#", "0xFF"),
                            ),
                          ),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Color(
                            int.parse(
                              colorValue.toString().replaceFirst("#", "0xFF"),
                            ),
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
    );

    if (selectedColor != null) {
      _updateColor(cartId, selectedColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    double textScale = w / 390;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body:
          user ==
                  null // to check if its guest
              ? const Center(
                child: Text(
                  "Please log in to view your cart.",
                  style: TextStyle(fontSize: 18),
                ),
              )
              : StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection("users")
                        .doc(user!.uid) // the error is here it stop the program
                        .collection("cart")
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final cartDocs = snapshot.data!.docs;

                  if (cartDocs.isEmpty) {
                    return Center(
                      child: Text(
                        "Your cart is empty",
                        style: GoogleFonts.inter(
                          fontSize: 16 * textScale,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }

                  final subtotal = _calculateSubtotal(cartDocs);
                  final total = subtotal;

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: cartDocs.length,
                          itemBuilder: (context, index) {
                            final cartItem = cartDocs[index];
                            final cartId = cartItem.id;
                            final productId = cartItem['id'];

                            // Fetch product document to get all sizes/colors
                            return StreamBuilder<DocumentSnapshot>(
                              stream:
                                  FirebaseFirestore.instance
                                      .collection('Nproducts')
                                      .doc(productId)
                                      .snapshots(),
                              builder: (context, productSnapshot) {
                                if (!productSnapshot.hasData) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                final productData = productSnapshot.data!;
                                final sizes = List<dynamic>.from(
                                  productData['sizes'] ?? [],
                                );
                                final colors = List<dynamic>.from(
                                  productData['colors'] ?? [],
                                );

                                final availableStock =
                                    productData['quantity'] ?? 0;
                                final cartQty = cartItem['quantity'];
                                final isOutOfStock = availableStock == 0;
                                final atMaxStock = cartQty >= availableStock;

                                return Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: w * 0.01,
                                    vertical: h * 0.015,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isOutOfStock
                                            ? Colors.grey.shade200
                                            : Colors.white,
                                    border: const Border(
                                      bottom: BorderSide(
                                        color: Color(0xFFE7EDF4),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          // Product image
                                          Card(
                                            elevation: 2,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    w * 0.02,
                                                  ),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    w * 0.02,
                                                  ),
                                              child:
                                                  (cartItem
                                                              .data()
                                                              .toString()
                                                              .contains(
                                                                "image",
                                                              ) &&
                                                          cartItem["image"] !=
                                                              null)
                                                      ? Image.network(
                                                        cartItem["image"],
                                                        width: w * 0.22,
                                                        height: w * 0.22,
                                                        fit: BoxFit.cover,
                                                        color:
                                                            isOutOfStock
                                                                ? Colors.black12
                                                                : null,
                                                        colorBlendMode:
                                                            isOutOfStock
                                                                ? BlendMode
                                                                    .darken
                                                                : null,
                                                      )
                                                      : Icon(
                                                        Icons.image,
                                                        size: w * 0.18,
                                                      ),
                                            ),
                                          ),
                                          SizedBox(width: w * 0.01),

                                          // Product info
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  cartItem["name"],
                                                  style: GoogleFonts.inter(
                                                    fontSize: 16 * textScale,
                                                    fontWeight: FontWeight.w600,
                                                    color: const Color(
                                                      0xFF0D141C,
                                                    ),
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                SizedBox(height: h * 0.004),
                                                Text(
                                                  "₪${cartItem["price"]}",
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14 * textScale,
                                                    color: const Color(
                                                      0xFF49709C,
                                                    ),
                                                  ),
                                                ),

                                                // Size
                                                GestureDetector(
                                                  onTap:
                                                      () => _selectSize(
                                                        cartId,
                                                        sizes,
                                                      ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 4,
                                                        ),
                                                    child: Text(
                                                      "Size: ${cartItem["size"]}",
                                                      style: GoogleFonts.inter(
                                                        fontSize:
                                                            13 * textScale,
                                                        color: Colors.black87,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                // Color
                                                GestureDetector(
                                                  onTap:
                                                      () => _selectColor(
                                                        cartId,
                                                        colors,
                                                      ),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        "Color: ",
                                                        style:
                                                            GoogleFonts.inter(
                                                              fontSize:
                                                                  13 *
                                                                  textScale,
                                                              color:
                                                                  Colors
                                                                      .black87,
                                                            ),
                                                      ),
                                                      Container(
                                                        width: 16,
                                                        height: 16,
                                                        decoration: BoxDecoration(
                                                          color: Color(
                                                            cartItem["color"],
                                                          ),
                                                          shape:
                                                              BoxShape.circle,
                                                          border: Border.all(
                                                            color:
                                                                Colors
                                                                    .grey
                                                                    .shade400,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                // Quantity controls
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        IconButton(
                                                          icon: const Icon(
                                                            Icons.remove,
                                                          ),
                                                          onPressed:
                                                              isOutOfStock
                                                                  ? null
                                                                  : () =>
                                                                      _decreaseQty(
                                                                        cartId,
                                                                        cartQty,
                                                                      ),
                                                        ),
                                                        Text(
                                                          "$cartQty",
                                                          style:
                                                              GoogleFonts.inter(
                                                                fontSize:
                                                                    15 *
                                                                    textScale,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                        ),
                                                        IconButton(
                                                          icon: const Icon(
                                                            Icons.add,
                                                          ),
                                                          color:
                                                              atMaxStock
                                                                  ? Colors.grey
                                                                  : Colors
                                                                      .black,
                                                          onPressed:
                                                              (!isOutOfStock)
                                                                  ? () =>
                                                                      _increaseQty(
                                                                        cartId,
                                                                        cartQty,
                                                                        productId,
                                                                      )
                                                                  : null,
                                                        ),
                                                      ],
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                      ),
                                                      onPressed:
                                                          () => _removeFromCart(
                                                            cartId,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      // 🧩 If out of stock → show small gray message + actions
                                      if (isOutOfStock) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          "This product is out of stock.",
                                          style: GoogleFonts.inter(
                                            fontSize: 13 * textScale,
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              onPressed: () async {
                                                final productId =
                                                    cartItem["id"];

                                                // Check if already in wishlist
                                                final alreadyInWishlist =
                                                    await FirestoreService.isInWishlist(
                                                      productId,
                                                    );

                                                if (alreadyInWishlist) {
                                                  // 🔴 Already there
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        "Already in wishlist",
                                                      ),
                                                      duration: Duration(
                                                        seconds: 1,
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  // 🟢 Add to wishlist
                                                  final product = Product(
                                                    id: cartItem["id"],
                                                    name: cartItem["name"],
                                                    price:
                                                        cartItem["price"]
                                                            .toDouble(),
                                                    image: cartItem["image"],
                                                    category:
                                                        '', // Optional: fill if available
                                                    brand:
                                                        '', // Optional: fill if available
                                                  );

                                                  await FirestoreService.addToWishlist(
                                                    product,
                                                  );

                                                  // Optional: Remove from cart after moving
                                                  await FirestoreService.removeFromCart(
                                                    productId,
                                                  );

                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        "Moved to wishlist",
                                                      ),
                                                      duration: Duration(
                                                        seconds: 1,
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                              child: const Text(
                                                "Move to Wishlist",
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),

                      // Summary Section
                      Padding(
                        padding: EdgeInsets.all(w * 0.04),
                        child: Column(
                          children: [
                            Divider(thickness: 1, color: Colors.grey[300]),
                            _buildSummaryRow(
                              "Total",
                              "₪${total.toStringAsFixed(2)}",
                              w,
                              textScale: textScale,
                              isBold: true,
                            ),
                            SizedBox(height: h * 0.02),
                            SizedBox(
                              width: double.infinity,
                              height: h * 0.065,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0D78F2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      w * 0.03,
                                    ),
                                  ),
                                ),
                                onPressed: () async {
                                  final snapshot =
                                      await FirebaseFirestore.instance
                                          .collection("users")
                                          .doc(user!.uid)
                                          .collection("cart")
                                          .get();

                                  final cartDocs = snapshot.docs;

                                  bool hasProblem = false;
                                  List<String> problemMessages = [];
                                  Set<String> processedProductIds =
                                      {}; // Track already checked products

                                  for (var doc in cartDocs) {
                                    final productId = doc["id"];

                                    if (processedProductIds.contains(productId))
                                      continue; // Skip duplicates
                                    processedProductIds.add(productId);

                                    final productSnap =
                                        await FirebaseFirestore.instance
                                            .collection("Nproducts")
                                            .doc(productId)
                                            .get();

                                    if (!productSnap.exists) continue;

                                    String productName =
                                        productSnap["name"] ?? "Product";
                                    int stock =
                                        ((productSnap["quantity"] ?? 0) as num)
                                            .toInt();

                                    // Total quantity of this product in cart
                                    final cartSnapshot =
                                        await FirebaseFirestore.instance
                                            .collection("users")
                                            .doc(user!.uid)
                                            .collection("cart")
                                            .where("id", isEqualTo: productId)
                                            .get();

                                    int totalQtyInCart = 0;
                                    for (var cartDoc in cartSnapshot.docs) {
                                      totalQtyInCart +=
                                          ((cartDoc["quantity"] ?? 0) as num)
                                              .toInt();
                                    }

                                    if (stock == 0) {
                                      hasProblem = true;
                                      problemMessages.add(
                                        "$productName is out of stock. Please remove it or move it to your wishlist.",
                                      );
                                    } else if (totalQtyInCart > stock) {
                                      hasProblem = true;
                                      int exceedQty = totalQtyInCart - stock;
                                      problemMessages.add(
                                        "$productName quantity exceeds stock by $exceedQty. Available: $stock, In Cart: $totalQtyInCart.",
                                      );
                                    }
                                  }

                                  if (hasProblem) {
                                    final maxHeight =
                                        MediaQuery.of(context).size.height *
                                        0.5;

                                    showDialog(
                                      context: context,
                                      builder:
                                          (_) => AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            title: const Text(
                                              "Can't Proceed to Checkout 🛑",
                                            ),
                                            content: ConstrainedBox(
                                              constraints: BoxConstraints(
                                                maxHeight: maxHeight,
                                              ),
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children:
                                                      problemMessages
                                                          .map(
                                                            (msg) => Padding(
                                                              padding:
                                                                  const EdgeInsets.only(
                                                                    bottom: 8.0,
                                                                  ),
                                                              child: Text(msg),
                                                            ),
                                                          )
                                                          .toList(),
                                                ),
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () =>
                                                        Navigator.pop(context),
                                                child: const Text("OK"),
                                              ),
                                            ],
                                          ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const CheckoutPage(),
                                      ),
                                    );
                                  }
                                },

                                child: Text(
                                  "Checkout",
                                  style: GoogleFonts.inter(
                                    fontSize: 16 * textScale,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
    );
  }

  void _removeFromCart(String cartId) {
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .collection("cart")
        .doc(cartId)
        .delete();
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    double w, {
    bool isBold = false,
    double textScale = 1,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: w * 0.01),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 15 * textScale,
              color: const Color(0xFF49709C),
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 15 * textScale,
              color: const Color(0xFF0D141C),
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
