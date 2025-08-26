import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leadingWidth: 0,
        title: const Text(""),
        actions: [
          IconButton(
            icon: const Icon(Icons.grid_view_rounded, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tabs Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Text("All", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Women"),
                Text("Men"),
                Text("Kids"),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Image.network(
                    "https://images.unsplash.com/photo-1606813909027-1e6f27bb8c8b",
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  const Positioned(
                    bottom: 12,
                    left: 12,
                    child: Text(
                      "The Big Softie: Cloudsurfer Max",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Product Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 260,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                return _buildProductCard(
                  "Cloudspike Amplius 2",
                  index % 2 == 0 ? "Women" : "Men",
                  "\$160.00",
                  "https://static.nike.com/a/images/t_default/8b68d8f1-b228-4689-8ff0-1f89f2a57502/air-max-270-mens-shoes-KkLcGR.png",
                );
              },
            ),
          ),
        ],
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ""),
        ],
      ),
    );
  }

  Widget _buildProductCard(String title, String category, String price, String imageUrl) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shoe Image
            Expanded(
              child: Center(
                child: Image.network(imageUrl, height: 100),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "NEW COLOR",
              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12),
            ),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              "$category – Track running, spikes, long-distance",
              maxLines: 2,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
