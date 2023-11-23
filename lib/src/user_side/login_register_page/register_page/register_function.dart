import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:neighboard/models/user_model.dart';
import 'package:neighboard/screen_direct.dart';

class RegisterFunction {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<String> registerUser(String email, String password) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return "true";
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    }
  }

  static Future<bool> userExists(String username) async => (await _firestore
          .collection("users")
          .where("username", isEqualTo: username)
          .get())
      .docs
      .isNotEmpty;

  static Future<void> sendEmailVerification() async {
    User? user = FirebaseAuth.instance.currentUser;
    await user?.sendEmailVerification();
  }

  static Future<bool> checkEmailVerification() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await user.reload();
      user = FirebaseAuth.instance.currentUser; // Refresh the user data
      if (user == null) return false;
      if (user.emailVerified) {
        // User's email is verified
        print('Email is verified');
        return true;
      } else {
        // User's email is not verified
        user.delete();
        print('Email is not verified');
        return false;
      }
    } else {
      return false;
    }
  }

  static Future<bool> saveUserDetails({
    required String email,
    required String firstName,
    required String lastName,
    required String suffix,
    required String username,
    required String gender,
    required String address,
    required String cNo,
  }) async {
    try {
      String userId = _auth.currentUser!.uid;
      UserModel userModel = UserModel(
        userId: userId,
        firstName: firstName,
        lastName: lastName,
        suffix: suffix,
        username: username,
        gender: gender,
        email: email,
        address: address,
        contactNo: cNo,
        socialMediaLinks: [],
        rank: 0,
        posts: 0,
        profilePicture: "",
        role: "USER",
        deviceToken: myToken,
      );
      await _firestore.collection("users").doc(userId).set(userModel.toJson());

      //await enrollPhoneNumber(userModel.contactNo);
      return true;
    } catch (e) {
      return false;
    }
  }
}
