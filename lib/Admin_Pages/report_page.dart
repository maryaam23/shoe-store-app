import 'package:flutter/material.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // bg-slate-50
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F5F9),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0D141C)),
          onPressed: () {},
        ),
        title: const Text(
          "Sales Overview",
          style: TextStyle(
              color: Color(0xFF0D141C),
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Time Range Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _TimeRangeButton(title: "Daily", selected: false),
              _TimeRangeButton(title: "Weekly", selected: true),
              _TimeRangeButton(title: "Monthly", selected: false),
            ],
          ),
          const SizedBox(height: 16),

          // Revenue Card
          _RevenueCard(),

          // Best-Selling Products
          const SizedBox(height: 24),
          const Text(
            "Best-Selling Products",
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0D141C)),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                _ProductCard(
                  title: "Performance Runners",
                  sold: 150,
                  imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuA_YD3oP_nSKgjxOUG9Zql-chu5N8Pk0dXk95Mo4Grj5h-AX2NoBCpBe-9L9OXO7akh-EiqAwbAyd0zhoguA1tTCgl78zWQHtcygoAX6bF7SKaZSZJpHpEIv1-OHLzbTmr21ZXdGZdeij9DVi-DX2lMuxCSqWciPaoTJ2xFIviFe_5aL7Day8sM2xAPHcexmeyLxsz7u7oSWyxLylunsBJBaeX1AUleNHXuWtFdYOsWAxfNDuIJCxsfYu-9RPy9nOdDnRL81PvfzxDm",
                ),
                _ProductCard(
                  title: "Court Dominators",
                  sold: 120,
                  imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuAXnOSib5bDmKlsx14O_aUWgywmHqKEVaJpQYZMZvJBKlO48AvhwHjR66cAne9pQhkNbOQvFylRqO6zfvsrywnsRUhkd4bI1Lsvj6YTdMzfl1p2dEXfDCRGc2PjhVVApO0P_Z_0YdnqLMjQsiSzZbfB-VFA_iWdPssiOLx7xvjyfG1tST8N90esokCXm6vi5c9Vwcc9gP8-XraDHKi16RYHAnY-0dtChN5UHhK7fltgZHmwgmUIIx1WuiehOIKMMIwIfjmkmMlgdLo7",
                ),
                _ProductCard(
                  title: "Street Style",
                  sold: 100,
                  imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuCS9r-zVfyDx32-jR35dMBaU35bB1OGgZcJA1PBijk9fQ5xKsOKMDEE_rYsXssk-0VFHRLTlazYUCDxvjEutxx2Br8gvHqjibXg7u7-6WaPLhSc1Kum4iolENSDX9EXm9XUQ-j61M_HtmzdCDyQVUgZJnByQEZl_6AOXoFlLE7gjnFeJBdn1u4Fnb1t99bqJ9YC5oOIFk32OxAbMDiIIhEaO_YtAa8U2p7JlHa4dMstxf-q7KHqgWUg85VvyiYNS_Ny92Hkk9OAYFZH",
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            "Customer Order Trends",
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0D141C)),
          ),
          const SizedBox(height: 12),
          _OrdersCard(),

          const SizedBox(height: 24),
          const Text(
            "Stock Reports",
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0D141C)),
          ),
          const SizedBox(height: 12),
          _StockReportCard(
            title: "Low Stock",
            subtitle: "10 items",
            icon: Icons.inventory_2_outlined,
          ),
          _StockReportCard(
            title: "Most Stocked Categories",
            subtitle: "5 categories",
            icon: Icons.category_outlined,
          ),

          const SizedBox(height: 32),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D78F2),
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {},
            icon: const Icon(Icons.file_copy, color: Colors.white),
            label: const Text(
              "Export Reports",
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// Reusable Widgets
class _TimeRangeButton extends StatelessWidget {
  final String title;
  final bool selected;
  const _TimeRangeButton({required this.title, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: selected ? Colors.white : const Color(0xFFE7EDF4),
          borderRadius: BorderRadius.circular(8),
          boxShadow: selected
              ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]
              : [],
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
                color: selected ? const Color(0xFF0D141C) : const Color(0xFF49709C),
                fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}

class _RevenueCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Revenue",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF0D141C))),
            const SizedBox(height: 4),
            const Text("\$12,500",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0D141C))),
            const SizedBox(height: 8),
            Row(
              children: const [
                Text("Last 7 Days", style: TextStyle(color: Color(0xFF49709C))),
                SizedBox(width: 4),
                Text("+15%", style: TextStyle(color: Color(0xFF07883B), fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 148,
              color: const Color(0xFFE7EDF4),
              child: const Center(child: Text("Revenue Chart Placeholder")),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String title;
  final int sold;
  final String imageUrl;
  const _ProductCard({required this.title, required this.sold, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(imageUrl, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF0D141C))),
          Text("$sold units sold", style: const TextStyle(color: Color(0xFF49709C), fontSize: 12)),
        ],
      ),
    );
  }
}

class _OrdersCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Orders", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF0D141C))),
            const SizedBox(height: 4),
            const Text("250",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0D141C))),
            const SizedBox(height: 8),
            Row(
              children: const [
                Text("Last 7 Days", style: TextStyle(color: Color(0xFF49709C))),
                SizedBox(width: 4),
                Text("+8%", style: TextStyle(color: Color(0xFF07883B), fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 148,
              color: const Color(0xFFE7EDF4),
              child: const Center(child: Text("Orders Chart Placeholder")),
            ),
          ],
        ),
      ),
    );
  }
}

class _StockReportCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const _StockReportCard({required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFE7EDF4),
              child: Icon(icon, color: const Color(0xFF0D141C)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF0D141C))),
                Text(subtitle, style: const TextStyle(color: Color(0xFF49709C), fontSize: 12)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
