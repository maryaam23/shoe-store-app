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

  // 🔹 Responsive size helpers
  double h(BuildContext context, double value) =>
      MediaQuery.of(context).size.height * (value / 812); // base height (iPhone 11 Pro)
  double w(BuildContext context, double value) =>
      MediaQuery.of(context).size.width * (value / 375); // base width
  double sp(BuildContext context, double value) =>
      MediaQuery.of(context).textScaler.scale(value);

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
      orderData['status'] = 'Delivered';
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        title: Text(
          'Order #${orderData['orderNumber'] ?? widget.orderId}',
          style: TextStyle(
            fontSize: sp(context, 18),
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(w(context, 16)),
        child: ListView(
          children: [
            // 🔹 Customer Info
            Text(
              'Customer: ${orderData['customer']}',
              style: TextStyle(
                fontSize: sp(context, 16),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: h(context, 4)),
            Text(
              'Phone: ${orderData['phone']}',
              style: TextStyle(fontSize: sp(context, 14)),
            ),
            Text(
              'Address: ${orderData['city']}',
              style: TextStyle(fontSize: sp(context, 14)),
            ),
            SizedBox(height: h(context, 8)),

            // 🔹 Order Info
            Text('Status: $status', style: TextStyle(fontSize: sp(context, 14))),
            Text('Total: \$${orderData['total']}',
                style: TextStyle(fontSize: sp(context, 14))),
            Text('Payment: ${orderData['paymentMethod']}',
                style: TextStyle(fontSize: sp(context, 14))),
            Text(
              'Date: ${orderData['orderDate']?.toDate().toString() ?? ''}',
              style: TextStyle(fontSize: sp(context, 13)),
            ),

            SizedBox(height: h(context, 16)),
            Divider(thickness: 1.2),
            Text(
              'Items:',
              style: TextStyle(
                fontSize: sp(context, 18),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: h(context, 8)),

            // 🔹 Items List
            ...items.map<Widget>((item) {
              final colorValue = item['color'];
              final itemColor =
                  colorValue is int ? Color(colorValue) : Colors.grey;

              return Card(
                margin: EdgeInsets.symmetric(vertical: h(context, 6)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(w(context, 12)),
                ),
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(w(context, 8)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(w(context, 8)),
                        child: Image.network(
                          item['image'],
                          width: w(context, 64),
                          height: w(context, 64),
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: w(context, 12)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['name'] ?? 'Unknown',
                                style: TextStyle(
                                  fontSize: sp(context, 15),
                                  fontWeight: FontWeight.bold,
                                )),
                            SizedBox(height: h(context, 4)),
                            Text('Price: \$${item['price']}',
                                style: TextStyle(fontSize: sp(context, 13))),
                            Text('Size: ${item['size']}',
                                style: TextStyle(fontSize: sp(context, 13))),
                            Text('Quantity: ${item['quantity']}',
                                style: TextStyle(fontSize: sp(context, 13))),
                            SizedBox(height: h(context, 4)),
                            Row(
                              children: [
                                Text('Color: ',
                                    style: TextStyle(fontSize: sp(context, 13))),
                                Container(
                                  width: w(context, 18),
                                  height: w(context, 18),
                                  decoration: BoxDecoration(
                                    color: itemColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.black26),
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
              );
            }).toList(),

            SizedBox(height: h(context, 24)),

            // 🔹 Action button or delivered message
            if (status != 'Delivered')
              ElevatedButton.icon(
                onPressed: markAsDelivered,
                icon: Icon(Icons.check_circle_outline, size: w(context, 18)),
                label: Text(
                  'Mark as Delivered',
                  style: TextStyle(fontSize: sp(context, 15)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: h(context, 14)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(w(context, 12)),
                  ),
                ),
              )
            else
              Center(
                child: Text(
                  'This order is already delivered ✅',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: sp(context, 15),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
