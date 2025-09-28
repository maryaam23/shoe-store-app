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

  void _increaseQty(String productId, int currentQty) {
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .collection("cart")
        .doc(productId)
        .update({"quantity": currentQty + 1});
  }

  void _decreaseQty(String productId, int currentQty) {
    if (currentQty > 1) {
      FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .collection("cart")
          .doc(productId)
          .update({"quantity": currentQty - 1});
    }
  }

  double _calculateSubtotal(List<QueryDocumentSnapshot> cartDocs) {
    return cartDocs.fold(
      0,
      (sum, doc) => sum + (doc["price"] * doc["quantity"]),
    );
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
                    final item = cartDocs[index];
                    final productId = item.id;

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
                                  (item.data().toString().contains("image") &&
                                          item["image"] != null)
                                      ? Image.network(
                                        item["image"],
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Product info
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item["name"],
                                        style: GoogleFonts.inter(
                                          fontSize: 16 * textScale,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF0D141C),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: h * 0.004),
                                      Text(
                                        "₪${item["price"]}",
                                        style: GoogleFonts.inter(
                                          fontSize: 14 * textScale,
                                          color: const Color(0xFF49709C),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),

                                // Quantity controls + Delete
                                Row(
                                  mainAxisSize:
                                      MainAxisSize.min, // shrink to content
                                  mainAxisAlignment:
                                      MainAxisAlignment.end, // push to right
                                  children: [
                                    // Decrease button
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(
                                        minWidth: 0,
                                        minHeight: 0,
                                      ),
                                      icon: Icon(
                                        Icons.remove,
                                        size: 18 * textScale,
                                      ),
                                      onPressed:
                                          () => _decreaseQty(
                                            productId,
                                            item["quantity"],
                                          ),
                                    ),

                                    // Quantity text
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 2,
                                      ), // small spacing
                                      child: Text(
                                        "${item["quantity"]}",
                                        style: GoogleFonts.inter(
                                          fontSize: 15 * textScale,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),

                                    // Increase button
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(
                                        minWidth: 0,
                                        minHeight: 0,
                                      ),
                                      icon: Icon(
                                        Icons.add,
                                        size: 18 * textScale,
                                      ),
                                      onPressed:
                                          () => _increaseQty(
                                            productId,
                                            item["quantity"],
                                          ),
                                    ),

                                    // Delete button
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
                                          () => _removeFromCart(productId),
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

  void _removeFromCart(String productId) {
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .collection("cart")
        .doc(productId)
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
