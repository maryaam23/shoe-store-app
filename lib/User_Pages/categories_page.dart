import 'package:flutter/material.dart';
import 'product_page.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  final List<Map<String, String>> categories = const [
    {"name": "Shoes", "image": "assets/shoes.png"},
    {"name": "Clothes", "image": "assets/shirt.png"},
    {"name": "Accessories", "image": "assets/hat.png"},
  ];

  @override
  Widget build(BuildContext context) {
    // Get screen size
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Categories",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: w * 0.06,
          ),
        ),
        backgroundColor: const Color(0xFFF7F5F5),
        elevation: 0,
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(w * 0.04),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: h * 0.03,
          crossAxisSpacing: w * 0.04,
          childAspectRatio: w / (h * 0.9), // adjusts for screen
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => ProductPage(
                        selectedFilterName: category["name"] as String,
                        filterType: "category",
                      ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(w * 0.04),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: w * 0.015,
                    offset: Offset(0, h * 0.01),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: w * 0.35,
                    height: w * 0.35,
                    child: Image.asset(category["image"]!, fit: BoxFit.contain),
                  ),
                  SizedBox(height: h * 0.01),
                  Text(
                    category["name"] as String,
                    style: TextStyle(
                      fontSize: w * 0.05,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
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
