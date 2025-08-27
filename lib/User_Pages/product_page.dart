import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int selectedSize = 42;
  Color selectedColor = Colors.black;

  final List<String> productImages = [
    'assets/images/shoe1.png',
    'assets/images/shoe2.png',
    'assets/images/shoe3.png',
  ];

  final List<int> sizes = [38, 39, 40, 41, 42, 43];
  final List<Color> colors = [Colors.black, Colors.red, Colors.blue, Colors.green];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image Carousel
              SizedBox(
                height: 250,
                child: PageView.builder(
                  itemCount: productImages.length,
                  itemBuilder: (context, index) {
                    return Image.asset(productImages[index], fit: BoxFit.contain);
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Title + Brand + Price
              Text("Air Max 90", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
              Text("by Nike", style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600])),
              const SizedBox(height: 8),
              Text("\$120.00", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.black)),

              const SizedBox(height: 20),

              // Size Selector
              Text("Select Size", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: sizes.map((size) {
                  final isSelected = selectedSize == size;
                  return ChoiceChip(
                    label: Text(size.toString()),
                    selected: isSelected,
                    onSelected: (_) => setState(() => selectedSize = size),
                    selectedColor: Colors.black,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Color Selector
              Text("Select Color", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Row(
                children: colors.map((color) {
                  final isSelected = selectedColor == color;
                  return GestureDetector(
                    onTap: () => setState(() => selectedColor = color),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: isSelected ? Colors.black : Colors.transparent, width: 2),
                      ),
                      child: CircleAvatar(backgroundColor: color, radius: 18),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Stock + Delivery Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 6),
                    Text("In Stock", style: GoogleFonts.poppins(fontSize: 16)),
                  ]),
                  Row(children: [
                    const Icon(Icons.local_shipping, color: Colors.blue),
                    const SizedBox(width: 6),
                    Text("Delivery: 2-4 days", style: GoogleFonts.poppins(fontSize: 16)),
                  ]),
                ],
              ),

              const SizedBox(height: 20),

              // Add to Cart Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {},
                  child: Text("Add to Cart", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),

              const SizedBox(height: 24),

              // Expandable Description
              ExpansionTile(
                title: Text("Description", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500)),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("The Nike Air Max 90 stays true to its OG running roots with the iconic Waffle sole and stitched overlays, while bold colors add a fresh look.", style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700])),
                  ),
                ],
              ),

              // Expandable Product Details
              ExpansionTile(
                title: Text("Product Details", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500)),
                children: [
                  ListTile(title: Text("Material: Mesh, Leather", style: GoogleFonts.poppins(fontSize: 14))),
                  ListTile(title: Text("Sole: Rubber", style: GoogleFonts.poppins(fontSize: 14))),
                  ListTile(title: Text("Weight: 300g", style: GoogleFonts.poppins(fontSize: 14))),
                ],
              ),

              const SizedBox(height: 20),

              // Review Summary
              Text("Customer Reviews", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text("4.5", style: GoogleFonts.poppins(fontSize: 40, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: List.generate(5, (i) => const Icon(Icons.star, color: Colors.amber, size: 20))),
                      Text("200 Reviews", style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Customer Review Example
              ListTile(
                leading: const CircleAvatar(backgroundImage: AssetImage("assets/images/user1.png")),
                title: Text("John Doe", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                subtitle: Text("Great shoes! Very comfortable and stylish.", style: GoogleFonts.poppins()),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (i) => const Icon(Icons.star, color: Colors.amber, size: 16)),
                ),
              ),
              ListTile(
                leading: const CircleAvatar(backgroundImage: AssetImage("assets/images/user2.png")),
                title: Text("Sarah Smith", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                subtitle: Text("Good value for the price.", style: GoogleFonts.poppins()),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(4, (i) => const Icon(Icons.star, color: Colors.amber, size: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
