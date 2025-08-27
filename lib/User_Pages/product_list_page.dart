import 'package:flutter/material.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  int _selectedIndex = 1;

  final List<String> filters = ["Size 8", "Size 9", "Black", "White"];

  final List<Map<String, String>> products = [
    {
      "name": "Air Max 90",
      "price": "\$120",
      "img":
          "https://lh3.googleusercontent.com/aida-public/AB6AXuDl5lGbOwfsOwPh3zDP82lxno-czEfKvQDpg93W8pPZw14--FnH4wMQUoglKd8lNXZB-n1sAIuFZf8g12LRqvLvnuRyDGudw0jwMZoVfawSwXgmLpUARAKAplnI32A09dAeNQlNOYAbyVStRZsnOq2pkuUjvgd8G3YxkVzvBKQ4_0OL5WophS1ZtTUEeUlcKJxXcwYNqO9ChD7skuUlz74b6O3eR-PwIMdkvJ_TEASV0z3DI_WQlc2AhteRXMMk3mevi5BG7IgzA3S1"
    },
    {
      "name": "Air Force 1",
      "price": "\$100",
      "img":
          "https://lh3.googleusercontent.com/aida-public/AB6AXuBLfFh8ELJm0x8e4EeHQrUmsICED-3aZKxFmEZKSvMSItQrRjweQSt8m4MEo0hvaOoNeDCSMulItEKjfq4KUOUyBvg1poK2_M9kuIiUSZcwOJOh8_9eA0UzKmqZqjhkkOjjgVsYvyPPEEmJZwIXWDGEIVqBbz6quYRQmOusWQgoEYcEYV4o082-HCqEeD4UCqRPelI5kgRDC_c6fqb3dWtHosu5knat1BoM1aY2xMMLZZLDSJ6kOxC-i23rhKWcWwsy1o0uVJaO52-c"
    },
    {
      "name": "Air Jordan 1",
      "price": "\$160",
      "img":
          "https://lh3.googleusercontent.com/aida-public/AB6AXuAsf3MU5QanQZ_2osGh8jeLR5N8VTYnNOJhrIuRcNLflT1T1CGH_hhZ1D-mCUAOx7b7xsZSARO3GX9wGnjcuLW5MtVV99daalvw5bVqrZ6_GGXvXIqhUWW7WsuPWH7yX2NDRrCg_XMFLhArLC8mNdPkfrHq7KZtZjPqNK5nb2ZjWgPN9_r6qKQQl7YZddgPgwc6FZ35gtFwPJt2AZkNpLtRmVIWrkwJ80eiBqOype4pSkQ0KGbbMHBj7PpyJ3EqoI_WYTC-rO-Qjlpg"
    },
    {
      "name": "Air Max 97",
      "price": "\$170",
      "img":
          "https://lh3.googleusercontent.com/aida-public/AB6AXuBise3tRhjK4-yVylEUTi2ncIVP-b0HkzwpyrJvxsOnkQoRtla3Bqi8nqdgyLbmSukCR5iOG3xX1ubCgkbFUsO-UehqVUGF_Xkyx47hIEMAhlsdhumQzvrq36y4X0QTdNNfg6DokHokpWol-gujQ_VPOIqy-gfKlfrnRTNxfdWLbe5cmI3_GR3m7XSmnV_OGE_e77MFFXC3NXtodHI5-n2KY90Fv56kz4y6NGNN4k_YbvEdgfglJ6pX0p-tvafThB003EzTxNqDpD51"
    },
    {
      "name": "Air Max 270",
      "price": "\$150",
      "img":
          "https://lh3.googleusercontent.com/aida-public/AB6AXuCf2J5widyQoJD0qiYh1UfayW5Mclsn8eiz9_bcMhLPQ29xE9teEJXVbGHQLyu1I3UukdCKq6CS3IPnhEaxzdKU9nbxFjQjgjYDbCL82PM3qFEWuit80CTUhI602Cmr8ElqELOmcKOT7OLmjRPkJcsTCnHpPawZygqPkLRjapstbnKr79YfB1uJoEpCKJ-yLh0zsl-hNMyLivniNDxpBJACijl6t4dUY41cDlCw894SNx9JMjqUY8fKN8UyI_qMvBaS7TDEniEkdTSQ"
    },
    {
      "name": "Air Max 720",
      "price": "\$180",
      "img":
          "https://lh3.googleusercontent.com/aida-public/AB6AXuB5IBm3ewsbhNUAH2gxe6yvRzre1lgHR0hINHci9Oy-VYqKiL4VQ086PhXM-4QyxrvTTUkWsQXjVZCf-eE6qObxpMPtXTmgOT88Ma3IDQw581MizZgEuAd5wvB0WOcs0fWYyzdwP_DhdD_YeNc3l9ZZmHDXWtGXEY2SYTY47KHvJ0z7MLWx46YDLAlnpasBq_oK06oXIH_klwzpFuvBCbXxLu0rzPV1ryDU8sLLJ5kTKahC7qRLw1jf8QhMFa0a12H-T00Naz7K8l_I"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey[50],
        title: const Text(
          "Shoes",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xff0d141c),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.tune, color: Color(0xff0d141c)),
          ),
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter chips
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xffe7edf4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      filters[index],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xff0d141c),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Products Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 3 / 4,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          product["img"]!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product["name"]!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff0d141c),
                      ),
                    ),
                    Text(
                      product["price"]!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xff49709c),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xff0d141c),
        unselectedItemColor: const Color(0xff49709c),
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Categories"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Wishlist"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
