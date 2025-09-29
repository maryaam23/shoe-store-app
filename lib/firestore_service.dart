import 'package:cloud_firestore/cloud_firestore.dart';
import 'User_Pages/product_page.dart'; // Product model
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final String userId = FirebaseAuth.instance.currentUser!.uid;

  // ------------------ CART ------------------ //
  static Future<void> addToCart(Product product) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = _db.collection("users").doc(user.uid);

    await userDoc.collection("cart").doc(product.id).set({
      "name": product.name,
      "price": product.price,
      "image": product.image, // ✅ keep image field
      "quantity": 1,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  // In firestore_service.dart
  static Future<void> removeFromCart(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid);

    await userDoc.collection("cart").doc(productId).delete();
  }

  // ------------------ CART STREAM ------------------ //
static Stream<QuerySnapshot> getCart() {
  return _db
      .collection("users")
      .doc(userId)
      .collection("cart")
      .orderBy("createdAt", descending: true)
      .snapshots();
}


  // ------------------ WISHLIST ------------------ //
  static Future<void> addToWishlist(Product product) async {
    await _db
        .collection("users")
        .doc(userId)
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
    await _db
        .collection("users")
        .doc(userId)
        .collection("wishlist")
        .doc(productId)
        .delete();
  }

  static Stream<QuerySnapshot> getWishlist() {
    return _db
        .collection("users")
        .doc(userId)
        .collection("wishlist")
        .orderBy("createdAt", descending: true)
        .snapshots();
  }
}
