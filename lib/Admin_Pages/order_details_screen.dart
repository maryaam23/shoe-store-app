import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String userId;
  final String orderId;
  final Map<String, dynamic> orderData;

  const OrderDetailsScreen({
    super.key,
    required this.userId,
    required this.orderId,
    required this.orderData,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late Map<String, dynamic> orderData;

  @override
  void initState() {
    super.initState();
    orderData = Map<String, dynamic>.from(widget.orderData);
  }

  Future<void> markAsDelivered() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('orders')
        .doc(widget.orderId)
        .update({'status': 'Delivered'});

    setState(() {
      orderData['status'] = 'Delivered'; // ✅ instantly updates UI
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order marked as Delivered ✅')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = orderData['items'] ?? [];
    final status = orderData['status'] ?? 'Processing';

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${orderData['orderNumber'] ?? widget.orderId}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Customer: ${orderData['customer']}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Status: $status'),
            Text('Total: \$${orderData['total']}'),
            Text('Payment: ${orderData['paymentMethod']}'),
            Text('Date: ${orderData['orderDate']?.toDate().toString() ?? ''}'),

            const SizedBox(height: 16),
            const Divider(),
            const Text(
              'Items:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            ...items.map<Widget>((item) {
              final colorValue = item['color'];
              final itemColor =
                  colorValue is int ? Color(colorValue) : Colors.grey;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: Image.network(
                    item['image'],
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                  title: Text(item['name'] ?? 'Unknown'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Price: \$${item['price']}'),
                      Text('Size: ${item['size']}'),
                      Text('Quantity: ${item['quantity']}'),
                      Row(
                        children: [
                          const Text('Color: '),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: itemColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 24),

            if (status != 'Delivered')
              ElevatedButton.icon(
                onPressed: markAsDelivered,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Mark as Delivered'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              )
            else
              const Center(
                child: Text(
                  'This order is already delivered ✅',
                  style: TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
