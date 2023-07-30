import 'package:firebase_auth/firebase_auth.dart';

class RegisterFunction {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<bool> createAccout(String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
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
}
