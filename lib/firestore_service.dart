import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'User_Pages/product_page.dart'; // Product model
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ------------------ CART ------------------ //
  static Future<void> addToCart(
    Product product, {
    required int size,
    required Color color,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = _db.collection("users").doc(user.uid);

    await userDoc.collection("cart").doc(product.id).set({
      "id": product.id,
      "name": product.name,
      "price": product.price,
      "image": product.image,
      "quantity": 1,
      "size": size,
      "color": color.value, // save color as int
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  static Future<void> removeFromCart(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = _db.collection("users").doc(user.uid);
    await userDoc.collection("cart").doc(productId).delete();
  }

  static Future<bool> isInCart(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final doc = await _db
        .collection("users")
        .doc(user.uid)
        .collection("cart")
        .doc(productId)
        .get();

    return doc.exists;
  }

  static Stream<QuerySnapshot> getCart() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // 🔹 Return empty stream for guest users
      return const Stream.empty();
    }

    return _db
        .collection("users")
        .doc(user.uid)
        .collection("cart")
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  // ------------------ UPDATE CART SIZE & COLOR ------------------ //
  static Future<void> updateCartSize(String productId, int newSize) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _db
        .collection("users")
        .doc(user.uid)
        .collection("cart")
        .doc(productId)
        .update({"size": newSize});
  }

  static Future<void> updateCartColor(String productId, Color newColor) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _db
        .collection("users")
        .doc(user.uid)
        .collection("cart")
        .doc(productId)
        .update({"color": newColor.value});
  }

  // ------------------ 🆕 ADD OR UPDATE CART ITEM ------------------ //
  static Future<void> addOrUpdateCart(
    Product product, {
    required int size,
    required Color color,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userId = user.uid;
    final colorValue = color.value;

    // Check if same product with same size & color already exists
    final query = await _db
        .collection('users')
        .doc(userId)
        .collection('cart')
        .where('id', isEqualTo: product.id)
        .where('size', isEqualTo: size)
        .where('color', isEqualTo: colorValue)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      // 🟢 If same item exists → increase quantity
      final doc = query.docs.first;
      await doc.reference.update({
        'quantity': FieldValue.increment(1),
      });
    } else {
      // 🟧 Else add new entry
      await _db
          .collection('users')
          .doc(userId)
          .collection('cart')
          .add({
        'id': product.id,
        'name': product.name,
        'price': product.price,
        'image': product.image,
        'size': size,
        'color': colorValue,
        'quantity': 1,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // ------------------ WISHLIST ------------------ //
  static Future<void> addToWishlist(Product product) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _db
        .collection("users")
        .doc(user.uid)
        .collection("wishlist")
        .doc(product.id)
        .set({
      "id": product.id,
      "name": product.name,
      "price": product.price,
      "image": product.image,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  static Future<void> removeFromWishlist(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _db
        .collection("users")
        .doc(user.uid)
        .collection("wishlist")
        .doc(productId)
        .delete();
  }

  static Future<bool> isInWishlist(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final doc = await _db
        .collection("users")
        .doc(user.uid)
        .collection("wishlist")
        .doc(productId)
        .get();

    return doc.exists;
  }

  static Stream<QuerySnapshot> getWishlist() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // 🔹 Return empty stream for guest users
      return const Stream.empty();
    }

    return _db
        .collection("users")
        .doc(user.uid)
        .collection("wishlist")
        .orderBy("createdAt", descending: true)
        .snapshots();
  }
}
