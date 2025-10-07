import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'product_page.dart';
import '../firestore_service.dart'; // ✅ Import Firestore service
import 'package:cloud_firestore/cloud_firestore.dart';

// ========================
// Product Detail Page
// ========================
class ProductDetailPage extends StatefulWidget {
  final Product product;
  final bool isGuest; // ✅ Added isGuest

  const ProductDetailPage({
    super.key,
    required this.product,
    this.isGuest = false, // default to false if not provided
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int selectedSize = 0;
  Color selectedColor = Colors.black;

  final user = FirebaseAuth.instance.currentUser;

  bool isInCart = false;
  bool isInWishlist = false;

  Stream<DocumentSnapshot<Map<String, dynamic>>>? cartItemStream;

  @override
  void initState() {
    super.initState();

    if (widget.product.sizes != null && widget.product.sizes!.isNotEmpty) {
      selectedSize = widget.product.sizes!.first;
    }
    if (widget.product.colors != null && widget.product.colors!.isNotEmpty) {
      selectedColor = widget.product.colors!.first;
    }

    // ✅ Initialize wishlist & cart status
    FirestoreService.isInCart(widget.product.id).then((value) {
      setState(() => isInCart = value);
    });
    FirestoreService.isInWishlist(widget.product.id).then((value) {
      setState(() => isInWishlist = value);
    });

    // ✅ Listen to the cart item in real-time
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
            if (data['color'] != null) selectedColor = Color(data['color']);
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
                          : Image.asset(
                            widget.product.image,
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
                widget.product.category,
                style: GoogleFonts.poppins(
                  fontSize: fontSize(16),
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: verticalSpace(8)),
              Text(
                "₪${widget.product.price.toStringAsFixed(2)}",
                style: GoogleFonts.poppins(
                  fontSize: fontSize(24),
                  fontWeight: FontWeight.w600,
                  color: Colors.deepOrange,
                ),
              ),

              // Brand & SKU
              if (widget.product.brand != null ||
                  widget.product.sku != null) ...[
                SizedBox(height: verticalSpace(12)),
                if (widget.product.brand != null)
                  Text(
                    "Brand: ${widget.product.brand!}",
                    style: GoogleFonts.poppins(
                      fontSize: fontSize(14),
                      color: Colors.black54,
                    ),
                  ),
                if (widget.product.sku != null)
                  Text(
                    "SKU: ${widget.product.sku!}",
                    style: GoogleFonts.poppins(
                      fontSize: fontSize(14),
                      color: Colors.black54,
                    ),
                  ),
              ],

              // Stock Info
              if (widget.product.quantity != null) ...[
                SizedBox(height: verticalSpace(8)),
                Text(
                  widget.product.inStock
                      ? "In Stock (${widget.product.quantity} available)"
                      : "Out of Stock",
                  style: GoogleFonts.poppins(
                    fontSize: fontSize(16),
                    fontWeight: FontWeight.w600,
                    color: widget.product.inStock ? Colors.green : Colors.red,
                  ),
                ),
              ],

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
              if (widget.product.sizes != null &&
                  widget.product.sizes!.isNotEmpty) ...[
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
                      widget.product.sizes!.map((size) {
                        final isSelected = selectedSize == size;
                        return ChoiceChip(
                          label: Text(
                            size.toString(),
                            style: GoogleFonts.poppins(
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                              color: isSelected ? Colors.white : Colors.black87,
                              fontSize: fontSize(14),
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (_) async {
                            setState(() => selectedSize = size);
                            // Update Firestore if in cart
                            if (isInCart) {
                              await FirestoreService.updateCartSize(
                                widget.product.id,
                                size,
                              );
                            }
                          },
                          selectedColor: Colors.deepOrange,
                          backgroundColor: Colors.grey.shade200,
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalSpace(14),
                            vertical: verticalSpace(8),
                          ),
                        );
                      }).toList(),
                ),
              ],

              // Colors
              if (widget.product.colors != null &&
                  widget.product.colors!.isNotEmpty) ...[
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
                      widget.product.colors!.map((color) {
                        final isSelected = selectedColor == color;
                        return GestureDetector(
                          onTap: () async {
                            setState(() => selectedColor = color);
                            if (isInCart) {
                              await FirestoreService.updateCartColor(
                                widget.product.id,
                                color,
                              );
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: horizontalSpace(12)),
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
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ],

              SizedBox(height: verticalSpace(40)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ❤️ Wishlist Button
                  // ❤️ Wishlist Button
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
                        // 🚫 Prevent guest from adding to wishlist
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

                        // ❤️ Toggle wishlist state
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

                  // 🛒 Add to Cart Button
                  
                  ElevatedButton(
                    onPressed:
                        widget.product.inStock
                            ? () async {
                              // 🚫 Prevent guest from adding to cart
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

                              // Add to cart by checking id, size, color
                              await FirestoreService.addOrUpdateCart(
                                widget.product,
                                size: selectedSize,
                                color: selectedColor,
                              );

                              // Update local button state
                              if (mounted) setState(() => isInCart = true);

                              // Show success message
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
                          isInCart ? Colors.green : Colors.deepOrange,
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
                      widget.product.inStock
                          ? (isInCart ? "In Cart" : "Add to Cart")
                          : "Out of Stock",
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
}
