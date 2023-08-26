import 'package:firebase_auth/firebase_auth.dart';

class LoginFunction {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<String> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return "true";
    } on FirebaseAuthException catch (e) {
      String err = e.message
          .toString()
          .split("/")[1]
          .split(")")[0]
          .replaceAll(RegExp(r'-'), ' ');
      err = err.substring(0, 1).toUpperCase() + err.substring(1);
      if (err == 'User not found') {
        return err;
      } else if (err == 'Wrong password') {
        return err;
      } else {
        return err;
      }
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
