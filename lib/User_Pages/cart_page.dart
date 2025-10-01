import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'checkout_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final user = FirebaseAuth.instance.currentUser;

  void _increaseQty(String cartId, int currentQty) {
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .collection("cart")
        .doc(cartId)
        .update({"quantity": currentQty + 1});
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
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection("users")
                .doc(user!.uid)
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
                    return FutureBuilder<DocumentSnapshot>(
                      future:
                          FirebaseFirestore.instance
                              .collection('Nproducts')
                              .doc(productId)
                              .get(),
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

                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: w * 0.01,
                            vertical: h * 0.015,
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              bottom: BorderSide(
                                color: Color(0xFFE7EDF4),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Product image
                              Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(w * 0.02),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(w * 0.02),
                                  child:
                                      (cartItem.data().toString().contains(
                                                "image",
                                              ) &&
                                              cartItem["image"] != null)
                                          ? Image.network(
                                            cartItem["image"],
                                            width: w * 0.22,
                                            height: w * 0.22,
                                            fit: BoxFit.cover,
                                          )
                                          : Icon(Icons.image, size: w * 0.18),
                                ),
                              ),
                              SizedBox(width: w * 0.01),

                              // Product info + Quantity
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cartItem["name"],
                                      style: GoogleFonts.inter(
                                        fontSize: 16 * textScale,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF0D141C),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: h * 0.004),
                                    Text(
                                      "₪${cartItem["price"]}",
                                      style: GoogleFonts.inter(
                                        fontSize: 14 * textScale,
                                        color: const Color(0xFF49709C),
                                      ),
                                    ),

                                    // Size selection
                                    GestureDetector(
                                      onTap: () => _selectSize(cartId, sizes),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4,
                                        ),
                                        child: Text(
                                          "Size: ${cartItem["size"]}",
                                          style: GoogleFonts.inter(
                                            fontSize: 13 * textScale,
                                            color: Colors.black87,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Color selection
                                    GestureDetector(
                                      onTap: () => _selectColor(cartId, colors),
                                      child: Row(
                                        children: [
                                          Text(
                                            "Color: ",
                                            style: GoogleFonts.inter(
                                              fontSize: 13 * textScale,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          Container(
                                            width: 16,
                                            height: 16,
                                            decoration: BoxDecoration(
                                              color: Color(cartItem["color"]),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.grey.shade400,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Quantity controls + Delete
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            IconButton(
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(
                                                minWidth: 0,
                                                minHeight: 0,
                                              ),
                                              icon: const Icon(Icons.remove),
                                              onPressed:
                                                  () => _decreaseQty(
                                                    cartId,
                                                    cartItem["quantity"],
                                                  ),
                                            ),
                                            Text(
                                              "${cartItem["quantity"]}",
                                              style: GoogleFonts.inter(
                                                fontSize: 15 * textScale,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            IconButton(
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(
                                                minWidth: 0,
                                                minHeight: 0,
                                              ),
                                              icon: const Icon(Icons.add),
                                              onPressed:
                                                  () => _increaseQty(
                                                    cartId,
                                                    cartItem["quantity"],
                                                  ),
                                            ),
                                          ],
                                        ),
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(
                                            minWidth: 0,
                                            minHeight: 0,
                                          ),
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                            size: 18 * textScale,
                                          ),
                                          onPressed:
                                              () => _removeFromCart(cartId),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
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
                            borderRadius: BorderRadius.circular(w * 0.03),
                          ),
                        ),
                        onPressed: () {
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
