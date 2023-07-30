import 'package:firebase_auth/firebase_auth.dart';

class LoginFunction {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<bool> login(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      // the error is in e variable
      return false;
    }
  }

  static Future<void> logout() async {
    await _auth.signOut();
  }
}
