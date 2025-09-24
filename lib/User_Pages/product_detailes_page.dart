import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'product_page.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int selectedSize = 0;
  Color selectedColor = Colors.black;

  @override
  void initState() {
    super.initState();
    if (widget.product.sizes != null && widget.product.sizes!.isNotEmpty) {
      selectedSize = widget.product.sizes!.first;
    }
    if (widget.product.colors != null && widget.product.colors!.isNotEmpty) {
      selectedColor = widget.product.colors!.first;
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
          icon: Icon(Icons.arrow_back, color: Colors.black87, size: fontSize(24)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Product Details",
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600, color: Colors.black87, fontSize: fontSize(20)),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(horizontalSpace(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(horizontalSpace(20)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.shade300, blurRadius: 10, offset: const Offset(0, 5)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(horizontalSpace(20)),
                  child: widget.product.image.startsWith('http')
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
              Text(widget.product.name,
                  style: GoogleFonts.poppins(
                      fontSize: fontSize(26),
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
              SizedBox(height: verticalSpace(4)),
              Text(widget.product.category,
                  style: GoogleFonts.poppins(
                      fontSize: fontSize(16), color: Colors.grey[600])),
              SizedBox(height: verticalSpace(8)),
              Text("\$${widget.product.price.toStringAsFixed(2)}",
                  style: GoogleFonts.poppins(
                      fontSize: fontSize(24),
                      fontWeight: FontWeight.w600,
                      color: Colors.deepOrange)),

              // Sizes
              if (widget.product.sizes != null && widget.product.sizes!.isNotEmpty) ...[
                SizedBox(height: verticalSpace(30)),
                Text("Select Size",
                    style: GoogleFonts.poppins(
                        fontSize: fontSize(18), fontWeight: FontWeight.w600)),
                SizedBox(height: verticalSpace(12)),
                Wrap(
                  spacing: horizontalSpace(12),
                  children: widget.product.sizes!.map((size) {
                    final isSelected = selectedSize == size;
                    return ChoiceChip(
                      label: Text(size.toString(),
                          style: GoogleFonts.poppins(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.white : Colors.black87,
                              fontSize: fontSize(14))),
                      selected: isSelected,
                      onSelected: (_) => setState(() => selectedSize = size),
                      selectedColor: Colors.deepOrange,
                      backgroundColor: Colors.grey.shade200,
                      padding: EdgeInsets.symmetric(
                          horizontal: horizontalSpace(14), vertical: verticalSpace(8)),
                    );
                  }).toList(),
                ),
              ],

              // Colors
              if (widget.product.colors != null && widget.product.colors!.isNotEmpty) ...[
                SizedBox(height: verticalSpace(30)),
                Text("Select Color",
                    style: GoogleFonts.poppins(
                        fontSize: fontSize(18), fontWeight: FontWeight.w600)),
                SizedBox(height: verticalSpace(12)),
                Row(
                  children: widget.product.colors!.map((color) {
                    final isSelected = selectedColor == color;
                    return GestureDetector(
                      onTap: () => setState(() => selectedColor = color),
                      child: Container(
                        margin: EdgeInsets.only(right: horizontalSpace(12)),
                        padding: EdgeInsets.all(horizontalSpace(3)),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: isSelected ? Colors.deepOrange : Colors.transparent,
                              width: 2),
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
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.shade300,
                            blurRadius: 8,
                            offset: const Offset(0, 4))
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(Icons.favorite_border,
                          color: Colors.deepOrange, size: fontSize(28)),
                      onPressed: () {},
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      padding: EdgeInsets.symmetric(
                          horizontal: horizontalSpace(50), vertical: verticalSpace(16)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(horizontalSpace(12))),
                      shadowColor: Colors.deepOrange.shade200,
                      elevation: 5,
                    ),
                    child: Text("Add to Cart",
                        style: GoogleFonts.poppins(
                            fontSize: fontSize(16),
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
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
