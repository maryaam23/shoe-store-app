import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:intl/intl.dart'; // 👈 Add intl package in pubspec.yaml

class NotificationScreen extends StatefulWidget {
  final String userId;
  const NotificationScreen({super.key, required this.userId});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  int selectedTabIndex = 0;

  final List<String> categories = [
    "promotions",
    "order_updates",
    "recommendations",
  ];

  /// Count unread notifications for badge
  ValueNotifier<int> unreadCount = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    String selectedCategory = categories[selectedTabIndex];

    /// General notifications stream
    final generalStream =
        FirebaseFirestore.instance
            .collection("UserNotification")
            .where("category", isEqualTo: selectedCategory)
            .orderBy("createdAt", descending: true)
            .snapshots();

    /// User-specific notifications stream
    final userStream =
        FirebaseFirestore.instance
            .collection("users")
            .doc(widget.userId)
            .collection("notification")
            .where("category", isEqualTo: selectedCategory)
            //.orderBy("createdAt", descending: true) // optional
            .snapshots();

    /// Combine both streams
    final combinedStream = CombineLatestStream.combine2<
      QuerySnapshot,
      QuerySnapshot,
      List<Map<String, dynamic>>
    >(generalStream, userStream, (generalSnap, userSnap) {
      // Merge docs with collection info
      List<Map<String, dynamic>> allDocs = [
        ...generalSnap.docs.map((d) => {'doc': d, 'isUser': false}),
        ...userSnap.docs.map((d) => {'doc': d, 'isUser': true}),
      ];

      // Sort by createdAt descending
      allDocs.sort((a, b) {
        final aData = a['doc'].data() as Map<String, dynamic>;
        final bData = b['doc'].data() as Map<String, dynamic>;

        // Convert createdAt safely
        DateTime aTime;
        if (aData['createdAt'] is Timestamp) {
          aTime = (aData['createdAt'] as Timestamp).toDate();
        } else if (aData['createdAt'] is DateTime) {
          aTime = aData['createdAt'] as DateTime;
        } else {
          aTime = DateTime(0);
        }

        DateTime bTime;
        if (bData['createdAt'] is Timestamp) {
          bTime = (bData['createdAt'] as Timestamp).toDate();
        } else if (bData['createdAt'] is DateTime) {
          bTime = bData['createdAt'] as DateTime;
        } else {
          bTime = DateTime(0);
        }

        return bTime.compareTo(aTime); // newest first
      });

      // Update unread count
      int count = allDocs.where((d) => d['doc']['isRead'] == false).length;
      unreadCount.value = count;

      return allDocs;
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F5F9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0D141C)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Color(0xFF0D141C),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          ValueListenableBuilder<int>(
            valueListenable: unreadCount,
            builder:
                (context, value, _) => Stack(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.notifications,
                        color: Colors.black,
                      ),
                      onPressed: () {},
                    ),
                    if (value > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$value',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tabs
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                categories.length,
                (index) => _buildTab(
                  categories[index].replaceAll('_', ' ').capitalize(),
                  index,
                ),
              ),
            ),
          ),
          const Divider(height: 0, color: Color(0xFFCEDAE8)),

          // Combined Stream
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: combinedStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No notifications found"));
                }

                final docs = snapshot.data!;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final docMap = docs[index];
                    final doc = docMap['doc'] as QueryDocumentSnapshot;
                    final data = doc.data() as Map<String, dynamic>;
                    bool isRead = data['isRead'] ?? false;

                    // Format createdAt
                    String dateTimeString = '';
                    if (data['createdAt'] != null &&
                        data['createdAt'] is Timestamp) {
                      DateTime dateTime =
                          (data['createdAt'] as Timestamp).toDate();
                      dateTimeString = DateFormat(
                        'yyyy-MM-dd HH:mm',
                      ).format(dateTime);
                    }

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          data['image'] ?? '',
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  const Icon(Icons.image_not_supported),
                        ),
                      ),
                      title: Text(
                        data['title'] ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color:
                              !isRead
                                  ? const Color.fromARGB(255, 250, 31, 15)
                                  : const Color(0xFF0D141C),
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['subtitle'] ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  !isRead
                                      ? const Color.fromARGB(255, 0, 0, 0)
                                      : const Color(0xFF49709C),
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (dateTimeString.isNotEmpty)
                            Text(
                              dateTimeString,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                      onTap: () async {
                        if (!isRead) {
                          await doc.reference.update({"isRead": true});
                        }
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

  Widget _buildTab(String title, int index) {
    bool isSelected = selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => selectedTabIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              color:
                  isSelected
                      ? const Color(0xFF0D141C)
                      : const Color(0xFF49709C),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 3,
            width: 60,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF0D78F2) : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

extension StringCasingExtension on String {
  String capitalize() => "${this[0].toUpperCase()}${substring(1)}";
}
