import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:intl/intl.dart';

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

  ValueNotifier<int> unreadCount = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    // ======================
    // ✅ Responsive constants
    // ======================
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final isTablet = width > 600;

    // Scaling factors
    double textScale(double value) => value * (width / 375);
    double paddingScale(double value) => value * (width / 375);
    double imageScale(double value) => value * (width / 375);

    String selectedCategory = categories[selectedTabIndex];

    final generalStream =
        FirebaseFirestore.instance
            .collection("UserNotification")
            .where("category", isEqualTo: selectedCategory)
            .orderBy("createdAt", descending: true)
            .snapshots();

    final userStream =
        FirebaseFirestore.instance
            .collection("users")
            .doc(widget.userId)
            .collection("notification")
            .where("category", isEqualTo: selectedCategory)
            .snapshots();

    final combinedStream = CombineLatestStream.combine2<
      QuerySnapshot,
      QuerySnapshot,
      List<Map<String, dynamic>>
    >(generalStream, userStream, (generalSnap, userSnap) {
      List<Map<String, dynamic>> allDocs = [
        ...generalSnap.docs.map((d) => {'doc': d, 'isUser': false}),
        ...userSnap.docs.map((d) => {'doc': d, 'isUser': true}),
      ];

      allDocs.sort((a, b) {
        final aData = a['doc'].data() as Map<String, dynamic>;
        final bData = b['doc'].data() as Map<String, dynamic>;

        DateTime aTime;
        if (aData['createdAt'] is Timestamp) {
          aTime = (aData['createdAt'] as Timestamp).toDate();
        } else if (aData['createdAt'] is DateTime) {
          aTime = aData['createdAt'];
        } else {
          aTime = DateTime(0);
        }

        DateTime bTime;
        if (bData['createdAt'] is Timestamp) {
          bTime = (bData['createdAt'] as Timestamp).toDate();
        } else if (bData['createdAt'] is DateTime) {
          bTime = bData['createdAt'];
        } else {
          bTime = DateTime(0);
        }

        return bTime.compareTo(aTime);
      });

      int count = allDocs.where((d) => d['doc']['isRead'] == false).length;
      unreadCount.value = count;

      return allDocs;
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F5F9),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: const Color(0xFF0D141C),
            size: textScale(22),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Notifications',
          style: TextStyle(
            color: const Color(0xFF0D141C),
            fontWeight: FontWeight.bold,
            fontSize: textScale(18),
          ),
        ),
        actions: [
          ValueListenableBuilder<int>(
            valueListenable: unreadCount,
            builder:
                (context, value, _) => Stack(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.notifications,
                        color: Colors.black,
                        size: textScale(24),
                      ),
                      onPressed: () {},
                    ),
                    if (value > 0)
                      Positioned(
                        right: textScale(6),
                        top: textScale(6),
                        child: Container(
                          padding: EdgeInsets.all(paddingScale(4)),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$value',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: textScale(12),
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
            padding: EdgeInsets.symmetric(vertical: paddingScale(8)),
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
          Divider(height: 0, color: const Color(0xFFCEDAE8)),

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
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: paddingScale(16),
                        vertical: paddingScale(8),
                      ),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(paddingScale(8)),
                        child: Image.network(
                          data['image'] ?? '',
                          width: imageScale(56),
                          height: imageScale(56),
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Icon(
                                Icons.image_not_supported,
                                size: imageScale(40),
                              ),
                        ),
                      ),
                      title: Text(
                        data['title'] ?? '',
                        style: TextStyle(
                          fontSize: textScale(16),
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
                              fontSize: textScale(14),
                              color:
                                  !isRead
                                      ? Colors.black
                                      : const Color(0xFF49709C),
                            ),
                          ),
                          SizedBox(height: paddingScale(4)),
                          if (dateTimeString.isNotEmpty)
                            Text(
                              dateTimeString,
                              style: TextStyle(
                                fontSize: textScale(12),
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
