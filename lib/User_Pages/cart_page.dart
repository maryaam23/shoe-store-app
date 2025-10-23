import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shoe_store_app/User_Pages/product_page.dart';
import 'package:shoe_store_app/firestore_service.dart';
import 'checkout_page.dart';
import 'dart:io';

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

    final variantsRaw = productDoc['variants'] as Map<dynamic, dynamic>? ?? {};
    final variants = <String, Map<String, dynamic>>{};
    variantsRaw.forEach((key, value) {
      variants[key.toString()] = Map<String, dynamic>.from(value);
    });

    int availableStock = 0;
    for (var colorMap in variants.values) {
      if (colorMap is Map) {
        for (var qty in colorMap.values) {
          availableStock += (qty as num).toInt();
        }
      }
    }

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

  Future<bool> _decreaseProductStock(
    String productId,
    String colorHex,
    int size,
    int qtyToDecrease,
  ) async {
    final productRef = FirebaseFirestore.instance
        .collection('Nproducts')
        .doc(productId);
    final productSnap = await productRef.get();
    if (!productSnap.exists) return false;

    final variantsRaw = productSnap['variants'] as Map<dynamic, dynamic>? ?? {};
    final variants = <String, Map<String, dynamic>>{};
    variantsRaw.forEach((key, value) {
      variants[key.toString()] = Map<String, dynamic>.from(value);
    });

    final sizeStock =
        (variants[colorHex]?[size.toString()] as num?)?.toInt() ?? 0;

    if (sizeStock < qtyToDecrease) {
      return false; // Not enough stock
    }

    // Decrease stock
    variants[colorHex]?[size.toString()] = sizeStock - qtyToDecrease;

    // Save back to Firestore
    await productRef.update({'variants': variants});

    return true;
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

  Future<void> _updateColor(String cartId, String newColor) {
    // normalize color to lowercase and match Nproducts key format
    final normalizedColor = newColor.toLowerCase().substring(0, 7); // "#RRGGBB"
    return FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .collection("cart")
        .doc(cartId)
        .update({"color": normalizedColor});
  }

  Future<void> _updateSize(String cartId, int newSize) {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .collection("cart")
        .doc(cartId)
        .update({"size": newSize});
  }

  double _calculateSubtotal(List<QueryDocumentSnapshot> cartDocs) {
    return cartDocs.fold(
      0,
      (sum, doc) => sum + (doc["price"] * doc["quantity"]),
    );
  }

  Future<void> _selectColorAndSize(
    String cartId,
    Map<String, dynamic> variants,
    String currentColor,
    int currentSize,
  ) async {
    String selectedColor = currentColor;
    int selectedSize = currentSize;

    // Find first available color and size if current is out of stock
    // Check if current selection is valid
    final currentSizesMap = variants[selectedColor] as Map<String, dynamic>?;

    final currentQty =
        (currentSizesMap?[selectedSize.toString()] as num?)?.toInt() ?? 0;

    if (currentQty <= 0) {
      // Current selection out of stock → pick first available
      bool found = false;
      for (var color in variants.keys) {
        final sizesMap = variants[color] as Map<String, dynamic>;
        final availableSizes =
            sizesMap.entries.where((e) => (e.value as num) > 0).toList();
        if (availableSizes.isNotEmpty) {
          selectedColor = color;
          selectedSize = int.tryParse(availableSizes.first.key) ?? 0;
          found = true;
          break;
        }
      }

      if (!found) {
        // No stock at all → leave as is
      }
    }
    // Otherwise, keep cart item's original color & size

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final colorKeys = variants.keys.toList();
            final sizesForSelectedColor =
                variants[selectedColor]?.keys.toList() ?? [];

            return AlertDialog(
              title: const Text("Select Color and Size"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Color picker
                  Wrap(
                    spacing: 8,
                    children:
                        colorKeys.map<Widget>((colorHex) {
                          final sizesMap =
                              variants[colorHex] as Map<String, dynamic>;
                          final allZero = sizesMap.values.every(
                            (qty) => (qty as num) <= 0,
                          );

                          return GestureDetector(
                            onTap:
                                allZero
                                    ? null
                                    : () => setState(() {
                                      selectedColor = colorHex;

                                      // Automatically pick first available size
                                      final availableSizes =
                                          sizesMap.entries
                                              .where(
                                                (e) => (e.value as num) > 0,
                                              )
                                              .toList();
                                      selectedSize =
                                          availableSizes.isNotEmpty
                                              ? int.tryParse(
                                                    availableSizes.first.key,
                                                  ) ??
                                                  0
                                              : 0;
                                    }),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: _colorFromHex(colorHex),
                                  child:
                                      allZero
                                          ? Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(
                                                0.7,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                          )
                                          : null,
                                ),
                                if (allZero)
                                  const Icon(
                                    Icons.block,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                if (selectedColor == colorHex)
                                  const Icon(Icons.check, color: Colors.white),
                              ],
                            ),
                          );
                        }).toList(),
                  ),

                  const SizedBox(height: 12),

                  // Size picker
                  Wrap(
                    spacing: 8,
                    children:
                        sizesForSelectedColor.map<Widget>((size) {
                          final sizeInt = int.tryParse(size.toString()) ?? 0;
                          final qty =
                              (variants[selectedColor][size] as num?)
                                  ?.toInt() ??
                              0;

                          return ChoiceChip(
                            label: Text("$sizeInt"),
                            selected: selectedSize == sizeInt,
                            onSelected:
                                qty > 0
                                    ? (selected) {
                                      setState(() {
                                        selectedSize = sizeInt;
                                      });
                                    }
                                    : null,
                            disabledColor: Colors.grey.shade300,
                            selectedColor: Colors.blue,
                          );
                        }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    // Update Firestore first
                    await _updateColor(cartId, selectedColor);
                    await _updateSize(cartId, selectedSize);

                    // Then close dialog
                    Navigator.pop(context);
                  },
                  child: const Text("Confirm"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    double textScale = w / 390;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            tooltip: "Clear Cart",
            onPressed: () async {
              if (user == null) return;

              final cartRef = FirebaseFirestore.instance
                  .collection("users")
                  .doc(user!.uid)
                  .collection("cart");

              final cartSnapshot = await cartRef.get();

              if (cartSnapshot.docs.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Cart is already empty."),
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
              }

              // Confirm before deleting all
              final confirm = await showDialog<bool>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text("Clear Cart"),
                      content: const Text(
                        "Are you sure you want to delete all items from your cart?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Yes, clear"),
                        ),
                      ],
                    ),
              );

              if (confirm == true) {
                // Delete all cart documents
                for (var doc in cartSnapshot.docs) {
                  await doc.reference.delete();
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Cart cleared successfully."),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ],
      ),
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

                                final productDoc = productSnapshot.data!;
                                if (!productDoc.exists) {
                                  return ListTile(
                                    title: Text(
                                      "Product not found",
                                      style: TextStyle(color: Colors.redAccent),
                                    ),
                                    subtitle: Text(
                                      "It may have been deleted from the store.",
                                    ),
                                  );
                                }

                                final variants =
                                    productDoc['variants']
                                        as Map<String, dynamic>? ??
                                    {};

                                final colors =
                                    variants.keys
                                        .toList(); // color hex list like ["#ff00ff", "#ffffff"]

                                // Flatten all available sizes (from all colors)
                                final Set<dynamic> sizesSet = {};
                                for (var colorMap in variants.values) {
                                  if (colorMap is Map) {
                                    sizesSet.addAll(colorMap.keys);
                                  }
                                }
                                final sizes = sizesSet.toList()..sort();

                                // For total stock (sum of all sizes in all colors)
                                int availableStock = 0;
                                for (var colorMap in variants.values) {
                                  if (colorMap is Map) {
                                    for (var qty in colorMap.values) {
                                      availableStock += (qty as num).toInt();
                                    }
                                  }
                                }

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
                                                      ? (() {
                                                        final imagePath =
                                                            cartItem["image"]
                                                                .toString();

                                                        if (imagePath
                                                            .startsWith(
                                                              "http",
                                                            )) {
                                                          return Image.network(
                                                            imagePath,
                                                            width: w * 0.22,
                                                            height: w * 0.22,
                                                            fit: BoxFit.cover,
                                                            color:
                                                                isOutOfStock
                                                                    ? Colors
                                                                        .black12
                                                                    : null,
                                                            colorBlendMode:
                                                                isOutOfStock
                                                                    ? BlendMode
                                                                        .darken
                                                                    : null,
                                                          );
                                                        } else {
                                                          return Image.file(
                                                            File(imagePath),
                                                            width: w * 0.22,
                                                            height: w * 0.22,
                                                            fit: BoxFit.cover,
                                                            color:
                                                                isOutOfStock
                                                                    ? Colors
                                                                        .black12
                                                                    : null,
                                                            colorBlendMode:
                                                                isOutOfStock
                                                                    ? BlendMode
                                                                        .darken
                                                                    : null,
                                                          );
                                                        }
                                                      })()
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
                                                      () => _selectColorAndSize(
                                                        cartId,
                                                        variants,
                                                        cartItem["color"] ??
                                                            "#FFFFFF",
                                                        cartItem["size"] ?? 0,
                                                      ),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        "Color & Size",
                                                        style: GoogleFonts.inter(
                                                          fontSize:
                                                              13 * textScale,
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Container(
                                                        width: 16,
                                                        height: 16,
                                                        decoration: BoxDecoration(
                                                          color: _colorFromHex(
                                                            cartItem["color"] ??
                                                                "#FFFFFF",
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
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        "${cartItem["size"]}",
                                                        style:
                                                            GoogleFonts.inter(
                                                              fontSize:
                                                                  13 *
                                                                  textScale,
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

                                  // -------------------- CHECK STOCK --------------------
                                  bool hasProblem = false;
                                  List<String> problemMessages = [];

                                  for (var cartItem in cartDocs) {
                                    final productId = cartItem['id'];
                                    final color =
                                        (cartItem['color'] ?? '')
                                            .toString()
                                            .toLowerCase();
                                    final size = cartItem['size'] ?? 0;
                                    final qty = cartItem['quantity'] ?? 0;

                                    final productSnap =
                                        await FirebaseFirestore.instance
                                            .collection('Nproducts')
                                            .doc(cartItem['id'])
                                            .get();

                                    if (!productSnap.exists) continue;

                                    final variants = Map<String, dynamic>.from(
                                      productSnap['variants'] ?? {},
                                    );

                                    // Normalize variant keys
                                    final normalizedVariants =
                                        <String, Map<String, dynamic>>{};
                                    variants.forEach((key, value) {
                                      normalizedVariants[key.toLowerCase()] =
                                          Map<String, dynamic>.from(value);
                                    });

                                    final sizeStock =
                                        (normalizedVariants[color]?[size
                                                    .toString()]
                                                as num?)
                                            ?.toInt() ??
                                        0;

                                    if (sizeStock < qty) {
                                      hasProblem = true;
                                      if (sizeStock == 0) {
                                        problemMessages.add(
                                          "${cartItem['name']} is out of stock for color $color, size $size.",
                                        );
                                      } else {
                                        problemMessages.add(
                                          "${cartItem['name']} has only $sizeStock items available for color $color, size $size.",
                                        );
                                      }
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
                                    return;
                                  }

                                  // -------------------- DEDUCT STOCK & CLEAR CART --------------------
                                  for (var cartItem in cartDocs) {
                                    final productId = cartItem['id'];
                                    final color = cartItem['color'] ?? '';
                                    final size = cartItem['size'] ?? 0;
                                    final qty = cartItem['quantity'] ?? 0;

                                    // Update stock in Nproducts
                                    final productRef = FirebaseFirestore
                                        .instance
                                        .collection('Nproducts')
                                        .doc(productId);

                                    await FirebaseFirestore.instance
                                        .runTransaction((transaction) async {
                                          final snapshot = await transaction
                                              .get(productRef);
                                          if (!snapshot.exists) return;

                                          final variants =
                                              Map<String, dynamic>.from(
                                                snapshot['variants'] ?? {},
                                              );
                                          final colorMap =
                                              Map<String, dynamic>.from(
                                                variants[color] ?? {},
                                              );

                                          final currentStock =
                                              (colorMap[size.toString()]
                                                      as num?)
                                                  ?.toInt() ??
                                              0;
                                          colorMap[size.toString()] =
                                              currentStock - qty;

                                          variants[color] = colorMap;
                                          transaction.update(productRef, {
                                            'variants': variants,
                                          });
                                        });

                                    // Remove item from cart
                                  }

                                  // Navigate to checkout
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const CheckoutPage(),
                                    ),
                                  );
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

  Color _colorFromHex(String hexColor) {
    final buffer = StringBuffer();
    if (hexColor.length == 6 || hexColor.length == 7) buffer.write('ff');
    buffer.write(hexColor.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
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
