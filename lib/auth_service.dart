import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';



class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ Email Signup
  Future<User?> signUpWithEmail(String email, String password) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  // ✅ Email Login
  Future<User?> signInWithEmail(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  // ✅ Google Sign-In (Android, iOS, Windows)
  Future<User?> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null; // user canceled

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print("❌ Google sign-in error: $e");
      return null;
    }
  }

  Future<User?> signInWithFacebook() async {
  try {
    // Trigger the sign-in flow
    final LoginResult result = await FacebookAuth.instance.login();

    if (result.status == LoginStatus.success) {
      // Get the access token
      final AccessToken accessToken = result.accessToken!;

      // Create a credential for Firebase
      final OAuthCredential credential =
          FacebookAuthProvider.credential(accessToken.tokenString);

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } else {
      print("Facebook login failed: ${result.status}");
      return null;
    }
  } catch (e) {
    print("Error during Facebook login: $e");
    return null;
  }
}


  // ✅ Logout from all providers
  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
    await FacebookAuth.instance.logOut();
  }
}