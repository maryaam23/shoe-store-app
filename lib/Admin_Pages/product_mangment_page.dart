import 'package:flutter/material.dart';

class ProductManagementScreen extends StatelessWidget {
  const ProductManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Products',
          style: TextStyle(
            color: Color(0xFF0d141c),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add,
              color: Color(0xFF0d141c),
              size: 24,
            ),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search products',
                hintStyle: const TextStyle(color: Color(0xFF49709c)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF49709c)),
                filled: true,
                fillColor: const Color(0xFFe7edf4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Filter buttons
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                FilterButton(label: 'Category'),
                const SizedBox(width: 8),
                FilterButton(label: 'Stock'),
                const SizedBox(width: 8),
                FilterButton(label: 'Price'),
              ],
            ),
          ),

          // Product List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                ProductItem(
                  name: 'Air Zoom Pegasus 38',
                  category: 'Sneakers',
                  stock: 50,
                  imageUrl:
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDZwLijp_0djnBOdir76ZL5mu1eTHRmXzPFA2smBlezTAEzzY7ilp2dLKI2J8krDOxZW3fPEtOKesTEk4i6WJ3s8VFXs-PMuT6bjU5nGZTT262YSw7KbfSj_SW8PKLhs5p9Ps2zmIDVm84kejzEd34uSFjJbEwfcNjJ0wGbKA38JLdEw7rfm2hCISNW0T7kAUkDBn6Hqxn1eY6tzvLiQ5pDQZfofRQBzr6IHkhPIJIcgiKTk1RZhQDCZyR40POf7rq8ay0jBz2pXiPe',
                ),
                ProductItem(
                  name: 'Free Run 5.0',
                  category: 'Running',
                  stock: 30,
                  imageUrl:
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuBDSDW9gyCkVlDWRhO_CO3p6UdaxnmK844taXLDUTNfrJ6pmqSy3w2BSAy0AVTyVfe6Hj9F0vDYe-d62fsTsAF5fW1w4bAixz91ct2LOE6VR17K1QRONwN2lp-mL6RCIPuNltpRuArn0ZjR6pk8gnZbSikjjWCxh0lrHxu94JKmspgW3xV6vD5VvkZqwyW1FPY2sbC4ksuNSr_89xruR_lt_cdOzP9RQfPCKi-DcwqjBaqzPDfi0y6Bo5SJgp08dsIhWxUpNJjk89uy',
                ),
                ProductItem(
                  name: 'LeBron 19',
                  category: 'Basketball',
                  stock: 20,
                  imageUrl:
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDSGgMFXZ9xKlqZO9dkXSEHtacfGe_312BL8y-UKOkNkocUiGQTbWQ6m6vrWhaE_7qPhNRSXi299wwF9drdXNQ2FofPOBl7dpxJ_O4vA9qsHMLlSLtDxyAd0V70Sy7RvE3nCW5_-ZddWTWS-adoZWUyk_epcX3kg6qT5RQw6iLCyL5TxKMHo00JBPavOTWzLQ5nEcsZhzDOCmCsifJrrgOhQfwPc-gOV9yivWGvI21qBsPdGXQLGh0EUlA7yhduYoCs2Ei-KabkwtVo',
                ),
                ProductItem(
                  name: 'Metcon 7',
                  category: 'Training',
                  stock: 40,
                  imageUrl:
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuA1m-PeSFy7hMy3Km4FHkGycXTVMHHU69c4nHYJDjrf4yomra0tSv7D0J2bV43dgLKXqtra0q5GOlhnkQG35bWq6Ae8sONtTO_nPKidUOR6vmb5MvU076NsIp1JxOJNnSd-ky3dC4Ww-6qG5ut35o87n3n7QAUlOAHHqkkPl1yjNPqn7IDazvzL0SdB0N5JOWAzA3_ENZOdsql0ki_vlGp0h37Ujnx5YHnaVZNG8U91rVEc0bzDMzMee79aTMM6lpodyCF4oY9TXpz1',
                ),
                ProductItem(
                  name: 'Air Force 1',
                  category: 'Lifestyle',
                  stock: 60,
                  imageUrl:
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuBbkNL7qioXsn_01oe5LpEmC75NC8KHH5vxZpDc1XuGvUdVzXn_csNeIm5sStLAt945uoy1OLEK5U5yF6TSp5yLvEVC1aG9DiKb4GdpsrnlH6ZH63kb8PGGSp9nFvyh8IdDgRLjA3jASGKCQ5_Nu_I2aWINRjwWUV4kxelCfTDdNwXkJ2KkD9Rztwm21foWpHRJMJNwYbzk1nTNQDuSIyywTj4WO6yp9TXJLpjjGW36ZtswHDse6t2EGw0TKgZTOKLkK3S5NCH8xKz7',
                ),
              ],
            ),
          ),

          // Add Product Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 24),
                label: const Text(
                  'Add Product',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  final String label;
  const FilterButton({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFe7edf4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
                color: Color(0xFF0d141c),
                fontWeight: FontWeight.w500,
                fontSize: 14),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_drop_down, size: 20, color: Color(0xFF0d141c)),
        ],
      ),
    );
  }
}

class ProductItem extends StatelessWidget {
  final String name;
  final String category;
  final int stock;
  final String imageUrl;

  const ProductItem({
    super.key,
    required this.name,
    required this.category,
    required this.stock,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0d141c))),
                const SizedBox(height: 4),
                Text(
                  'Category: $category, Stock: $stock',
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFF49709c)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
