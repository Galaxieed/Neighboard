import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:neighboard/models/user_model.dart';

class LoginFunction {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<String> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final result = await _firestore
          .collection("users")
          .doc(_auth.currentUser!.uid)
          .get();
      UserModel userModel = UserModel.fromJson(result.data()!);

      if (userModel.role == "ADMIN") {
        return "ADMIN";
      }

      return "USER";
    } on FirebaseAuthException catch (e) {
      String err = e.message.toString();
      return err;
    }
  }

  static Future<void> logout() async {
    await _auth.signOut();
  }

  static Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }
}
