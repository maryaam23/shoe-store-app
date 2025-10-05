import 'package:flutter/material.dart';
import '../firestore_service.dart';
import 'product_detailes_page.dart';
import 'package:another_flushbar/flushbar.dart';

class ProductCard extends StatelessWidget {
  final BuildContext parentContext;
  final double w;
  final double h;
  final dynamic product;
  final Set<String> cartIds;
  final Set<String> wishlistIds;

  const ProductCard({
    super.key,
    required this.parentContext,
    required this.w,
    required this.h,
    required this.product,
    required this.cartIds,
    required this.wishlistIds,
  });

  @override
  Widget build(BuildContext context) {
    final isInCart = cartIds.contains(product.id);
    final isInWishlist = wishlistIds.contains(product.id);

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
            ClipRRect(
              borderRadius: BorderRadius.circular(w * 0.01),
              child: product.image.startsWith('http')
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
                "\$${product.price.toStringAsFixed(2)}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: w * 0.04,
                  color: Colors.deepOrange,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: w * 0.02, vertical: 8),
              child: Row(
                children: [
                  // 🛒 Add to Cart
                  Container(
                    width: w * 0.12,
                    height: h * 0.05,
                    decoration: BoxDecoration(
                      color: isInCart ? Colors.green : Colors.deepOrange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: w * 0.06,
                      icon: const Icon(Icons.add_shopping_cart_outlined,
                          color: Colors.white),
                      onPressed: () => _showAddToCartModal(context),
                    ),
                  ),
                  SizedBox(width: w * 0.04),
                  // ❤️ Wishlist
                  Container(
                    width: w * 0.12,
                    height: h * 0.05,
                    decoration: BoxDecoration(
                      color: isInWishlist ? Colors.pink : Colors.deepOrange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: w * 0.055,
                      icon: const Icon(Icons.favorite, color: Colors.white),
                      onPressed: () async {
                        if (isInWishlist) {
                          await FirestoreService.removeFromWishlist(product.id);
                        } else {
                          await FirestoreService.addToWishlist(product);
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
  }

  void _showAddToCartModal(BuildContext context) {
    final outerContext = parentContext;

    showModalBottomSheet(
      context: outerContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        int? selectedSize;
        Color? selectedColor;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: w * 0.05,
                right: w * 0.05,
                top: h * 0.02,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + h * 0.03,
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
                    SizedBox(height: h * 0.02),
                    Text("Size:", style: TextStyle(fontWeight: FontWeight.w600, fontSize: w * 0.04)),
                    SizedBox(height: h * 0.01),
                    Wrap(
                      spacing: w * 0.02,
                      runSpacing: h * 0.01,
                      children: (product.sizes ?? []).map((size) {
                        return ChoiceChip(
                          label: Text(size.toString(), style: TextStyle(fontSize: w * 0.035)),
                          selected: selectedSize == size,
                          onSelected: (_) => setModalState(() => selectedSize = size),
                          selectedColor: Colors.deepOrange.withOpacity(0.8),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: h * 0.025),
                    Text("Color:", style: TextStyle(fontWeight: FontWeight.w600, fontSize: w * 0.04)),
                    SizedBox(height: h * 0.01),
                    Wrap(
                      spacing: w * 0.03,
                      runSpacing: h * 0.01,
                      children: (product.colors ?? []).map((color) {
                        return GestureDetector(
                          onTap: () => setModalState(() => selectedColor = color),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selectedColor == color ? Colors.deepOrange : Colors.grey,
                                width: w * 0.007,
                              ),
                            ),
                            child: CircleAvatar(
                              backgroundColor: color,
                              radius: w * 0.045,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: h * 0.04),
                    SizedBox(
                      width: double.infinity,
                      height: h * 0.06,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(w * 0.03)),
                        ),
                        icon: Icon(Icons.shopping_cart_outlined, color: Colors.white, size: w * 0.06),
                        label: Text("Add to Cart", style: TextStyle(color: Colors.white, fontSize: w * 0.04, fontWeight: FontWeight.w600)),
                        onPressed: () async {
                          if (selectedSize == null || selectedColor == null) {
                            Flushbar(
                              message: "Please choose size and color before adding.",
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 2),
                              margin: const EdgeInsets.all(8),
                              borderRadius: BorderRadius.circular(12),
                              flushbarPosition: FlushbarPosition.TOP,
                            ).show(outerContext);
                            return;
                          }
                          await FirestoreService.addOrUpdateCart(product, size: selectedSize!, color: selectedColor!);
                          Navigator.pop(modalContext);
                          Flushbar(
                            message: "Product added to cart!",
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 2),
                            margin: const EdgeInsets.all(8),
                            borderRadius: BorderRadius.circular(12),
                            flushbarPosition: FlushbarPosition.TOP,
                            icon: const Icon(Icons.check, color: Colors.white),
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
