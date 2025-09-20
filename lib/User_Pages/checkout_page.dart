import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'order_confirmation_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String selectedAddress = "Home";
  String selectedPayment = "Credit Card";

  final List<Map<String, dynamic>> addresses = [
    {
      "label": "Home",
      "value": "Home",
      "details": "123 Elm Street, Apt 4B, Anytown, USA",
      "icon": Icons.home,
    },
    {
      "label": "Work",
      "value": "Work",
      "details": "456 Oak Avenue, Unit 12, Anytown, USA",
      "icon": Icons.work,
    },
  ];

  final List<Map<String, dynamic>> payments = [
    {"label": "Credit Card", "value": "Credit Card", "icon": Icons.credit_card},
    {
      "label": "Cash on Delivery",
      "value": "Cash on Delivery",
      "icon": Icons.money,
    },
    {
      "label": "PayPal",
      "value": "PayPal",
      "icon": Icons.account_balance_wallet,
    },
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
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    double total = subtotal + shipping + tax;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: w * 0.07),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Checkout",
          style: GoogleFonts.inter(
            fontSize: w * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: w * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("Delivery Address", w, h),
              ...addresses.map(
                (addr) => RadioListTile(
                  value: addr["value"],
                  groupValue: selectedAddress,
                  onChanged: (val) => setState(() => selectedAddress = val!),
                  title: Text(
                    addr["label"],
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, fontSize: w * 0.045),
                  ),
                  subtitle: Text(
                    addr["details"],
                    style: GoogleFonts.inter(
                        color: const Color(0xFF49709C), fontSize: w * 0.035),
                  ),
                  secondary: CircleAvatar(
                    backgroundColor: const Color(0xFFE7EDF4),
                    radius: w * 0.07,
                    child: Icon(addr["icon"], color: Colors.black, size: w * 0.06),
                  ),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFE7EDF4),
                  radius: w * 0.07,
                  child: Icon(Icons.add, color: Colors.black, size: w * 0.06),
                ),
                title: Text("Add New Address",
                    style: GoogleFonts.inter(fontSize: w * 0.045)),
                onTap: () {},
              ),
              _sectionTitle("Payment Method", w, h),
              ...payments.map(
                (pm) => RadioListTile(
                  value: pm["value"],
                  groupValue: selectedPayment,
                  onChanged: (val) => setState(() => selectedPayment = val!),
                  title: Text(
                    pm["label"],
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500, fontSize: w * 0.045),
                  ),
                  secondary: CircleAvatar(
                    backgroundColor: const Color(0xFFE7EDF4),
                    radius: w * 0.07,
                    child: Icon(pm["icon"], color: Colors.black, size: w * 0.06),
                  ),
                ),
              ),
              _sectionTitle("Order Summary", w, h),
              ...orderItems.map(
                (item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(w * 0.03),
                    child:
                        Image.asset(item["image"], width: w * 0.12, height: w * 0.12),
                  ),
                  title: Text(
                    item["name"],
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, fontSize: w * 0.045),
                  ),
                  subtitle: Text(
                    "Quantity: ${item["qty"]}",
                    style: GoogleFonts.inter(
                        color: const Color(0xFF49709C), fontSize: w * 0.035),
                  ),
                ),
              ),
              _summaryRow("Subtotal", "\$${subtotal.toStringAsFixed(2)}", w),
              _summaryRow("Shipping", "\$${shipping.toStringAsFixed(2)}", w),
              _summaryRow("Tax", "\$${tax.toStringAsFixed(2)}", w),
              _summaryRow("Total", "\$${total.toStringAsFixed(2)}", w, bold: true),
              Padding(
                padding: EdgeInsets.symmetric(vertical: h * 0.02),
                child: TextField(
                  controller: notesController,
                  maxLines: 3,
                  style: GoogleFonts.inter(fontSize: w * 0.04),
                  decoration: InputDecoration(
                    hintText: "Order Notes (e.g., Leave at door, Gift wrap)",
                    hintStyle:
                        GoogleFonts.inter(color: const Color(0xFF49709C), fontSize: w * 0.04),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(w * 0.03),
                      borderSide: const BorderSide(color: Color(0xFFCEDAE8)),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: EdgeInsets.all(w * 0.04),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(w * 0.04),
          child: SizedBox(
            width: double.infinity,
            height: h * 0.07,
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
                    builder: (_) => const OrderConfirmationPage(),
                  ),
                );
              },
              child: Text(
                "Confirm Purchase",
                style: GoogleFonts.inter(
                  fontSize: w * 0.045,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, double w, double h) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, h * 0.02, 0, h * 0.01),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: w * 0.05,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, double w, {bool bold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: w * 0.015),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              color: const Color(0xFF49709C),
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: w * 0.045,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              color: Colors.black,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: w * 0.045,
            ),
          ),
        ],
      ),
    );
  }
}
