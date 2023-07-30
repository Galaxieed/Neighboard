import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:neighboard/models/user_model.dart';

class ProfileFunction {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<UserModel?> getUserDetails() async {
    try {
      final result = await _firestore
          .collection("users")
          .doc(_auth.currentUser!.uid)
          .get();
      UserModel userModel = UserModel.fromJson(result.data()!);

      return userModel;
    } catch (e) {
      print(e);
      return null;
    }
  }
}
