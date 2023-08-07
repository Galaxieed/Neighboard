import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:neighboard/models/user_model.dart';

class RegisterFunction {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<bool> createAccout(
    String email,
    String password,
    String firstName,
    String lastName,
    String username,
  ) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        _saveUserDetails(
          email: email,
          firstName: firstName,
          lastName: lastName,
          username: username,
        );
        return true;
      } else {
        return false;
      }
    } catch (e) {
      // the error is in e variable
      return false;
    }
  }

  static Future<void> _saveUserDetails({
    required String email,
    required String firstName,
    required String lastName,
    required String username,
  }) async {
    try {
      String userId = _auth.currentUser!.uid;
      UserModel userModel = UserModel(
        userId: userId,
        firstName: firstName,
        lastName: lastName,
        username: username,
        email: email,
        socialMediaLinks: [],
        rank: 0,
        posts: 0,
        profilePicture: "",
      );
      await _firestore.collection("users").doc(userId).set(userModel.toJson());
    } catch (e) {
      return;
    }
  }
}
