import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'product_page.dart';
import '../firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  final bool isGuest;

  const ProductDetailPage({
    super.key,
    required this.product,
    this.isGuest = false,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  String? selectedColor; // Hex string like "#f436ee"
  String? selectedSize;
  int availableQty = 0;

  final user = FirebaseAuth.instance.currentUser;

  bool isInCart = false;
  bool isInWishlist = false;

  Stream<DocumentSnapshot<Map<String, dynamic>>>? cartItemStream;

  @override
  void initState() {
    super.initState();

    // ✅ Initialize first color and size
    if (widget.product.variants != null &&
        widget.product.variants!.isNotEmpty) {
      selectedColor = widget.product.variants!.keys.first;
      selectedSize = widget.product.variants![selectedColor!]!.keys.first;
      availableQty =
          widget.product.variants![selectedColor!]![selectedSize!] ?? 0;
    }

    // ✅ Initialize wishlist & cart status
    FirestoreService.isInCart(widget.product.id).then((value) {
      setState(() => isInCart = value);
    });
    FirestoreService.isInWishlist(widget.product.id).then((value) {
      setState(() => isInWishlist = value);
    });

    // ✅ Listen to cart changes
    if (user != null) {
      cartItemStream =
          FirebaseFirestore.instance
              .collection("users")
              .doc(user!.uid)
              .collection("cart")
              .doc(widget.product.id)
              .snapshots();

      cartItemStream!.listen((snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          final data = snapshot.data()!;
          setState(() {
            if (data['size'] != null) selectedSize = data['size'];
            if (data['color'] != null) selectedColor = data['color'];

            // Update quantity if color & size exist
            if (selectedColor != null &&
                selectedSize != null &&
                widget.product.variants![selectedColor!]!.containsKey(
                  selectedSize!,
                )) {
              availableQty =
                  widget.product.variants![selectedColor!]![selectedSize!]!;
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaWidth = MediaQuery.of(context).size.width;
    final mediaHeight = MediaQuery.of(context).size.height;

    double fontSize(double size) => size * mediaWidth / 375;
    double verticalSpace(double size) => size * mediaHeight / 812;
    double horizontalSpace(double size) => size * mediaWidth / 375;

    final colors = widget.product.variants?.keys.toList() ?? [];
    final sizes =
        selectedColor != null
            ? widget.product.variants![selectedColor!]!.keys
                .map((e) => e.toString())
                .toList()
            : <String>[];

    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black87,
            size: fontSize(24),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Product Details",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: fontSize(20),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(horizontalSpace(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(horizontalSpace(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(horizontalSpace(20)),
                  child:
                      widget.product.image.startsWith('http')
                          ? Image.network(
                            widget.product.image,
                            height: mediaHeight * 0.3,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                          : Image.file(
                            File(widget.product.image), // <-- use File
                            height: mediaHeight * 0.3,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                ),
              ),
              SizedBox(height: verticalSpace(20)),

              // Name & Category
              Text(
                widget.product.name,
                style: GoogleFonts.poppins(
                  fontSize: fontSize(26),
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: verticalSpace(4)),
              Text(
                "Category: ${widget.product.category}",
                style: GoogleFonts.poppins(
                  fontSize: fontSize(16),
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: verticalSpace(8)),
              Text(
                "Price: ₪${widget.product.price.toStringAsFixed(2)}",
                style: GoogleFonts.poppins(
                  fontSize: fontSize(24),
                  fontWeight: FontWeight.w600,
                  color: Colors.deepOrange,
                ),
              ),

              // Brand & SKU
              if (widget.product.brand != null) ...[
                SizedBox(height: verticalSpace(12)),
                Text(
                  "Brand: ${widget.product.brand!}",
                  style: GoogleFonts.poppins(
                    fontSize: fontSize(14),
                    color: Colors.black54,
                  ),
                ),
              ],
              if (widget.product.sku != null) ...[
                Text(
                  "SKU: ${widget.product.sku!}",
                  style: GoogleFonts.poppins(
                    fontSize: fontSize(14),
                    color: Colors.black54,
                  ),
                ),
              ],

              // Stock Info
              SizedBox(height: verticalSpace(8)),
              Text(
                availableQty > 0
                    ? "In Stock ($availableQty available)"
                    : "Out of Stock",
                style: GoogleFonts.poppins(
                  fontSize: fontSize(16),
                  fontWeight: FontWeight.w600,
                  color: availableQty > 0 ? Colors.green : Colors.red,
                ),
              ),

              // Description
              if (widget.product.description != null &&
                  widget.product.description!.isNotEmpty) ...[
                SizedBox(height: verticalSpace(20)),
                Text(
                  "Description",
                  style: GoogleFonts.poppins(
                    fontSize: fontSize(18),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: verticalSpace(8)),
                Text(
                  widget.product.description!,
                  style: GoogleFonts.poppins(
                    fontSize: fontSize(14),
                    color: Colors.black87,
                  ),
                ),
              ],

              // Sizes
              // ✅ Sizes
              if (sizes.isNotEmpty) ...[
                SizedBox(height: verticalSpace(30)),
                Text(
                  "Select Size",
                  style: GoogleFonts.poppins(
                    fontSize: fontSize(18),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: verticalSpace(12)),
                Wrap(
                  spacing: horizontalSpace(12),
                  children:
                      sizes.map((size) {
                        final qty =
                            widget.product.variants![selectedColor!]![size] ??
                            0;
                        final isSelected = selectedSize == size;
                        final isDisabled = qty == 0;

                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Opacity(
                              opacity: isDisabled ? 0.4 : 1.0,
                              child: ChoiceChip(
                                label: Text(
                                  size,
                                  style: GoogleFonts.poppins(
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : Colors.black87,
                                    fontSize: fontSize(14),
                                  ),
                                ),
                                selected: isSelected,
                                onSelected:
                                    isDisabled
                                        ? null // disable if qty = 0
                                        : (_) {
                                          setState(() {
                                            selectedSize = size;
                                            availableQty =
                                                widget
                                                    .product
                                                    .variants![selectedColor!]![selectedSize!] ??
                                                0;
                                          });
                                        },
                                selectedColor: Colors.deepOrange,
                                backgroundColor: Colors.grey.shade200,
                                padding: EdgeInsets.symmetric(
                                  horizontal: horizontalSpace(14),
                                  vertical: verticalSpace(8),
                                ),
                              ),
                            ),
                            if (isDisabled)
                              const Positioned(
                                right: 0,
                                top: 0,
                                child: Icon(
                                  Icons.block,
                                  color: Colors.red,
                                  size: 18,
                                ),
                              ),
                          ],
                        );
                      }).toList(),
                ),
              ],

              // ✅ Colors
              if (colors.isNotEmpty) ...[
                SizedBox(height: verticalSpace(30)),
                Text(
                  "Select Color",
                  style: GoogleFonts.poppins(
                    fontSize: fontSize(18),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: verticalSpace(12)),
                Row(
                  children:
                      colors.map((colorHex) {
                        final color = _colorFromHex(colorHex);
                        final isSelected = selectedColor == colorHex;

                        // check if all sizes in this color have 0 qty
                        final allZero = widget
                            .product
                            .variants![colorHex]!
                            .values
                            .every((qty) => qty == 0);

                        return GestureDetector(
                          onTap:
                              allZero
                                  ? null
                                  : () {
                                    setState(() {
                                      selectedColor = colorHex;
                                      selectedSize =
                                          widget
                                              .product
                                              .variants![selectedColor!]!
                                              .keys
                                              .first;
                                      availableQty =
                                          widget
                                              .product
                                              .variants![selectedColor!]![selectedSize!] ??
                                          0;
                                    });
                                  },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                margin: EdgeInsets.only(
                                  right: horizontalSpace(12),
                                ),
                                padding: EdgeInsets.all(horizontalSpace(3)),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? Colors.deepOrange
                                            : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: CircleAvatar(
                                  backgroundColor: color,
                                  radius: horizontalSpace(20),
                                  child:
                                      allZero
                                          ? Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(
                                                0.7,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                          )
                                          : null,
                                ),
                              ),
                              if (allZero)
                                const Positioned(
                                  child: Icon(
                                    Icons.block,
                                    color: Colors.red,
                                    size: 22,
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ],

              

              SizedBox(height: verticalSpace(40)),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Wishlist Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        isInWishlist ? Icons.favorite : Icons.favorite_border,
                        color: isInWishlist ? Colors.pink : Colors.deepOrange,
                        size: fontSize(28),
                      ),
                      onPressed: () async {
                        if (widget.isGuest) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please login first"),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 2),
                            ),
                          );
                          return;
                        }

                        if (isInWishlist) {
                          await FirestoreService.removeFromWishlist(
                            widget.product.id,
                          );
                        } else {
                          await FirestoreService.addToWishlist(widget.product);
                        }

                        setState(() => isInWishlist = !isInWishlist);
                      },
                    ),
                  ),

                  // Add to Cart Button
                  ElevatedButton(
                    onPressed:
                        availableQty > 0
                            ? () async {
                              if (widget.isGuest) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Please login first"),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                return;
                              }

                              final int? sizeInt = int.tryParse(
                                selectedSize ?? '',
                              );

                              if (sizeInt == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Please select a valid size"),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                return;
                              }

                              if (selectedColor == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Please select a color"),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                return;
                              }

                              await FirestoreService.addOrUpdateCart(
                                widget.product,
                                size: sizeInt,
                                color: _colorFromHex(
                                  selectedColor ?? '#000000',
                                ),
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Product added to cart!"),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          availableQty > 0 ? Colors.deepOrange : Colors.grey,
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalSpace(50),
                        vertical: verticalSpace(16),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          horizontalSpace(12),
                        ),
                      ),
                      shadowColor: Colors.deepOrange.shade200,
                      elevation: 5,
                    ),
                    child: Text(
                      availableQty > 0 ? "Add to Cart" : "Out of Stock",
                      style: GoogleFonts.poppins(
                        fontSize: fontSize(16),
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Convert hex string to Color
  Color _colorFromHex(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
