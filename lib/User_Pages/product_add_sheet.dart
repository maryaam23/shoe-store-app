import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'product_page.dart';
import '../firestore_service.dart'; // ✅ Import Firestore service
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductAddSheet extends StatefulWidget {
  final Product product;

  const ProductAddSheet({super.key, required this.product});

  @override
  State<ProductAddSheet> createState() => _ProductAddSheetState();
}

class _ProductAddSheetState extends State<ProductAddSheet> {
  int? selectedSize;
  Color? selectedColor;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 16,
        left: 16,
        right: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🧱 Small handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 🏷️ Product name
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          // 🎨 Color selection
          if (product.colors != null && product.colors!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Choose Color:"),
                Wrap(
                  spacing: 8,
                  children: product.colors!.map((color) {
                    final isSelected = selectedColor == color;
                    return GestureDetector(
                      onTap: () => setState(() => selectedColor = color),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.black : Colors.grey,
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),

          const SizedBox(height: 16),

          // 👟 Size selection
          if (product.sizes != null && product.sizes!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Choose Size:"),
                Wrap(
                  spacing: 8,
                  children: product.sizes!.map((size) {
                    final isSelected = selectedSize == size;
                    return ChoiceChip(
                      label: Text(size.toString()),
                      selected: isSelected,
                      onSelected: (_) => setState(() => selectedSize = size),
                      selectedColor: Colors.black,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),

          const SizedBox(height: 24),

          // ✅ Add to cart button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                if (selectedSize == null || selectedColor == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please select size and color first"),
                    ),
                  );
                  return;
                }

                await FirestoreService.addToCart(
                  product,
                  size: selectedSize!,
                  color: selectedColor!,
                );

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Added to cart successfully!"),
                  ),
                );
              },
              child: const Text(
                "Add to Cart",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
