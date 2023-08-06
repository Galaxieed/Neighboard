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

  // static Future<void> getUserDetails() async {
  //   try {
  //     final result = await _firestore
  //         .collection("users")
  //         .doc(_auth.currentUser!.uid)
  //         .get();

  //     UserModel userModel = UserModel.fromJson(result.data()!);

  //     await SharedPrefHelper.saveString(key: "userId", value: userModel.userId);
  //     await SharedPrefHelper.saveString(
  //         key: "username", value: userModel.username);
  //     await SharedPrefHelper.saveString(
  //         key: "profile_picture", value: userModel.profilePicture);
  //   } catch (e) {
  //     return;
  //   }
  // }
}
