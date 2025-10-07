import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderConfirmationPage extends StatelessWidget {
  final double subtotal;
  final double shipping;
  final double total;
  final String orderNumber;

  const OrderConfirmationPage({
    super.key,
    required this.subtotal,
    required this.shipping,
    required this.total,
    required this.orderNumber,
  });

  @override
  Widget build(BuildContext context) {
    // Trigger notification when user reaches this page
    _sendOrderNotification(orderNumber, total);

    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    final dateNow = DateTime.now();
    final formattedDate = "${dateNow.day}/${dateNow.month}/${dateNow.year}";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.04),
            child: Column(
              children: [
                SizedBox(height: h * 0.05),

                // Success Icon
                Container(
                  width: w * 0.25,
                  height: w * 0.25,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.shade100,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: w * 0.25,
                  ),
                ),
                SizedBox(height: h * 0.03),

                Text(
                  "Thank You!",
                  style: GoogleFonts.inter(
                    fontSize: w * 0.08,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: h * 0.01),
                Text(
                  "Your order has been placed successfully.",
                  style: GoogleFonts.inter(
                    fontSize: w * 0.04,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: h * 0.03),

                // Order Info Card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(w * 0.04),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: EdgeInsets.all(w * 0.04),
                    child: Column(
                      children: [
                        _infoRow(w, Icons.tag, "Order Number", orderNumber),
                        const Divider(),
                        _infoRow(
                          w,
                          Icons.date_range,
                          "Order Date",
                          formattedDate,
                        ),
                        const Divider(),
                        _infoRow(
                          w,
                          Icons.local_shipping,
                          "Estimated Delivery",
                          "2 - 3 Business Days",
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: h * 0.03),

                // Order Summary
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(w * 0.04),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: EdgeInsets.all(w * 0.04),
                    child: Column(
                      children: [
                        _summaryRow(
                          "Subtotal",
                          "₪${subtotal.toStringAsFixed(2)}",
                          w,
                        ),
                        _summaryRow(
                          "Shipping",
                          "₪${shipping.toStringAsFixed(2)}",
                          w,
                        ),
                        const Divider(),
                        _summaryRow(
                          "Total",
                          "₪${total.toStringAsFixed(2)}",
                          w,
                          bold: true,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: h * 0.04),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: _secondaryButton(
                        w,
                        h,
                        "Share Receipt",
                        () => _shareReceiptAsPDF(orderNumber, formattedDate),
                      ),
                    ),
                    SizedBox(width: w * 0.03),
                    Expanded(
                      child: _secondaryButton(
                        w,
                        h,
                        "Continue Shopping",
                        () => _continueShopping(context),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: h * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ----------------- FIRESTORE NOTIFICATION -----------------
  Future<void> _sendOrderNotification(String orderNumber, double total) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);

      await userRef.collection('notification').add({
        "title": "Order #$orderNumber Confirmed 🎉",
        "subtitle":
            "Your order of ₪${total.toStringAsFixed(2)} has been placed successfully.",
        "category": "order_updates",
        "isRead": false,
        "createdAt": FieldValue.serverTimestamp(),
        "image": "https://cdn-icons-png.flaticon.com/512/190/190411.png",
      });

      debugPrint("✅ Custom order notification added for user ${user.uid}");
    } catch (e) {
      debugPrint("❌ Failed to send notification: $e");
    }
  }

  // ----------------- PDF SHARE -----------------
  Future<void> _shareReceiptAsPDF(String orderNumber, String date) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    String customerName = "Customer";
    String customerPhone = "N/A";

    if (userId != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        customerName = data['fullName'] ?? "Customer";
        customerPhone = data['phone'] ?? "N/A";
      }
    }

    final pdf = pw.Document();
    final fontData = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);
    final logoBytes = await rootBundle.load('assets/logoImage.png');
    final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());

    pdf.addPage(
      pw.Page(
        build:
            (context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Image(logoImage, width: 60, height: 60),
                    pw.SizedBox(width: 10),
                    pw.Text(
                      "SPORT BRANDS",
                      style: pw.TextStyle(
                        font: ttf,
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                pw.Divider(height: 20, thickness: 2),
                pw.Text(
                  "Order Confirmation",
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 15),
                pw.Text(
                  "Customer Name: $customerName",
                  style: pw.TextStyle(font: ttf),
                ),
                pw.Text(
                  "Phone Number: $customerPhone",
                  style: pw.TextStyle(font: ttf),
                ),
                pw.Text(
                  "Order Number: #$orderNumber",
                  style: pw.TextStyle(font: ttf),
                ),
                pw.Text("Order Date: $date", style: pw.TextStyle(font: ttf)),
                pw.SizedBox(height: 10),
                pw.Text(
                  "Subtotal: ₪${subtotal.toStringAsFixed(2)}",
                  style: pw.TextStyle(font: ttf),
                ),
                pw.Text(
                  "Shipping: ₪${shipping.toStringAsFixed(2)}",
                  style: pw.TextStyle(font: ttf),
                ),
                pw.Text(
                  "Total: ₪${total.toStringAsFixed(2)}",
                  style: pw.TextStyle(font: ttf),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  "Thank you for shopping with us!",
                  style: pw.TextStyle(font: ttf),
                ),
              ],
            ),
      ),
    );

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/order_receipt.pdf');
    await file.writeAsBytes(await pdf.save());

    Share.shareXFiles([XFile(file.path)], text: 'Your Order Receipt');
  }

  // ----------------- CONTINUE SHOPPING -----------------
  void _continueShopping(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomePage()),
      (route) => false,
    );
  }

  // ----------------- UI HELPERS -----------------
  Widget _infoRow(double w, IconData icon, String title, String value) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: const Color(0xFFE7EDF4),
          radius: w * 0.06,
          child: Icon(icon, color: Colors.black87, size: w * 0.06),
        ),
        SizedBox(width: w * 0.04),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: w * 0.04,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: w * 0.035,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _summaryRow(
    String label,
    String value,
    double w, {
    bool bold = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: w * 0.01),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: w * 0.04,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: w * 0.04,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _secondaryButton(double w, double h, String text, VoidCallback onTap) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: const Color(0xFFE7EDF4),
        foregroundColor: Colors.black87,
        padding: EdgeInsets.symmetric(vertical: h * 0.015),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(w * 0.03),
        ),
      ),
      onPressed: onTap,
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
          fontSize: w * 0.035,
        ),
      ),
    );
  }
}
