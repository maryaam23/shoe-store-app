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
    final snapshot =
        await FirebaseFirestore.instance
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
    final snapshot =
        await FirebaseFirestore.instance
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
        title: const Text(
          'Users Management',
          style: TextStyle(
            color: Color(0xFF0D141C),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // 🔹 Buttons with numbers beside
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _getUserStats,
                  icon: const Icon(Icons.people_alt_outlined),
                  label: Row(
                    children: [
                      const Text("Total Users: "),
                      Text(
                        totalUniqueUsers != null ? '$totalUniqueUsers' : '—',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrangeAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _getUserStats,
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: Row(
                    children: [
                      const Text("Today: "),
                      Text(
                        usersToday != null ? '$usersToday' : '—',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // ✅ Optional: combined display at bottom too
          if (totalUniqueUsers != null && usersToday != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '👤 Total unique users: $totalUniqueUsers | 📅 Today: $usersToday',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),

          // 🔹 Users List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('users')
                      .orderBy('email', descending: false)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = snapshot.data!.docs;

                if (users.isEmpty) {
                  return const Center(child: Text('No users found.'));
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
                    final lastEnteredAt =
                        userData['lastEnteredAt'] != null
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
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: LinearProgressIndicator(),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              title: Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0D141C),
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    email,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  Text('Phone: $phone'),
                                  Text('Role: $role'),
                                  Text('Orders: $ordersCount'),
                                  Text('Cart: $cartCount items'),
                                  Text('Wishlist: $wishlistCount items'),
                                  Text('Last entered: $lastEnteredAt'),
                                ],
                              ),
                              children: [
                                if (wishlistCount > 0) ...[
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 4,
                                    ),
                                    child: Text(
                                      '🧡 Wishlist:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  ...wishlistItems.map(
                                    (item) => ListTile(
                                      dense: true,
                                      title: Text(item['name'] ?? 'No name'),
                                      subtitle: Text(
                                        'Price: ${item['price'] ?? 'N/A'}',
                                      ),
                                    ),
                                  ),
                                  const Divider(),
                                ],
                                if (cartCount > 0) ...[
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 4,
                                    ),
                                    child: Text(
                                      '🛒 Cart:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  ...cartItems.map(
                                    (item) => ListTile(
                                      dense: true,
                                      title: Text(item['name'] ?? 'No name'),
                                      subtitle: Text(
                                        'Price: ${item['price'] ?? 'N/A'}',
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
