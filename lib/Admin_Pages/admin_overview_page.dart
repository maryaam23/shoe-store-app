import 'package:flutter/material.dart';

void main() => runApp(AdminOverviewApp());

class AdminOverviewApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AdminOverviewScreen(),
    );
  }
}

class AdminOverviewScreen extends StatelessWidget {
  final List<Map<String, dynamic>> stats = [
    {
      "title": "Total Sales",
      "value": "\$12,500",
      "change": "+10%",
      "color": Colors.green
    },
    {
      "title": "Orders Today",
      "value": "75",
      "change": "+5%",
      "color": Colors.green
    },
    {
      "title": "Pending Orders",
      "value": "5",
      "change": "-2%",
      "color": Colors.red
    },
    {
      "title": "Low-Stock Items",
      "value": "12",
      "change": "-1%",
      "color": Colors.red
    },
  ];

  final List<Map<String, dynamic>> lowStockProducts = [
    {
      "name": "Running Shoes",
      "left": "10 units left",
      "image":
          "https://lh3.googleusercontent.com/aida-public/AB6AXuCJclcdrPld5PzpNEH0qplRNdYPmxChHmSfX0MQZ-jwQiFrmU-25SMi1sQOFV2db5JPmas8MVIsQspA9DZWDi1d4ox0L9_e0ejlCYNxsf1MuHwFX-Zg2hE_uUEL84tvOGwjv8jKcXq8_ryJu_fB9WTjzB9nDJNOh_K2qOAUahsXCIhngjL-gIOMNaCsZKiVwFQ90IYV-ocnnKy0vJok5E7Pyh0JRDc-IZitFUg6ys5diFpLJzfYi0D2vRLq2eMcqPTk-DHwfO2FE6AQ"
    },
    {
      "name": "Casual Sneakers",
      "left": "5 units left",
      "image":
          "https://lh3.googleusercontent.com/aida-public/AB6AXuBzBtEReFEyDrIYbrtAuzvzSWbM5gnttPZCC_poXtZrxb05srSxJsAVEKMQbr44qBRakZIem2hqGq7qUVKDnR99o5pqWOUHjDpmwQy1B3A4pBUYwXIZISvS5YtQj9rnQcx3x9ds4LDSCoqHUs5g7f-D1PVgJYuOOGC0BX0N5r79jEyzhuc1MKzgto4EKi3MPERdPBAE-ZHgufsgmxYW1pudJVEd3PTxvpyhsjMSHKRq3Zp9kZDa6J1F4KFmZQVfwkRPQtIILchMFuYw"
    },
    {
      "name": "Boots",
      "left": "2 units left",
      "image":
          "https://lh3.googleusercontent.com/aida-public/AB6AXuBPYh0TZi8I1rqrTL7vFegblKHXHgPEAmDo3ovU0h2VLDuq3Sepr10J-1vvi8Ci3ICShxR_L1wug78E88T_rWGDPekfLwpTKU2PDRuT6aRAIui8xFWfM5JjBagoGuTL0osZq-MilHGW5Ypgp82WGxe8hR5tkfPYU1bmP5eusa7C_Dg7w7dILvyN-JwiiUT-g2x7FJfn8blsibeIzhTAJyf-1HBdijfbldMGKPaJQBzaQPeLb7CUI1rVlClnvu7CMCkYgj_hVa57LeO5"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.arrow_back, size: 28, color: Colors.black87),
                  Expanded(
                    child: Center(
                      child: Text(
                        "Overview",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 28), // placeholder for back button alignment
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  Text(
                    "Hi, Alex, here's today's store overview",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Stats Grid
                  GridView.builder(
                    itemCount: stats.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.5,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12),
                    itemBuilder: (context, index) {
                      final stat = stats[index];
                      return Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(stat['title'],
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                )),
                            SizedBox(height: 8),
                            Text(stat['value'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                )),
                            SizedBox(height: 4),
                            Text(stat['change'],
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: stat['color'],
                                )),
                          ],
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 24),

                  // Low Stock Alerts
                  Text(
                    "Low Stock Alerts",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Column(
                    children: lowStockProducts
                        .map(
                          (product) => Container(
                            margin: EdgeInsets.only(bottom: 12),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    product['image'],
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(product['name'],
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500)),
                                    SizedBox(height: 4),
                                    Text(product['left'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.blueGrey,
                                        )),
                                  ],
                                )
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),

                  SizedBox(height: 24),

                  // Buttons
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          minimumSize: Size(double.infinity, 45),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text("Add Product",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(double.infinity, 45),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text("View Orders",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(double.infinity, 45),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text("Manage Users",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.blueGrey,
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: "Orders"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: "Products"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Users"),
        ],
      ),
    );
  }
}
