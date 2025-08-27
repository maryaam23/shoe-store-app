import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int _selectedIndex = 1;

  final List<Map<String, dynamic>> cartItems = [
    {
      "name": "Air Max 90",
      "variant": "Size 8 | Black",
      "price": 120.0,
      "image": "assets/images/shoe1.png",
      "qty": 1
    },
    {
      "name": "Air Force 1",
      "variant": "Size 9 | White",
      "price": 120.0,
      "image": "assets/images/shoe2.png",
      "qty": 1
    },
    {
      "name": "Air Jordan 1",
      "variant": "Size 10 | Red",
      "price": 120.0,
      "image": "assets/images/shoe3.png",
      "qty": 1
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Cart",
          style: GoogleFonts.inter(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Cart Items
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                        bottom: BorderSide(color: Color(0xFFE7EDF4), width: 1)),
                  ),
                  child: Row(
                    children: [
                      // Product image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(item["image"],
                            width: 56, height: 56, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 12),
                      // Product info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item["name"],
                                style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF0D141C))),
                            const SizedBox(height: 4),
                            Text(item["variant"],
                                style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: const Color(0xFF49709C))),
                          ],
                        ),
                      ),
                      // Quantity buttons
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 18),
                            onPressed: () => _decreaseQty(index),
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                  const Color(0xFFE7EDF4)),
                              shape: WidgetStateProperty.all(
                                const CircleBorder(),
                              ),
                            ),
                          ),
                          Text("${item["qty"]}",
                              style: GoogleFonts.inter(
                                  fontSize: 16, fontWeight: FontWeight.w500)),
                          IconButton(
                            icon: const Icon(Icons.add, size: 18),
                            onPressed: () => _increaseQty(index),
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                  const Color(0xFFE7EDF4)),
                              shape: WidgetStateProperty.all(
                                const CircleBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Summary Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSummaryRow("Subtotal", "\$${subtotal.toStringAsFixed(2)}"),
                _buildSummaryRow("Shipping", "Free"),
                _buildSummaryRow("Taxes", "\$${taxes.toStringAsFixed(2)}"),
                const Divider(),
                _buildSummaryRow("Total", "\$${total.toStringAsFixed(2)}",
                    isBold: true),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D78F2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {},
                    child: Text("Checkout",
                        style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0D141C),
        unselectedItemColor: const Color(0xFF49709C),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Categories"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Wishlist"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF49709C),
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF0D141C),
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
