import 'package:flutter/material.dart';
import 'package:shoe_store_app/Admin_Pages/orders_mangment_page.dart';
import 'package:shoe_store_app/Admin_Pages/product_mangment_page.dart';
import 'package:shoe_store_app/Admin_Pages/users_mangment_page.dart';
import 'package:shoe_store_app/User_Pages/login_page.dart'; // make sure you import LoginPage

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

class AdminOverviewScreen extends StatefulWidget {
  @override
  _AdminOverviewScreenState createState() => _AdminOverviewScreenState();
}

class _AdminOverviewScreenState extends State<AdminOverviewScreen> {
  int _currentIndex = 0;

  // Pages for BottomNavigationBar
  final List<Widget> _pages = [
    AdminOverviewScreenBody(), // main overview content
    OrderManagementScreen(),
    ProductManagementScreen(),
    UsersManagementPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.blueGrey,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: "Orders"),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: "Products",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Users"),
        ],
      ),
    );
  }
}

// Separated main overview content to allow bottom nav switching
class AdminOverviewScreenBody extends StatelessWidget {
  final List<Map<String, dynamic>> stats = [
    {
      "title": "Total Sales",
      "value": "\$12,500",
      "change": "+10%",
      "color": Colors.green,
    },
    {
      "title": "Orders Today",
      "value": "75",
      "change": "+5%",
      "color": Colors.green,
    },
    {
      "title": "Pending Orders",
      "value": "5",
      "change": "-2%",
      "color": Colors.red,
    },
    {
      "title": "Low-Stock Items",
      "value": "12",
      "change": "-1%",
      "color": Colors.red,
    },
  ];

  final List<Map<String, dynamic>> lowStockProducts = [
    {
      "name": "Running Shoes",
      "left": "10 units left",
      "image": "https://example.com/image1.jpg",
    },
    {
      "name": "Casual Sneakers",
      "left": "5 units left",
      "image": "https://example.com/image2.jpg",
    },
    {
      "name": "Boots",
      "left": "2 units left",
      "image": "https://example.com/image3.jpg",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final height = media.size.height;

    double scaleWidth(double size) => size * width / 375; // base width
    double scaleHeight(double size) => size * height / 812; // base height
    double scaleText(double size) => size * width / 375;

    return SafeArea(
      child: ListView(
        padding: EdgeInsets.all(scaleWidth(16)),
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.arrow_back,
                size: scaleWidth(28),
                color: Colors.black87,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    "Overview",
                    style: TextStyle(
                      fontSize: scaleText(20),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: scaleWidth(28)),
            ],
          ),
          SizedBox(height: scaleHeight(16)),
          Text(
            "Hi, Alex, here's today's store overview",
            style: TextStyle(
              fontSize: scaleText(22),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: scaleHeight(16)),

          // Stats Grid
          GridView.builder(
            itemCount: stats.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: scaleWidth(12),
              mainAxisSpacing: scaleHeight(12),
            ),
            itemBuilder: (context, index) {
              final stat = stats[index];
              return Container(
                padding: EdgeInsets.all(scaleWidth(16)),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(scaleWidth(12)),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stat['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: scaleText(16),
                      ),
                    ),
                    SizedBox(height: scaleHeight(8)),
                    Text(
                      stat['value'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: scaleText(22),
                      ),
                    ),
                    SizedBox(height: scaleHeight(4)),
                    Text(
                      stat['change'],
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: scaleText(14),
                        color: stat['color'],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: scaleHeight(24)),

          // Low Stock Alerts
          Text(
            "Low Stock Alerts",
            style: TextStyle(
              fontSize: scaleText(20),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: scaleHeight(12)),
          Column(
            children:
                lowStockProducts
                    .map(
                      (product) => Container(
                        margin: EdgeInsets.only(bottom: scaleHeight(12)),
                        padding: EdgeInsets.all(scaleWidth(12)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(scaleWidth(12)),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                scaleWidth(8),
                              ),
                              child: Image.network(
                                product['image'],
                                width: scaleWidth(50),
                                height: scaleWidth(50),
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: scaleWidth(12)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['name'],
                                  style: TextStyle(
                                    fontSize: scaleText(16),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: scaleHeight(4)),
                                Text(
                                  product['left'],
                                  style: TextStyle(
                                    fontSize: scaleText(14),
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
          ),
          SizedBox(height: scaleHeight(24)),

          // Buttons
          Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  navigateToPage(context, ProductManagementScreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: Size(double.infinity, scaleHeight(45)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(scaleWidth(10)),
                  ),
                ),
                child: Text(
                  "Add Product",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: scaleText(16),
                  ),
                ),
              ),
              SizedBox(height: scaleHeight(12)),
              OutlinedButton(
                onPressed: () {
                  navigateToPage(context, OrderManagementScreen());
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, scaleHeight(45)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(scaleWidth(10)),
                  ),
                ),
                child: Text(
                  "View Orders",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: scaleText(16),
                  ),
                ),
              ),
              SizedBox(height: scaleHeight(12)),
              OutlinedButton(
                onPressed: () {
                  navigateToPage(context, UsersManagementPage());
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, scaleHeight(45)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(scaleWidth(10)),
                  ),
                ),
                child: Text(
                  "Manage Users",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: scaleText(16),
                  ),
                ),
              ),
              SizedBox(height: scaleHeight(12)),

              // LOGOUT BUTTON
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: Size(double.infinity, scaleHeight(45)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(scaleWidth(10)),
                  ),
                ),
                child: Text(
                  "Logout",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: scaleText(16),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: scaleHeight(24)),
        ],
      ),
    );
  }

  void navigateToPage(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }
}
