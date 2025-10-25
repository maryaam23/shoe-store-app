import 'dart:io';
import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:shoe_store_app/User_Pages/product_page.dart';
import '../firestore_service.dart';
import 'product_detailes_page.dart';

Color _colorFromHex(String hexColor) {
  final buffer = StringBuffer();
  if (hexColor.length == 6 || hexColor.length == 7) buffer.write('ff');
  buffer.write(hexColor.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}

class ProductGrid extends StatelessWidget {
  final List<Product> products;
  final Set<String> cartIds;
  final Set<String> wishlistIds;
  final double w;
  final double h;
  final String role; // <-- add role

  const ProductGrid({
    super.key,
    required this.products,
    required this.cartIds,
    required this.wishlistIds,
    required this.w,
    required this.h,
    required this.role, // <-- pass role
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(w * 0.04),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
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

        final bool isOutOfStock =
            product.variants == null ||
            product.variants!.values.every(
              (sizeMap) => sizeMap.values.every((qty) => qty <= 0),
            );

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailPage(product: product),
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
                // Product Image with "Out of Stock"
                ClipRRect(
                  borderRadius: BorderRadius.circular(w * 0.01),
                  child: Stack(
                    children: [
                      product.image.startsWith('http')
                          ? Image.network(
                            product.image,
                            height: h * 0.2,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            color:
                                isOutOfStock
                                    ? Colors.black.withOpacity(0.5)
                                    : null,
                            colorBlendMode:
                                isOutOfStock ? BlendMode.darken : null,
                          )
                          : Image.file(
                            File(product.image),
                            height: h * 0.2,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            color:
                                isOutOfStock
                                    ? Colors.black.withOpacity(0.5)
                                    : null,
                            colorBlendMode:
                                isOutOfStock ? BlendMode.darken : null,
                          ),
                      if (isOutOfStock)
                        Positioned(
                          top: h * 0.015,
                          right: w * 0.02,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: w * 0.02,
                              vertical: h * 0.005,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(w * 0.02),
                            ),
                            child: Text(
                              "Out of Stock",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: w * 0.03,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: h * 0.01),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: w * 0.02),
                  child: Text(
                    product.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: w * 0.045,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: w * 0.02),
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
                    vertical: h * 0.005,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        iconSize: w * 0.06,
                        icon: Icon(
                          Icons.shopping_bag,
                          color: isInCart ? Colors.deepOrange : Colors.black,
                        ),
                        onPressed:
                            isOutOfStock
                                ? () {
                                  Flushbar(
                                    message:
                                        "This product is currently out of stock.",
                                    backgroundColor: Colors.redAccent,
                                    duration: Duration(seconds: 2),
                                    margin: EdgeInsets.all(w * 0.02),
                                    borderRadius: BorderRadius.circular(
                                      w * 0.02,
                                    ),
                                    flushbarPosition: FlushbarPosition.TOP,
                                  ).show(context);
                                }
                                : () {
                                  _showSizeColorModal(context, product);
                                },
                      ),
                      SizedBox(width: w * 0.04),
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          iconSize: w * 0.06,
                          icon: Icon(
                            isInWishlist
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color:
                                isInWishlist
                                    ? Color.fromARGB(255, 255, 17, 0)
                                    : Colors.black,
                          ),
                          onPressed:
                              role == 'admin'
                                  ? null // Admin can't tap: disabled button
                                  : () async {
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
  }

  void _showSizeColorModal(BuildContext outerContext, Product product) {
    showModalBottomSheet(
      context: outerContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        double w = MediaQuery.of(modalContext).size.width;
        double h = MediaQuery.of(modalContext).size.height;

        /// ✅ Helper: find first color and size that have stock > 0
        String? findFirstAvailableColor() {
          for (var color in product.variants!.keys) {
            var sizeMap = product.variants![color]!;
            if (sizeMap.values.any((qty) => qty > 0)) {
              return color;
            }
          }
          return null;
        }

        String? findFirstAvailableSize(String color) {
          var sizeMap = product.variants![color]!;
          for (var entry in sizeMap.entries) {
            if (entry.value > 0) return entry.key;
          }
          return null;
        }

        String? selectedColorHex = findFirstAvailableColor();
        String? selectedSize =
            selectedColorHex != null
                ? findFirstAvailableSize(selectedColorHex)
                : null;

        return StatefulBuilder(
          builder: (context, setModalState) {
            final colors = product.variants!.keys.toList();
            final sizes =
                selectedColorHex != null
                    ? product.variants![selectedColorHex]!.keys.toList()
                    : <String>[];

            bool isColorOutOfStock(String color) {
              final sizeMap = product.variants![color]!;
              return sizeMap.values.every((qty) => qty <= 0);
            }

            return Padding(
              padding: EdgeInsets.only(
                left: w * 0.05,
                right: w * 0.05,
                top: h * 0.02,
                bottom:
                    MediaQuery.of(modalContext).viewInsets.bottom + h * 0.03,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "Choose Size & Color",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: w * 0.05,
                        ),
                      ),
                    ),
                    SizedBox(height: h * 0.025),

                    /// ---------- Size section ----------
                    Text(
                      "Size:",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: w * 0.04,
                      ),
                    ),
                    SizedBox(height: h * 0.01),

                    Wrap(
                      spacing: w * 0.02,
                      runSpacing: h * 0.01,
                      children:
                          sizes.map((size) {
                            final availableQty =
                                selectedColorHex != null
                                    ? product
                                            .variants![selectedColorHex]![size] ??
                                        0
                                    : 0;

                            final bool isOutOfStock = availableQty <= 0;

                            return ChoiceChip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    size,
                                    style: TextStyle(
                                      fontSize: w * 0.035,
                                      decoration:
                                          isOutOfStock
                                              ? TextDecoration.lineThrough
                                              : null,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    "Qty: $availableQty",
                                    style: TextStyle(
                                      fontSize: w * 0.03,
                                      color:
                                          isOutOfStock
                                              ? Colors.grey.shade600
                                              : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              selected: selectedSize == size,
                              onSelected:
                                  isOutOfStock
                                      ? null
                                      : (_) => setModalState(
                                        () => selectedSize = size,
                                      ),
                              selectedColor: Colors.deepOrange.withOpacity(0.8),
                              backgroundColor:
                                  isOutOfStock
                                      ? Colors.grey.shade300
                                      : Colors.grey.shade200,
                            );
                          }).toList(),
                    ),

                    SizedBox(height: h * 0.035),

                    /// ---------- Color section ----------
                    Text(
                      "Color:",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: w * 0.04,
                      ),
                    ),
                    SizedBox(height: h * 0.01),

                    Wrap(
                      spacing: w * 0.03,
                      runSpacing: h * 0.01,
                      children:
                          colors.map((color) {
                            final bool colorOut = isColorOutOfStock(color);

                            return GestureDetector(
                              onTap:
                                  colorOut
                                      ? null
                                      : () {
                                        setModalState(() {
                                          selectedColorHex = color;
                                          selectedSize = findFirstAvailableSize(
                                            color,
                                          );
                                        });
                                      },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color:
                                            selectedColorHex == color
                                                ? Colors.deepOrange
                                                : Colors.grey,
                                        width: w * 0.007,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      backgroundColor: _colorFromHex(color),
                                      radius: w * 0.045,
                                    ),
                                  ),
                                  if (colorOut)
                                    Container(
                                      width: w * 0.09,
                                      height: w * 0.09,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.5),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.block,
                                        color: Colors.redAccent,
                                        size: w * 0.045,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                    ),

                    SizedBox(height: h * 0.05),

                    /// ---------- Add to Cart ----------
                    SizedBox(
                      width: double.infinity,
                      height: h * 0.06,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(w * 0.03),
                          ),
                        ),
                        icon: Icon(
                          Icons.shopping_cart_outlined,
                          color: Colors.white,
                          size: w * 0.06,
                        ),
                        label: Text(
                          "Add to Cart",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: w * 0.04,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed:
                            role == 'admin'
                                ? null // Admin can't tap: disabled button
                                : () async {
                                  final availableQty =
                                      selectedColorHex != null &&
                                              selectedSize != null
                                          ? product
                                                  .variants![selectedColorHex]![selectedSize] ??
                                              0
                                          : 0;

                                  if (selectedColorHex == null ||
                                      selectedSize == null ||
                                      availableQty <= 0) {
                                    Flushbar(
                                      message:
                                          "Please choose a valid size and color that are in stock.",
                                      backgroundColor: Colors.redAccent,
                                      duration: const Duration(seconds: 2),
                                      margin: EdgeInsets.all(w * 0.02),
                                      borderRadius: BorderRadius.circular(
                                        w * 0.02,
                                      ),
                                      flushbarPosition: FlushbarPosition.TOP,
                                    ).show(outerContext);
                                    return;
                                  }

                                  await FirestoreService.addOrUpdateCart(
                                    product,
                                    size: int.tryParse(selectedSize!) ?? 0,
                                    color: _colorFromHex(selectedColorHex!),
                                  );

                                  Navigator.pop(modalContext);

                                  Flushbar(
                                    message: "Product added to cart!",
                                    backgroundColor: Colors.green,
                                    duration: const Duration(seconds: 2),
                                    margin: EdgeInsets.all(w * 0.02),
                                    borderRadius: BorderRadius.circular(
                                      w * 0.02,
                                    ),
                                    flushbarPosition: FlushbarPosition.TOP,
                                    icon: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                    ),
                                  ).show(outerContext);
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
  }
}
