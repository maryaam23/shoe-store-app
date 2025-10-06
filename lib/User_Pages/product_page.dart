import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final List<int>? sizes;
  final List<Color>? colors;
  final String? description;
  final int? quantity;
  final String? sku;
  final bool inStock;

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
    this.description,
    this.quantity,
    this.sku,
    this.inStock = true,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    String cleanString(dynamic s) {
      if (s == null) return '';
      return s.toString().replaceAll(RegExp(r'^"+|"+$'), '').trim();
    }

    List<Color>? parseColors(List<dynamic>? list) {
      if (list == null) return null;
      return list.map((c) {
        try {
          return Color(
            int.parse(
              c.toString().replaceAll('"', '').replaceFirst('#', '0xff'),
            ),
          );
        } catch (_) {
          return Colors.black;
        }
      }).toList();
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
      sizes:
          data['sizes'] != null
              ? List<int>.from(
                data['sizes'].map(
                  (e) => e is int ? e : int.tryParse(e.toString()) ?? 0,
                ),
              )
              : null,
      colors: parseColors(data['colors']),
      description: cleanString(data['description']),
      quantity:
          data['quantity'] != null
              ? int.tryParse(data['quantity'].toString())
              : null,
      sku: cleanString(data['sku']),
      inStock: data['inStock'] ?? true,
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
        title: Text("${widget.filterType}: ${widget.selectedFilterName}"),
        backgroundColor: Colors.deepOrange,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.collection('Nproducts').snapshots(),
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

                  return GridView.builder(
                    padding: EdgeInsets.all(w * 0.04),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: h * 0.015,
                      crossAxisSpacing: w * 0.03,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final isInCart = cartIds.contains(product.id);
                      final isInWishlist = wishlistIds.contains(product.id);

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => ProductDetailPage(product: product),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(w * 0.01),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(w * 0.01),
                                child:
                                    product.image.startsWith('http')
                                        ? Image.network(
                                          product.image,
                                          height: h * 0.2,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        )
                                        : Image.asset(
                                          product.image,
                                          height: h * 0.2,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                              ),
                              SizedBox(height: h * 0.01),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: w * 0.02,
                                ),
                                child: Text(
                                  product.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: w * 0.045,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: w * 0.02,
                                ),
                                child: Text(
                                  "₪${product.price.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: w * 0.04,
                                    color: Colors.deepOrange,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: w * 0.02,
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    // Cart Button
                                    Container(
                                      width: w * 0.12,
                                      height: h * 0.05,
                                      decoration: BoxDecoration(
                                        color:
                                            isInCart
                                                ? Colors.green
                                                : Colors.deepOrange,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        iconSize: w * 0.06,
                                        icon: const Icon(
                                          Icons.add_shopping_cart_outlined,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          final outerContext = context;

                                          showModalBottomSheet(
                                            context: outerContext,
                                            isScrollControlled: true,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                    top: Radius.circular(20),
                                                  ),
                                            ),
                                            builder: (modalContext) {
                                              int? selectedSize;
                                              Color? selectedColor;

                                              double w =
                                                  MediaQuery.of(
                                                    modalContext,
                                                  ).size.width;
                                              double h =
                                                  MediaQuery.of(
                                                    modalContext,
                                                  ).size.height;

                                              return StatefulBuilder(
                                                builder: (
                                                  context,
                                                  setModalState,
                                                ) {
                                                  return Padding(
                                                    padding: EdgeInsets.only(
                                                      left: w * 0.05,
                                                      right: w * 0.05,
                                                      top: h * 0.02,
                                                      bottom:
                                                          MediaQuery.of(
                                                            modalContext,
                                                          ).viewInsets.bottom +
                                                          h * 0.03,
                                                    ),
                                                    child: SingleChildScrollView(
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Center(
                                                            child: Text(
                                                              "Choose Size & Color",
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize:
                                                                    w * 0.05,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: h * 0.02,
                                                          ),
                                                          Text(
                                                            "Size:",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize:
                                                                  w * 0.04,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: h * 0.01,
                                                          ),
                                                          Wrap(
                                                            spacing: w * 0.02,
                                                            runSpacing:
                                                                h * 0.01,
                                                            children:
                                                                (product.sizes ?? []).map((
                                                                  size,
                                                                ) {
                                                                  return ChoiceChip(
                                                                    label: Text(
                                                                      size.toString(),
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            w *
                                                                            0.035,
                                                                      ),
                                                                    ),
                                                                    selected:
                                                                        selectedSize ==
                                                                        size,
                                                                    onSelected:
                                                                        (
                                                                          _,
                                                                        ) => setModalState(
                                                                          () =>
                                                                              selectedSize =
                                                                                  size,
                                                                        ),
                                                                    selectedColor: Colors
                                                                        .deepOrange
                                                                        .withOpacity(
                                                                          0.8,
                                                                        ),
                                                                  );
                                                                }).toList(),
                                                          ),
                                                          SizedBox(
                                                            height: h * 0.025,
                                                          ),
                                                          Text(
                                                            "Color:",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize:
                                                                  w * 0.04,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: h * 0.01,
                                                          ),
                                                          Wrap(
                                                            spacing: w * 0.03,
                                                            runSpacing:
                                                                h * 0.01,
                                                            children:
                                                                (product.colors ?? []).map((
                                                                  color,
                                                                ) {
                                                                  return GestureDetector(
                                                                    onTap:
                                                                        () => setModalState(
                                                                          () =>
                                                                              selectedColor =
                                                                                  color,
                                                                        ),
                                                                    child: Container(
                                                                      decoration: BoxDecoration(
                                                                        shape:
                                                                            BoxShape.circle,
                                                                        border: Border.all(
                                                                          color:
                                                                              selectedColor ==
                                                                                      color
                                                                                  ? Colors.deepOrange
                                                                                  : Colors.grey,
                                                                          width:
                                                                              w *
                                                                              0.007,
                                                                        ),
                                                                      ),
                                                                      child: CircleAvatar(
                                                                        backgroundColor:
                                                                            color,
                                                                        radius:
                                                                            w *
                                                                            0.045,
                                                                      ),
                                                                    ),
                                                                  );
                                                                }).toList(),
                                                          ),
                                                          SizedBox(
                                                            height: h * 0.04,
                                                          ),
                                                          SizedBox(
                                                            width:
                                                                double.infinity,
                                                            height: h * 0.06,
                                                            child: ElevatedButton.icon(
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                    Colors
                                                                        .deepOrange,
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        w * 0.03,
                                                                      ),
                                                                ),
                                                              ),
                                                              icon: Icon(
                                                                Icons
                                                                    .shopping_cart_outlined,
                                                                color:
                                                                    Colors
                                                                        .white,
                                                                size: w * 0.06,
                                                              ),
                                                              label: Text(
                                                                "Add to Cart",
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                  fontSize:
                                                                      w * 0.04,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                              onPressed: () async {
                                                                if (selectedSize ==
                                                                        null ||
                                                                    selectedColor ==
                                                                        null) {
                                                                  Flushbar(
                                                                    message:
                                                                        "Please choose size and color before adding.",
                                                                    backgroundColor:
                                                                        const Color.fromARGB(
                                                                          255,
                                                                          251,
                                                                          54,
                                                                          54,
                                                                        ),
                                                                    duration:
                                                                        const Duration(
                                                                          seconds:
                                                                              2,
                                                                        ),
                                                                    margin:
                                                                        const EdgeInsets.all(
                                                                          8,
                                                                        ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          12,
                                                                        ),
                                                                    flushbarPosition:
                                                                        FlushbarPosition
                                                                            .TOP,
                                                                  ).show(
                                                                    outerContext,
                                                                  );
                                                                  return;
                                                                }

                                                                await FirestoreService.addOrUpdateCart(
                                                                  product,
                                                                  size:
                                                                      selectedSize!,
                                                                  color:
                                                                      selectedColor!,
                                                                );

                                                                Navigator.pop(
                                                                  modalContext,
                                                                );

                                                                Flushbar(
                                                                  message:
                                                                      "Product added to cart!",
                                                                  backgroundColor:
                                                                      Colors
                                                                          .green,
                                                                  duration:
                                                                      const Duration(
                                                                        seconds:
                                                                            2,
                                                                      ),
                                                                  margin:
                                                                      const EdgeInsets.all(
                                                                        8,
                                                                      ),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        12,
                                                                      ),
                                                                  flushbarPosition:
                                                                      FlushbarPosition
                                                                          .TOP,
                                                                  icon: const Icon(
                                                                    Icons.check,
                                                                    color:
                                                                        Colors
                                                                            .white,
                                                                  ),
                                                                ).show(
                                                                  outerContext,
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    SizedBox(width: w * 0.04),
                                    // Wishlist Button
                                    Container(
                                      width: w * 0.12,
                                      height: h * 0.05,
                                      decoration: BoxDecoration(
                                        color:
                                            isInWishlist
                                                ? Colors.pink
                                                : Colors.deepOrange,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        iconSize: w * 0.055,
                                        icon: const Icon(
                                          Icons.favorite,
                                          color: Colors.white,
                                        ),
                                        onPressed: () async {
                                          if (isInWishlist) {
                                            await FirestoreService.removeFromWishlist(
                                              product.id,
                                            );
                                          } else {
                                            await FirestoreService.addToWishlist(
                                              product,
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
