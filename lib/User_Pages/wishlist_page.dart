import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firestore_service.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaWidth = MediaQuery.of(context).size.width;
    final mediaHeight = MediaQuery.of(context).size.height;

    double fontSize(double size) => size * mediaWidth / 375;
    double verticalSpace(double size) => size * mediaHeight / 812;
    double horizontalSpace(double size) => size * mediaWidth / 375;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService.getWishlist(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "Your wishlist is empty ❤️",
                style: TextStyle(fontSize: fontSize(16), color: Colors.black54),
              ),
            );
          }

          final items = snapshot.data!.docs;

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalSpace(16),
                  vertical: verticalSpace(4),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "${items.length} items",
                    style: TextStyle(
                      fontSize: fontSize(16),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0D141C),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder:
                      (_, __) => Divider(
                        height: verticalSpace(1),
                        color: const Color(0xFFE7EDF4),
                      ),
                  itemBuilder: (context, index) {
                    final item = items[index].data() as Map<String, dynamic>;
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: horizontalSpace(16),
                        vertical: verticalSpace(8),
                      ),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(horizontalSpace(8)),
                        child:
                            item["image"] != null
                                ? item["image"].startsWith('http')
                                    ? Image.network(
                                      item["image"],
                                      width: horizontalSpace(56),
                                      height: verticalSpace(56),
                                      fit: BoxFit.cover,
                                    )
                                    : Image.file(
                                      File(item["image"]),
                                      width: horizontalSpace(56),
                                      height: verticalSpace(56),
                                      fit: BoxFit.cover,
                                    )
                                : Container(
                                  width: horizontalSpace(56),
                                  height: verticalSpace(56),
                                  color: Colors.grey.shade200,
                                  child: Icon(
                                    Icons.image,
                                    color: Colors.grey,
                                    size: fontSize(28),
                                  ),
                                ),
                      ),
                      title: Text(
                        item["name"] ?? "",
                        style: TextStyle(
                          fontSize: fontSize(16),
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF0D141C),
                        ),
                      ),
                      subtitle: Text(
                        "₪${(item["price"] ?? 0).toString()}",
                        style: TextStyle(
                          fontSize: fontSize(14),
                          color: const Color(0xFF49709C),
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: fontSize(24),
                        ),
                        onPressed: () async {
                          await FirestoreService.removeFromWishlist(item["id"]);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
