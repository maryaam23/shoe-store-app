import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderHistoryPage extends StatelessWidget {
  final String userId;

  const OrderHistoryPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final ordersRef = FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("orders");

    // MediaQuery for responsive sizes
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text("Order History", style: TextStyle(fontSize: w * 0.05)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: ordersRef.orderBy("orderDate", descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No orders found",
                style: TextStyle(fontSize: w * 0.045),
              ),
            );
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final items = order["items"] as List<dynamic>? ?? [];

              return Card(
                margin: EdgeInsets.symmetric(
                  vertical: h * 0.01,
                  horizontal: w * 0.03,
                ),
                child: Padding(
                  padding: EdgeInsets.all(w * 0.03),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Order #: ${order['orderNumber']}",
                        style: GoogleFonts.merriweather(
                          fontSize: w * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: h * 0.005),
                      Text(
                        "Date: ${order['orderDate'] != null ? (order['orderDate'] as Timestamp).toDate() : 'N/A'}",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: w * 0.035,
                        ),
                      ),
                      SizedBox(height: h * 0.01),
                      Text(
                        "City: ${order['city'] ?? 'N/A'}",
                        style: TextStyle(fontSize: w * 0.038),
                      ),
                      Text(
                        "Address: ${order['address'] ?? 'N/A'}",
                        style: TextStyle(fontSize: w * 0.038),
                      ),
                      Text(
                        "Phone: ${order['phone'] ?? 'N/A'}",
                        style: TextStyle(fontSize: w * 0.038),
                      ),
                      Text(
                        "Payment Method: ${order['paymentMethod'] ?? 'N/A'}",
                        style: TextStyle(fontSize: w * 0.038),
                      ),
                      Text(
                        "Notes: ${order['notes'] ?? ''}",
                        style: TextStyle(fontSize: w * 0.038),
                      ),
                      SizedBox(height: h * 0.01),
                      Text(
                        "Subtotal: ₪${order['subtotal']}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: w * 0.04,
                        ),
                      ),
                      Text(
                        "Shipping: ₪${order['shipping']}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: w * 0.04,
                        ),
                      ),
                      Text(
                        "Total: ₪${order['total']}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: w * 0.045,
                        ),
                      ),
                      Divider(thickness: 1, height: h * 0.02),
                      Text(
                        "Items:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: w * 0.04,
                        ),
                      ),
                      SizedBox(height: h * 0.005),
                      ...items.map(
                        (item) => Padding(
                          padding: EdgeInsets.symmetric(vertical: h * 0.005),
                          child: Row(
                            children: [
                              if (item['image'] != null && item['image'] != "")
                                Image.network(
                                  item['image'],
                                  width: w * 0.12,
                                  height: w * 0.12,
                                  fit: BoxFit.cover,
                                ),
                              SizedBox(width: w * 0.02),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${item['quantity']}x ${item['name']} - ₪${item['price']}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: w * 0.038,
                                      ),
                                    ),
                                    if (item['size'] != null)
                                      Text(
                                        "Size: ${item['size']}",
                                        style: TextStyle(fontSize: w * 0.035),
                                      ),
                                    if (item['color'] != null)
                                      Row(
                                        children: [
                                          Text(
                                            "Color: ",
                                            style: TextStyle(
                                              fontSize: w * 0.035,
                                            ),
                                          ),
                                          Container(
                                            width: w * 0.04,
                                            height: w * 0.04,
                                            decoration: BoxDecoration(
                                              color:
                                                  item['color'] != null
                                                      ? _hexToColor(
                                                        item['color'],
                                                      )
                                                      : Colors.black,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
