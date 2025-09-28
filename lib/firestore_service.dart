import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'User_Pages/product_page.dart'; // for Product model

class FirestoreService {
  static Future<void> addToCart(Product product) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid);

    await userDoc.collection("cart").doc(product.id).set({
      "name": product.name,
      "price": product.price,
      "image": product.image, // ✅ add image field
      "quantity": 1,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  static Future<void> addToWishlist(Product product) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid);

    await userDoc.collection("wishlist").doc(product.id).set({
      "name": product.name,
      "price": product.price,
      "image": product.image, // ✅ add image field
      "createdAt": FieldValue.serverTimestamp(),
    });
  }
}
