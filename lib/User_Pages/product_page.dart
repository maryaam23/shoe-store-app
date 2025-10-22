import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shoe_store_app/User_Pages/product_grid.dart';
import '../firestore_service.dart';
import 'package:another_flushbar/flushbar.dart';
import 'product_detailes_page.dart';

// ========================
// Product Model
// ========================
class Product {
  final String id;
  final String name;
  final String image;
  final double price;
  final String category;
  final String? brand;
  final String? clothesType;
  final String? description;
  final String? sku;
  final bool inStock;
  final Map<String, Map<String, int>>? variants; // colorHex → { size: qty }
  // ✅ new

  Product({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.category,
    this.brand,
    this.clothesType,
    this.description,
    this.sku,
    this.inStock = true,
    this.variants,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    String cleanString(dynamic s) {
      if (s == null) return '';
      return s.toString().replaceAll(RegExp(r'^"+|"+$'), '').trim();
    }

    // Parse variants as Map<String, Map<String, int>>
    Map<String, Map<String, int>>? parseVariants(Map<String, dynamic>? map) {
      if (map == null) return null;
      final result = <String, Map<String, int>>{};
      map.forEach((colorKey, sizesMap) {
        final sizeMap = <String, int>{};
        if (sizesMap is Map) {
          sizesMap.forEach((size, qty) {
            final sizeStr = size.toString();
            final qtyInt =
                (qty is int) ? qty : int.tryParse(qty.toString()) ?? 0;
            sizeMap[sizeStr] = qtyInt;
          });
        }
        result[colorKey.toString()] = sizeMap;
      });
      return result;
    }

    return Product(
      id: doc.id,
      name: cleanString(data['name']),
      image:
          cleanString(data['image']).isNotEmpty
              ? cleanString(data['image'])
              : 'https://via.placeholder.com/150',
      price: (data['price'] ?? 0).toDouble(),
      category: cleanString(data['category']),
      brand:
          cleanString(data['brand']).isNotEmpty
              ? cleanString(data['brand'])
              : null,
      clothesType:
          cleanString(data['clothesType']).isNotEmpty
              ? cleanString(data['clothesType'])
              : null,
      description: cleanString(data['description']),
      sku: cleanString(data['sku']),
      inStock: data['inStock'] ?? true,
      variants: parseVariants(data['variants'] as Map<String, dynamic>?),
    );
  }
}

// ========================
// Product Page (Grid View with Cart & Wishlist)
// ========================
class ProductPage extends StatefulWidget {
  final String selectedFilterName;
  final String filterType; // "category" or "brand"

  const ProductPage({
    super.key,
    required this.selectedFilterName,
    required this.filterType,
  });

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  late Stream<QuerySnapshot> cartStream;
  late Stream<QuerySnapshot> wishlistStream;

  @override
  void initState() {
    super.initState();
    cartStream = FirestoreService.getCart();
    wishlistStream = FirestoreService.getWishlist();
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          " ${widget.selectedFilterName}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),

        backgroundColor: const Color(0xFFF7F5F5),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('Nproducts')
                .where(
                  'visible',
                  isEqualTo: true,
                ) // ✅ Show only visible products
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          List<Product> products =
              snapshot.data!.docs
                  .map((doc) => Product.fromFirestore(doc))
                  .toList();

          // Filter products
          products =
              products.where((p) {
                if (widget.filterType == "category") {
                  return p.category.toLowerCase() ==
                      widget.selectedFilterName.toLowerCase();
                } else if (widget.filterType == "brand") {
                  return p.brand?.toLowerCase() ==
                      widget.selectedFilterName.toLowerCase();
                }
                return false;
              }).toList();

          if (products.isEmpty)
            return Center(
              child: Text("No products found in this ${widget.filterType}."),
            );

          return StreamBuilder<QuerySnapshot>(
            stream: wishlistStream,
            builder: (context, wishlistSnap) {
              final wishlistIds =
                  wishlistSnap.hasData
                      ? wishlistSnap.data!.docs.map((d) => d.id).toSet()
                      : <String>{};

              return StreamBuilder<QuerySnapshot>(
                stream: cartStream,
                builder: (context, cartSnap) {
                  final cartIds =
                      cartSnap.hasData
                          ? cartSnap.data!.docs.map((d) => d.id).toSet()
                          : <String>{};

                  return ProductGrid(
                    products: products,
                    cartIds: cartIds,
                    wishlistIds: wishlistIds,
                    w: w,
                    h: h,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
