import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderConfirmationPage extends StatelessWidget {
  const OrderConfirmationPage({super.key});

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
        centerTitle: true,
        title: Text(
          "Order Confirmation",
          style: GoogleFonts.inter(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            "Thank you for your order!",
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0D141C),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Your order has been placed successfully.\nYou will receive an email confirmation shortly.",
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF0D141C),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Product / Banner Image
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: const DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(
                  "https://lh3.googleusercontent.com/aida-public/AB6AXuDqMH0x0b3emKPOGeY3O7PSEFEsRZA7XCipCPEvz6T8ELU9ikXfQH_X6WAgYyvK3jC3tPx0aOODH4gheMfLQ8dmqxBJjX8JshqPjIrzG4vEYCPbFElFKaqWkbffxaexIA0-IVm_pFzBxEY3JHu4bwMopgpK4_VGen0kuFRka77fwLO3aCwEtK3Ua6hwUVvI7a_4PREdhzai4uyDVNJqHBxYsIKdRe3tUJH18sLOtrfugepe1vXJoZMIrEjZMszIHmPw2nZAPKv_lW0J",
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Order Number
          _infoTile(
            icon: Icons.tag,
            title: "Order Number",
            subtitle: "1234567890",
          ),

          // Delivery Estimate
          _infoTile(
            icon: Icons.local_shipping,
            title: "Estimated Delivery",
            subtitle: "June 15, 2024",
          ),

          const Spacer(),

          // Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D78F2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                // TODO: Track order logic
              },
              child: Text("Track Order",
                  style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _secondaryButton("Share Receipt", () {
                // TODO: Share receipt logic
              }),
              _secondaryButton("Continue Shopping", () {
                // TODO: Navigate to shop
              }),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFE7EDF4),
            radius: 24,
            child: Icon(icon, color: Colors.black),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0D141C))),
              Text(subtitle,
                  style: GoogleFonts.inter(
                      fontSize: 13, color: const Color(0xFF49709C))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _secondaryButton(String text, VoidCallback onTap) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: const Color(0xFFE7EDF4),
        foregroundColor: const Color(0xFF0D141C),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onTap,
      child: Text(
        text,
        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }
}
