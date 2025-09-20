import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderConfirmationPage extends StatelessWidget {
  const OrderConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: w * 0.07),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          "Order Confirmation",
          style: GoogleFonts.inter(
            fontSize: w * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(bottom: h * 0.02), // space at bottom
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: h * 0.02),
                Text(
                  "Thank you for your order!",
                  style: GoogleFonts.inter(
                    fontSize: w * 0.07,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0D141C),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: h * 0.01),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: w * 0.06),
                  child: Text(
                    "Your order has been placed successfully.\nYou will receive an email confirmation shortly.",
                    style: GoogleFonts.inter(
                      fontSize: w * 0.035,
                      color: const Color(0xFF0D141C),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: h * 0.03),

                // Banner image
                Container(
                  margin: EdgeInsets.symmetric(horizontal: w * 0.04),
                  height: h * 0.25,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(w * 0.03),
                    image: const DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(
                        "https://lh3.googleusercontent.com/aida-public/AB6AXuDqMH0x0b3emKPOGeY3O7PSEFEsRZA7XCipCPEvz6T8ELU9ikXfQH_X6WAgYyvK3jC3tPx0aOODH4gheMfLQ8dmqxBJjX8JshqPjIrzG4vEYCPbFElFKaqWkbffxaexIA0-IVm_pFzBxEY3JHu4bwMopgpK4_VGen0kuFRka77fwLO3aCwEtK3Ua6hwUVvI7a_4PREdhzai4uyDVNJqHBxYsIKdRe3tUJH18sLOtrfugepe1vXJoZMIrEjZMszIHmPw2nZAPKv_lW0J",
                      ),
                    ),
                  ),
                ),
                SizedBox(height: h * 0.03),

                // Info tiles
                _infoTile(w: w, h: h, icon: Icons.tag, title: "Order Number", subtitle: "1234567890"),
                _infoTile(
                    w: w, h: h, icon: Icons.local_shipping, title: "Estimated Delivery", subtitle: "June 15, 2024"),

                SizedBox(height: h * 0.02),

                // Track Order Button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.015),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D78F2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(w * 0.03)),
                      padding: EdgeInsets.symmetric(vertical: h * 0.018),
                    ),
                    onPressed: () {},
                    child: Text("Track Order",
                        style: GoogleFonts.inter(
                            fontSize: w * 0.045, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),

                // Secondary Buttons Row
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.01),
                  child: Row(
                    children: [
                      Expanded(child: _secondaryButton(w, h, "Share Receipt", () {})),
                      SizedBox(width: w * 0.03),
                      Expanded(child: _secondaryButton(w, h, "Continue Shopping", () {})),
                    ],
                  ),
                ),
                SizedBox(height: h * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoTile({
    required double w,
    required double h,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.012),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFE7EDF4),
            radius: w * 0.06,
            child: Icon(icon, color: Colors.black, size: w * 0.06),
          ),
          SizedBox(width: w * 0.03),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.inter(
                      fontSize: w * 0.04,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0D141C))),
              SizedBox(height: h * 0.002),
              Text(subtitle,
                  style: GoogleFonts.inter(fontSize: w * 0.035, color: const Color(0xFF49709C))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _secondaryButton(double w, double h, String text, VoidCallback onTap) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: const Color(0xFFE7EDF4),
        foregroundColor: const Color(0xFF0D141C),
        padding: EdgeInsets.symmetric(vertical: h * 0.012),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(w * 0.03)),
      ),
      onPressed: onTap,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: w * 0.035),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
