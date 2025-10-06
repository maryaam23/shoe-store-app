import 'package:flutter/material.dart';
import 'product_page.dart';

class BrandsBar extends StatelessWidget {
  const BrandsBar({super.key});

  final List<Map<String, String>> brands = const [
    {"name": "Nike", "image": "assets/nike.png"},
    {"name": "Adidas", "image": "assets/adidas.png"},
    {"name": "Puma", "image": "assets/puma.png"},
    {"name": "Reebok", "image": "assets/reebok.png"},
    {"name": "Columbia", "image": "assets/columbia.png"},
    {"name": "New Balance", "image": "assets/new_balance.png"},
    {"name": "Converse", "image": "assets/converse.png"},
    {"name": "Under Armour", "image": "assets/under_armour.png"},
    {"name": "The North Face", "image": "assets/north_face.png"},
    {"name": "Skechers", "image": "assets/skechers.png"},
    {"name": "Roberto Vino", "image": "assets/roberto_vino.png"},
    {"name": "Lee Cooper", "image": "assets/lee_cooper.png"},
    {"name": "Le Coq", "image": "assets/le_coq.png"},
    {"name": "Timberland", "image": "assets/timberland.png"},
    {"name": "Nautica", "image": "assets/nautica.png"},
  ];

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return SizedBox(
      height: h * 0.18, // dynamic height (~18% of screen height)
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.01),
        itemCount: brands.length,
        separatorBuilder: (_, __) => SizedBox(width: w * 0.04),
        itemBuilder: (context, index) {
          final brand = brands[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => ProductPage(
                        selectedFilterName: brand["name"]!,
                        filterType: "brand",
                      ),
                ),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(w * 0.02),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox(
                    width: w * 0.13, // responsive circle size
                    height: w * 0.13,
                    child: Image.asset(brand["image"]!, fit: BoxFit.contain),
                  ),
                ),
                SizedBox(height: h * 0.008),
                Text(
                  brand["name"]!,
                  style: TextStyle(
                    fontSize: w * 0.03, // responsive text size
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
