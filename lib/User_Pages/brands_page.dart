import 'package:flutter/material.dart';
import 'product_page.dart';

class BrandsBar extends StatelessWidget {
  const BrandsBar({super.key});

  final List<Map<String, String>> brands = const [
    {"name": "Nike", "image": "assets/nike.png"},
    {"name": "Adidas", "image": "assets/adidas.png"},
    {"name": "Puma", "image": "assets/puma.png"},
    {"name": "Reebok", "image": "assets/reebok.png"},
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
    return SizedBox(
      height: 130, // adjust as needed
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: brands.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final brand = brands[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductPage(
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: Image.asset(
                      brand["image"]!,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  brand["name"]!,
                  style: const TextStyle(
                    fontSize: 12,
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
