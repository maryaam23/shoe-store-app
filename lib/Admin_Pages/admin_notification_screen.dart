import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminNotificationScreen extends StatefulWidget {
  const AdminNotificationScreen({super.key});

  @override
  State<AdminNotificationScreen> createState() =>
      _AdminNotificationScreenState();
}

class _AdminNotificationScreenState extends State<AdminNotificationScreen> {
  int selectedTabIndex = 0;

  final List<String> categories = ["new_order", "user_message", "system_alert"];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    double textScale(double value) => value * (width / 375);
    double paddingScale(double value) => value * (width / 375);
    double imageScale(double value) => value * (width / 375);

    String selectedCategory = categories[selectedTabIndex];

    final adminStream =
        FirebaseFirestore.instance
            .collection("admin_noti")
            .where("category", isEqualTo: selectedCategory)
            .snapshots();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F5F9),
        elevation: 1,
        shadowColor: Colors.grey.withOpacity(0.3),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: const Color(0xFF0D141C),
            size: textScale(24),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Admin Notifications',
          style: TextStyle(
            color: const Color(0xFF0D141C),
            fontWeight: FontWeight.bold,
            fontSize: textScale(20),
          ),
        ),
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('admin_noti')
                    .where('category', isEqualTo: categories[selectedTabIndex])
                    .where('isRead', isEqualTo: false)
                    .snapshots(),
            builder: (context, snapshot) {
              int unreadCount = 0;
              if (snapshot.hasData) {
                unreadCount = snapshot.data!.docs.length;
              }

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.black),
                    onPressed: () {},
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 3,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          '$unreadCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tabs
          Container(
            padding: EdgeInsets.symmetric(vertical: paddingScale(10)),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                categories.length,
                (index) => _buildTab(
                  categories[index].replaceAll('_', ' ').capitalize(),
                  index,
                  textScale,
                  paddingScale,
                ),
              ),
            ),
          ),
          const Divider(height: 0, color: Color(0xFFCEDAE8)),

          // Notifications Stream
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: adminStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No notifications found",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  padding: EdgeInsets.all(paddingScale(12)),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    bool isRead = data['isRead'] ?? false;

                    String dateTimeString = '';
                    if (data['createdAt'] != null &&
                        data['createdAt'] is Timestamp) {
                      DateTime dateTime =
                          (data['createdAt'] as Timestamp).toDate();
                      dateTimeString = DateFormat(
                        'yyyy-MM-dd HH:mm',
                      ).format(dateTime);
                    }

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: paddingScale(6)),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(paddingScale(14)),
                      ),
                      shadowColor: Colors.black.withOpacity(0.15),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(paddingScale(14)),
                        onTap: () async {
                          if (!isRead) {
                            await doc.reference.update({"isRead": true});
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(paddingScale(12)),
                          child: Row(
                            children: [
                              // Left: Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  paddingScale(12),
                                ),
                                child: Image.network(
                                  data['image'] ?? '',
                                  width: imageScale(60),
                                  height: imageScale(60),
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) => Icon(
                                        Icons.image_not_supported,
                                        size: imageScale(40),
                                        color: Colors.grey.shade400,
                                      ),
                                ),
                              ),
                              SizedBox(width: paddingScale(12)),

                              // Right: Text content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title + Unread badge
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            data['title'] ?? '',
                                            style: TextStyle(
                                              fontSize: textScale(16),
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  !isRead
                                                      ? Colors.redAccent
                                                      : Colors.black87,
                                            ),
                                          ),
                                        ),
                                        if (!isRead)
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: paddingScale(6),
                                              vertical: paddingScale(2),
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.redAccent,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              'NEW',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: textScale(10),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),

                                    SizedBox(height: paddingScale(6)),

                                    // Subtitle
                                    Text(
                                      data['subtitle'] ?? '',
                                      style: TextStyle(
                                        fontSize: textScale(14),
                                        height: 1.3,
                                        color:
                                            !isRead
                                                ? Colors.black87
                                                : Colors.blueGrey,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),

                                    SizedBox(height: paddingScale(8)),

                                    // Timestamp + Category Indicator
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          dateTimeString,
                                          style: TextStyle(
                                            fontSize: textScale(12),
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        // Category color indicator
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: paddingScale(8),
                                            vertical: paddingScale(4),
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getCategoryColor(
                                              data['category'],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            data['category']
                                                    ?.toString()
                                                    .replaceAll('_', ' ')
                                                    .capitalize() ??
                                                '',
                                            style: TextStyle(
                                              fontSize: textScale(10),
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
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

  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'new_order':
        return Colors.green;
      case 'user_message':
        return Colors.blue;
      case 'system_alert':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildTab(
    String title,
    int index,
    double Function(double) textScale,
    double Function(double) paddingScale,
  ) {
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
              fontSize: textScale(14),
            ),
          ),
          SizedBox(height: paddingScale(4)),
          Container(
            height: paddingScale(3),
            width: paddingScale(60),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF0D78F2) : Colors.transparent,
              borderRadius: BorderRadius.circular(paddingScale(2)),
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
