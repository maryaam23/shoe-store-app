import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'checkout_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final List<Map<String, dynamic>> cartItems = [
    {
      "name": "Air Max 90",
      "variant": "Size 8 | Black",
      "price": 120.0,
      "image": "assets/images/shoe1.png",
      "qty": 1,
    },
    {
      "name": "Air Force 1",
      "variant": "Size 9 | White",
      "price": 120.0,
      "image": "assets/images/shoe2.png",
      "qty": 1,
    },
    {
      "name": "Air Jordan 1",
      "variant": "Size 10 | Red",
      "price": 120.0,
      "image": "assets/images/shoe3.png",
      "qty": 1,
    },
  ];

  void _increaseQty(int index) {
    setState(() {
      cartItems[index]["qty"]++;
    });
  }

  void _decreaseQty(int index) {
    setState(() {
      if (cartItems[index]["qty"] > 1) {
        cartItems[index]["qty"]--;
      }
    });
  }

  double get subtotal =>
      cartItems.fold(0, (sum, item) => sum + item["price"] * item["qty"]);

  double get taxes => subtotal * 0.1;

  double get total => subtotal + taxes;

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    double imageSize = w * 0.08; // Smaller image
    if (imageSize > 50) imageSize = 50;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: w * 0.04,
                    vertical: h * 0.015,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE7EDF4), width: 1),
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
                          child: Image.asset(
                            item["image"],
                            width: imageSize,
                            height: imageSize,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(width: w * 0.03),
                      // Product info
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item["name"],
                                    style: GoogleFonts.inter(
                                      fontSize: w * 0.04,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF0D141C),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: h * 0.003),
                                  Text(
                                    item["variant"],
                                    style: GoogleFonts.inter(
                                      fontSize: w * 0.035,
                                      color: const Color(0xFF49709C),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            // Quantity buttons fixed width
                            SizedBox(
                              width: w * 0.22, // fixed width to prevent overflow
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove, size: w * 0.045),
                                    onPressed: () => _decreaseQty(index),
                                  ),
                                  Text(
                                    "${item["qty"]}",
                                    style: GoogleFonts.inter(
                                      fontSize: w * 0.04,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.add, size: w * 0.045),
                                    onPressed: () => _increaseQty(index),
                                  ),
                                ],
                              ),
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
                _buildSummaryRow("Subtotal", "\$${subtotal.toStringAsFixed(2)}", w),
                _buildSummaryRow("Shipping", "Free", w),
                _buildSummaryRow("Taxes", "\$${taxes.toStringAsFixed(2)}", w),
                Divider(thickness: 1, color: Colors.grey[300]),
                _buildSummaryRow("Total", "\$${total.toStringAsFixed(2)}", w,
                    isBold: true),
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
                        MaterialPageRoute(builder: (_) => const CheckoutPage()),
                      );
                    },
                    child: Text(
                      "Checkout",
                      style: GoogleFonts.inter(
                        fontSize: w * 0.045,
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
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, double w,
      {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: w * 0.01),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: w * 0.038,
              color: const Color(0xFF49709C),
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: w * 0.038,
              color: const Color(0xFF0D141C),
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
