import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_details_screen.dart';

class OrderManagementScreen extends StatelessWidget {
  const OrderManagementScreen({super.key});

  // 🔹 Helper functions to scale UI elements
  double h(BuildContext context, double value) =>
      MediaQuery.of(context).size.height * (value / 812); // base height iPhone 11 Pro
  double w(BuildContext context, double value) =>
      MediaQuery.of(context).size.width * (value / 375); // base width iPhone 11 Pro
  double sp(BuildContext context, double value) =>
      MediaQuery.of(context).textScaler.scale(value);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Orders',
          style: TextStyle(
            color: Colors.black,
            fontSize: sp(context, 18),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collectionGroup('orders') // ✅ searches all 'orders' subcollections
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No orders found 😔',
                style: TextStyle(fontSize: sp(context, 16)),
              ),
            );
          }

          final now = DateTime.now();
          final orders = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status'] ?? 'Processing';

            // ✅ Skip Delivered orders older than 30 days
            if (status == 'Delivered' && data['orderDate'] != null) {
              final orderDate = (data['orderDate'] as Timestamp).toDate();
              final difference = now.difference(orderDate).inDays;
              if (difference > 30) return false;
            }
            return true;
          }).toList();

          if (orders.isEmpty) {
            return Center(
              child: Text(
                'No active orders found 🧾',
                style: TextStyle(fontSize: sp(context, 16)),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(w(context, 12)),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final data = order.data() as Map<String, dynamic>;
              final status = data['status'] ?? 'Processing';
              final items = data['items'] ?? [];
              final total = data['total'] ?? 0;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(w(context, 12)),
                ),
                margin: EdgeInsets.symmetric(vertical: h(context, 8)),
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: w(context, 10),
                    vertical: h(context, 8),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Order #${order.id}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: sp(context, 15),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: h(context, 4)),
                        Text('Items: ${items.length}',
                            style: TextStyle(fontSize: sp(context, 13))),
                        Text('Total: \$${total.toString()}',
                            style: TextStyle(fontSize: sp(context, 13))),
                        SizedBox(height: h(context, 4)),
                        Row(
                          children: [
                            Text('Status: ',
                                style: TextStyle(fontSize: sp(context, 13))),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: w(context, 8),
                                vertical: h(context, 2),
                              ),
                              decoration: BoxDecoration(
                                color: status == 'Delivered'
                                    ? Colors.green[100]
                                    : Colors.orange[100],
                                borderRadius:
                                    BorderRadius.circular(w(context, 8)),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  color: status == 'Delivered'
                                      ? Colors.green[800]
                                      : Colors.orange[800],
                                  fontWeight: FontWeight.bold,
                                  fontSize: sp(context, 13),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: w(context, 16),
                      color: Colors.grey[700],
                    ),
                    onTap: () {
                      final orderUserId = data['userId'];
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderDetailsScreen(
                            userId: orderUserId,
                            orderId: order.id,
                            orderData: data,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
