import 'package:flutter/material.dart';

class OrderManagementScreen extends StatelessWidget {
  const OrderManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Orders',
          style: TextStyle(
            color: Color(0xFF0d141c),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF0d141c), size: 24),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search order ID or customer",
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

          // Filter Buttons
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: const [
                FilterChipWidget(label: "Status"),
                SizedBox(width: 8),
                FilterChipWidget(label: "Customer"),
                SizedBox(width: 8),
                FilterChipWidget(label: "Date"),
                SizedBox(width: 8),
                FilterChipWidget(label: "Total"),
              ],
            ),
          ),

          // Order List
          Expanded(
            child: ListView(
              children: const [
                OrderItem(
                  status: "Processing",
                  orderId: "#12345",
                  customer: "Alex",
                  imageUrl:
                      "https://lh3.googleusercontent.com/aida-public/AB6AXuDKmbimYRzA3FJQCasXSaGPRJLEEk5C7LFzgPQFP0EgZjCtdY70lJ7Iu56IHiQsjyBeLD8L-uLhiK6T-DxmhBWHPIl5_hGvS0uQFgk93RN1IoV8PeFh_YBWyLpwW1SDg5wxpdkyAjKh3xC621QP94RmjvO2cVnrw5hx5JVuXUmQZRv-5T_NoRBQNSPaPXiI0u84TBoThxiZxl8HFECEXo1X8nl8zY2oWWp_KsR-S1m3kho_5N8DL2YCH8OWzN2bL-9HXVoL8wtJ_sUH",
                ),
                OrderItem(
                  status: "Shipped",
                  orderId: "#67890",
                  customer: "Jordan",
                  imageUrl:
                      "https://lh3.googleusercontent.com/aida-public/AB6AXuAt55hir6EsxOb_fIm3A6PfgD1V2CsWZIg0QmdbSOX7u9B0jzIiPgBJTTi3M1teAi441lyUHVKD3pLPn096lL9_sA7Oed_lxuEO1gDbnWrn1-YvdA580XjaSRsWwfziS0ijCL-ftSebTT8h-DEI_K-qaB3AoFJ_u4QIisev2cYA12tsOWsF4kP3w1mpl5g9-JLqDlWOM5XYt_xz5Cadyl6lTTcXDjC9Clm06I4yVVX0FJWVnlCYDAsJQK2J8zGgIOPvhrIcToyn4Ub",
                ),
                OrderItem(
                  status: "Delivered",
                  orderId: "#11223",
                  customer: "Taylor",
                  imageUrl:
                      "https://lh3.googleusercontent.com/aida-public/AB6AXuBd-16_-0c8T91nEo3VR5ay8kmUT9JTJKPxWzpIet4zgAc9XjPxLrwpaWX48JOxhoKL_qiWIhjUzHoKXZu4NO3DsSOpBZ9u0mljEkdqtbZvTvZiPC4kJCjSU0wevsredKByi7iUHY9nmHTIlj0oUXYbd3uNy4qL_YZg-AMJi3vhCFujlGZ9HgR3xYv8GDQ-_xkD7OHIaXKyIbPWy6BnD1GYvoaFuLnnddir0D5x5CDYdHIM_CYANeLXos-TVXJKBc_cU0XgrjTxcjw6",
                ),
                OrderItem(
                  status: "Cancelled",
                  orderId: "#44556",
                  customer: "Casey",
                  imageUrl:
                      "https://lh3.googleusercontent.com/aida-public/AB6AXuD23FLbiYIQB93a08VHyCxIesUOsw_t9Boz1zvFsOII0Ompx0tZ1S-yH-k3tTXcrXFpXsaDYRYJmJ4sLNeud_bK9aa7kcyXOb_Uss9CaLkfgjnn0G92kNdLK_ZRa1B7ybuhsa3ECOyEvJ0msQxSixJYEbYzT_dSC-ucuNNZxlaS7IvsV2tDMU5ClX3Da-_ik_O6v8ahdPfpv33U4Z4x3su3GJj8942X4uMY2pK6cVRVMt6yTtej4GCpclsS1a1qlHPrz1MUHivcEbzV",
                ),
              ],
            ),
          ),
        ],
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: const Color(0xFF0d141c),
        unselectedItemColor: const Color(0xFF49709c),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// Filter Button Widget
class FilterChipWidget extends StatelessWidget {
  final String label;
  const FilterChipWidget({super.key, required this.label});

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
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF0d141c),
                  fontWeight: FontWeight.w500,
                  fontSize: 14)),
          const Icon(Icons.arrow_drop_down, color: Color(0xFF0d141c)),
        ],
      ),
    );
  }
}

// Order Item Widget
class OrderItem extends StatelessWidget {
  final String status;
  final String orderId;
  final String customer;
  final String imageUrl;

  const OrderItem({
    super.key,
    required this.status,
    required this.orderId,
    required this.customer,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
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
                Text(status,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0d141c))),
                const SizedBox(height: 4),
                Text('Order $orderId | Customer: $customer',
                    style: const TextStyle(
                        fontSize: 14, color: Color(0xFF49709c))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
