import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String selectedAddress = "Home";
  String selectedPayment = "Credit Card";

  final List<Map<String, dynamic>> addresses = [
    {"label": "Home", "value": "Home", "details": "123 Elm Street, Apt 4B, Anytown, USA", "icon": Icons.home},
    {"label": "Work", "value": "Work", "details": "456 Oak Avenue, Unit 12, Anytown, USA", "icon": Icons.work},
  ];

  final List<Map<String, dynamic>> payments = [
    {"label": "Credit Card", "value": "Credit Card", "icon": Icons.credit_card},
    {"label": "Cash on Delivery", "value": "Cash on Delivery", "icon": Icons.money},
    {"label": "PayPal", "value": "PayPal", "icon": Icons.account_balance_wallet},
    {"label": "Apple Pay", "value": "Apple Pay", "icon": Icons.apple},
  ];

  final List<Map<String, dynamic>> orderItems = [
    {"name": "Running Shoes", "qty": 1, "image": "assets/images/shoe1.png"},
    {"name": "Casual Sneakers", "qty": 1, "image": "assets/images/shoe2.png"},
  ];

  double subtotal = 150.0;
  double shipping = 10.0;
  double tax = 12.0;

  TextEditingController notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double total = subtotal + shipping + tax;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Checkout",
            style: GoogleFonts.inter(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("Delivery Address"),
            ...addresses.map((addr) => RadioListTile(
                  value: addr["value"],
                  groupValue: selectedAddress,
                  onChanged: (val) => setState(() => selectedAddress = val!),
                  title: Text(addr["label"],
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  subtitle: Text(addr["details"],
                      style: GoogleFonts.inter(color: const Color(0xFF49709C))),
                  secondary: CircleAvatar(
                    backgroundColor: const Color(0xFFE7EDF4),
                    child: Icon(addr["icon"], color: Colors.black),
                  ),
                )),
            ListTile(
              leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE7EDF4),
                  child: Icon(Icons.add, color: Colors.black)),
              title: Text("Add New Address", style: GoogleFonts.inter()),
              onTap: () {},
            ),

            _sectionTitle("Payment Method"),
            ...payments.map((pm) => RadioListTile(
                  value: pm["value"],
                  groupValue: selectedPayment,
                  onChanged: (val) => setState(() => selectedPayment = val!),
                  title: Text(pm["label"],
                      style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
                  secondary: CircleAvatar(
                    backgroundColor: const Color(0xFFE7EDF4),
                    child: Icon(pm["icon"], color: Colors.black),
                  ),
                )),

            _sectionTitle("Order Summary"),
            ...orderItems.map((item) => ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(item["image"], width: 48, height: 48),
                  ),
                  title: Text(item["name"],
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  subtitle: Text("Quantity: ${item["qty"]}",
                      style: GoogleFonts.inter(color: const Color(0xFF49709C))),
                )),
            _summaryRow("Subtotal", "\$${subtotal.toStringAsFixed(2)}"),
            _summaryRow("Shipping", "\$${shipping.toStringAsFixed(2)}"),
            _summaryRow("Tax", "\$${tax.toStringAsFixed(2)}"),
            _summaryRow("Total", "\$${total.toStringAsFixed(2)}", bold: true),

            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Order Notes (e.g., Leave at door, Gift wrap)",
                  hintStyle: GoogleFonts.inter(color: const Color(0xFF49709C)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFFCEDAE8))),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D78F2),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () {
              // Handle confirm purchase
            },
            child: Text("Confirm Purchase",
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(title,
          style: GoogleFonts.inter(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  color: const Color(0xFF49709C),
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: GoogleFonts.inter(
                  color: Colors.black,
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
