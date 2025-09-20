import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'product_detailes_page.dart';

enum CategoryType { shoes, accessories, clothes }
enum ShoeBrand { nike, adidas, puma }
enum ClothesType { top, bottom, suit }

class Product {
  final String name;
  final String image;
  final double price;
  final CategoryType category;
  final ShoeBrand? brand;
  final ClothesType? clothesType;
  final List<int>? sizes;
  final List<Color>? colors;

  Product({
    required this.name,
    required this.image,
    required this.price,
    required this.category,
    this.brand,
    this.clothesType,
    this.sizes,
    this.colors,
  });
}

class ProductPage extends StatefulWidget {
  final String? selectedCategoryName; // From CategoriesPage
  const ProductPage({super.key, this.selectedCategoryName});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<Product> allProducts = [];
  List<Product> filteredProducts = [];
  CategoryType? selectedCategory;
  ShoeBrand? selectedBrand;
  ClothesType? selectedClothesType;

  @override
  void initState() {
    super.initState();

    allProducts = [
      Product(
        name: "Air Max 90",
        image: "assets/images/shoe1.png",
        price: 120,
        category: CategoryType.shoes,
        brand: ShoeBrand.nike,
        sizes: [38, 39, 40, 41, 42],
        colors: [Colors.black, Colors.red, Colors.blue],
      ),
      Product(
        name: "Adidas Runner",
        image: "assets/images/shoe2.png",
        price: 100,
        category: CategoryType.shoes,
        brand: ShoeBrand.adidas,
        sizes: [38, 39, 40, 41, 42],
        colors: [Colors.black, Colors.green],
      ),
      Product(
        name: "Formal Suit",
        image: "assets/images/suit.png",
        price: 200,
        category: CategoryType.clothes,
        clothesType: ClothesType.suit,
      ),
      Product(
        name: "Leather Belt",
        image: "assets/images/belt.png",
        price: 30,
        category: CategoryType.accessories,
      ),
    ];

    // If navigated from CategoriesPage
    if (widget.selectedCategoryName != null) {
      switch (widget.selectedCategoryName!.toLowerCase()) {
        case "shoes":
          selectedCategory = CategoryType.shoes;
          break;
        case "clothes":
          selectedCategory = CategoryType.clothes;
          break;
        case "accessories":
          selectedCategory = CategoryType.accessories;
          break;
      }
    }

    filteredProducts = List.from(allProducts);
    filterProducts();
  }

  void filterProducts() {
    filteredProducts = allProducts.where((product) {
      bool categoryMatch = selectedCategory == null || product.category == selectedCategory;

      bool brandMatch = true;
      if (selectedCategory == CategoryType.shoes && selectedBrand != null) {
        brandMatch = product.brand == selectedBrand;
      }

      bool clothesMatch = true;
      if (selectedCategory == CategoryType.clothes && selectedClothesType != null) {
        clothesMatch = product.clothesType == selectedClothesType;
      }

      return categoryMatch && brandMatch && clothesMatch;
    }).toList();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Products",
          style: TextStyle(color: Colors.black, fontSize: w * 0.05),
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.category, color: Colors.black),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          )
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text("Filter by Category",
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              title: const Text("All"),
              onTap: () {
                selectedCategory = null;
                selectedBrand = null;
                selectedClothesType = null;
                filterProducts();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Shoes"),
              onTap: () {
                selectedCategory = CategoryType.shoes;
                selectedBrand = null;
                selectedClothesType = null;
                filterProducts();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Clothes"),
              onTap: () {
                selectedCategory = CategoryType.clothes;
                selectedBrand = null;
                selectedClothesType = null;
                filterProducts();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Accessories"),
              onTap: () {
                selectedCategory = CategoryType.accessories;
                selectedBrand = null;
                selectedClothesType = null;
                filterProducts();
                Navigator.pop(context);
              },
            ),
            const Divider(height: 32),
            if (selectedCategory == CategoryType.shoes) ...[
              Text("Filter by Brand",
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              ListTile(
                title: const Text("Nike"),
                onTap: () {
                  selectedBrand = ShoeBrand.nike;
                  filterProducts();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("Adidas"),
                onTap: () {
                  selectedBrand = ShoeBrand.adidas;
                  filterProducts();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("Puma"),
                onTap: () {
                  selectedBrand = ShoeBrand.puma;
                  filterProducts();
                  Navigator.pop(context);
                },
              ),
            ],
            if (selectedCategory == CategoryType.clothes) ...[
              Text("Filter by Type",
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              ListTile(
                title: const Text("Top"),
                onTap: () {
                  selectedClothesType = ClothesType.top;
                  filterProducts();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("Bottom"),
                onTap: () {
                  selectedClothesType = ClothesType.bottom;
                  filterProducts();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("Suit"),
                onTap: () {
                  selectedClothesType = ClothesType.suit;
                  filterProducts();
                  Navigator.pop(context);
                },
              ),
            ],
          ],
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredProducts.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.65,
        ),
        itemBuilder: (context, index) {
          final product = filteredProducts[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProductDetailPage(product: product)),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.asset(product.image,
                          fit: BoxFit.cover, width: double.infinity),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.name,
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text("\$${product.price}",
                            style: GoogleFonts.poppins(
                                color: Colors.black, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Wishlist Icon
                            GestureDetector(
                              onTap: () {
                                // TODO: Add to wishlist logic
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey.shade300,
                                        blurRadius: 6,
                                        offset: const Offset(0, 3))
                                  ],
                                ),
                                child: const Icon(Icons.favorite_border,
                                    color: Colors.deepOrange, size: 20),
                              ),
                            ),
                            // Add to Cart Button
                            ElevatedButton(
                              onPressed: () {
                                // TODO: Add to cart logic
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrange,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                              child: const Icon(Icons.shopping_cart, size: 20),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
