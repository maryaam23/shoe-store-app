import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersManagementPage extends StatefulWidget {
  const UsersManagementPage({super.key});

  @override
  State<UsersManagementPage> createState() => _UsersManagementPageState();
}

class _UsersManagementPageState extends State<UsersManagementPage> {
  int? totalUniqueUsers;
  int? usersToday;

  // ✅ Responsive size helpers
  double w(BuildContext context, double factor) =>
      MediaQuery.of(context).size.width * factor;
  double h(BuildContext context, double factor) =>
      MediaQuery.of(context).size.height * factor;
  double sp(BuildContext context, double size) =>
      MediaQuery.of(context).size.width * size; // scales font by width

  // 🔹 Fetch user stats
  Future<void> _getUserStats() async {
    final firestore = FirebaseFirestore.instance;
    final usersSnapshot = await firestore.collection('users').get();

    int total = usersSnapshot.docs.length;
    int todayCount = 0;

    final today = DateTime.now();
    for (var doc in usersSnapshot.docs) {
      final data = doc.data();
      final lastEnteredAt = (data['lastEnteredAt'] as Timestamp?)?.toDate();
      if (lastEnteredAt != null &&
          lastEnteredAt.year == today.year &&
          lastEnteredAt.month == today.month &&
          lastEnteredAt.day == today.day) {
        todayCount++;
      }
    }

    setState(() {
      totalUniqueUsers = total;
      usersToday = todayCount;
    });
  }

  Future<int> getSubcollectionCount(String userId, String subcollection) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection(subcollection)
        .get();
    return snapshot.size;
  }

  Future<List<Map<String, dynamic>>> getSubcollectionItems(
    String userId,
    String subcollection,
  ) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection(subcollection)
        .get();
    return snapshot.docs.map((d) => d.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F5F9),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Users Management',
          style: TextStyle(
            color: const Color(0xFF0D141C),
            fontWeight: FontWeight.bold,
            fontSize: sp(context, 0.05),
          ),
        ),
      ),
      body: Column(
        children: [
          // 🔹 Stats buttons
          Padding(
            padding: EdgeInsets.all(w(context, 0.03)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _getUserStats,
                  icon: const Icon(Icons.people_alt_outlined),
                  label: Row(
                    children: [
                      Text(
                        "Total Users: ",
                        style: TextStyle(fontSize: sp(context, 0.035)),
                      ),
                      Text(
                        totalUniqueUsers != null ? '$totalUniqueUsers' : '—',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: sp(context, 0.037),
                        ),
                      ),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrangeAccent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: w(context, 0.04),
                      vertical: h(context, 0.015),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _getUserStats,
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: Row(
                    children: [
                      Text(
                        "Today: ",
                        style: TextStyle(fontSize: sp(context, 0.035)),
                      ),
                      Text(
                        usersToday != null ? '$usersToday' : '—',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: sp(context, 0.037),
                        ),
                      ),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: w(context, 0.04),
                      vertical: h(context, 0.015),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(thickness: h(context, 0.0015)),

          // ✅ Combined display
          if (totalUniqueUsers != null && usersToday != null)
            Padding(
              padding: EdgeInsets.all(w(context, 0.02)),
              child: Text(
                '👤 Total unique users: $totalUniqueUsers | 📅 Today: $usersToday',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontSize: sp(context, 0.04),
                ),
              ),
            ),

          // 🔹 Users List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .orderBy('email', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = snapshot.data!.docs;
                if (users.isEmpty) {
                  return Center(
                    child: Text(
                      'No users found.',
                      style: TextStyle(fontSize: sp(context, 0.04)),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final userDoc = users[index];
                    final userData = userDoc.data() as Map<String, dynamic>;
                    final userId = userDoc.id;

                    final name = userData['fullName'] ?? 'No name';
                    final email = userData['email'] ?? 'No email';
                    final phone = userData['phone'] ?? 'No phone';
                    final role = userData['role'] ?? 'Unknown';
                    final lastEnteredAt = userData['lastEnteredAt'] != null
                        ? (userData['lastEnteredAt'] as Timestamp)
                            .toDate()
                            .toString()
                        : 'Never';

                    return FutureBuilder(
                      future: Future.wait([
                        getSubcollectionCount(userId, 'orders'),
                        getSubcollectionCount(userId, 'cart'),
                        getSubcollectionCount(userId, 'wishlist'),
                        getSubcollectionItems(userId, 'cart'),
                        getSubcollectionItems(userId, 'wishlist'),
                      ]),
                      builder: (context, snapshot2) {
                        if (!snapshot2.hasData) {
                          return Padding(
                            padding: EdgeInsets.all(w(context, 0.02)),
                            child: const LinearProgressIndicator(),
                          );
                        }

                        final results = snapshot2.data!;
                        final ordersCount = results[0] as int;
                        final cartCount = results[1] as int;
                        final wishlistCount = results[2] as int;
                        final cartItems =
                            results[3] as List<Map<String, dynamic>>;
                        final wishlistItems =
                            results[4] as List<Map<String, dynamic>>;

                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: w(context, 0.03),
                            vertical: h(context, 0.008),
                          ),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(w(context, 0.04)),
                            ),
                            elevation: 4,
                            child: ExpansionTile(
                              tilePadding: EdgeInsets.symmetric(
                                horizontal: w(context, 0.04),
                                vertical: h(context, 0.01),
                              ),
                              title: Text(
                                name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0D141C),
                                  fontSize: sp(context, 0.045),
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    email,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: sp(context, 0.035),
                                    ),
                                  ),
                                  Text('Phone: $phone',
                                      style: TextStyle(
                                          fontSize: sp(context, 0.035))),
                                  Text('Role: $role',
                                      style: TextStyle(
                                          fontSize: sp(context, 0.035))),
                                  Text('Orders: $ordersCount',
                                      style: TextStyle(
                                          fontSize: sp(context, 0.035))),
                                  Text('Cart: $cartCount items',
                                      style: TextStyle(
                                          fontSize: sp(context, 0.035))),
                                  Text('Wishlist: $wishlistCount items',
                                      style: TextStyle(
                                          fontSize: sp(context, 0.035))),
                                  Text('Last entered: $lastEnteredAt',
                                      style: TextStyle(
                                          fontSize: sp(context, 0.035))),
                                ],
                              ),
                              children: [
                                if (wishlistCount > 0) ...[
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: w(context, 0.04),
                                      vertical: h(context, 0.005),
                                    ),
                                    child: Text(
                                      '🧡 Wishlist:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: sp(context, 0.045),
                                      ),
                                    ),
                                  ),
                                  ...wishlistItems.map(
                                    (item) => ListTile(
                                      dense: true,
                                      title: Text(
                                        item['name'] ?? 'No name',
                                        style: TextStyle(
                                            fontSize: sp(context, 0.037)),
                                      ),
                                      subtitle: Text(
                                        'Price: ${item['price'] ?? 'N/A'}',
                                        style: TextStyle(
                                            fontSize: sp(context, 0.035)),
                                      ),
                                    ),
                                  ),
                                  const Divider(),
                                ],
                                if (cartCount > 0) ...[
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: w(context, 0.04),
                                      vertical: h(context, 0.005),
                                    ),
                                    child: Text(
                                      '🛒 Cart:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: sp(context, 0.045),
                                      ),
                                    ),
                                  ),
                                  ...cartItems.map(
                                    (item) => ListTile(
                                      dense: true,
                                      title: Text(
                                        item['name'] ?? 'No name',
                                        style: TextStyle(
                                            fontSize: sp(context, 0.037)),
                                      ),
                                      subtitle: Text(
                                        'Price: ${item['price'] ?? 'N/A'}',
                                        style: TextStyle(
                                            fontSize: sp(context, 0.035)),
                                      ),
                                    ),
                                  ),
                                  const Divider(),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
