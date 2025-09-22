import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_detailes_page.dart';
// Product Model
class Product {
  final String id;
  final String name;
  final String image;
  final double price;
  final String category;
  final String? brand;
  final String? clothesType;
  final List<int>? sizes;
  final List<Color>? colors;

  Product({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.category,
    this.brand,
    this.clothesType,
    this.sizes,
    this.colors,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Clean strings (remove extra quotes if present)
    String cleanString(String? s) {
      if (s == null) return '';
      return s.replaceAll('"', '').trim();
    }

    // Clean colors
    List<Color>? parseColors(List<dynamic>? list) {
      if (list == null) return null;
      return list.map((c) {
        try {
          return Color(int.parse(c.toString().replaceAll('"', '').replaceFirst('#', '0xff')));
        } catch (_) {
          return Colors.black;
        }
      }).toList();
    }

    return Product(
      id: doc.id,
      name: cleanString(data['name']),
      image: cleanString(data['image']).isNotEmpty
          ? cleanString(data['image'])
          : 'https://via.placeholder.com/150', // placeholder image
      price: (data['price'] ?? 0).toDouble(),
      category: cleanString(data['category']),
      brand: cleanString(data['brand']).isNotEmpty ? cleanString(data['brand']) : null,
      clothesType: cleanString(data['clothesType']).isNotEmpty
          ? cleanString(data['clothesType'])
          : null,
      sizes: data['sizes'] != null ? List<int>.from(data['sizes']) : null,
      colors: parseColors(data['colors']),
    );
  }
}

// Product Page Widget
class ProductPage extends StatelessWidget {
  final String selectedCategoryName;

  const ProductPage({super.key, required this.selectedCategoryName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedCategoryName),
        backgroundColor: Colors.deepOrange,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .snapshots(), // fetch all products
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          List<Product> products = snapshot.data!.docs
              .map((doc) => Product.fromFirestore(doc))
              .where((p) =>
                  p.category.toLowerCase() ==
                  selectedCategoryName.toLowerCase()) // filter here
              .toList();

          if (products.isEmpty) return const Center(child: Text("No products in this category."));

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.7,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ProductDetailPage(product: product)));
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: product.image.startsWith('http')
                          ? Image.network(
                              product.image,
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              product.image,
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                    ),
                    const SizedBox(height: 8),
                    Text(product.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text("\$${product.price.toStringAsFixed(2)}",
                        style: const TextStyle(color: Colors.deepOrange)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
