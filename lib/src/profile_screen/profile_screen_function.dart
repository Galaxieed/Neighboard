import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:neighboard/models/user_model.dart';
import 'package:universal_io/io.dart';

class ProfileFunction {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static Future<UserModel?> getUserDetails(String userId) async {
    try {
      final result = await _firestore.collection("users").doc(userId).get();
      UserModel userModel = UserModel.fromJson(result.data()!);

      return userModel;
    } catch (e) {
      return null;
    }
  }

  static Future<void> updateUserProfile(
      Map<String, dynamic> userDetails) async {
    try {
      await _firestore
          .collection("users")
          .doc(_auth.currentUser!.uid)
          .update(userDetails);
    } catch (e) {
      //catch error
    }
  }

  static Future<String?> uploadImage(File? imageFile) async {
    try {
      final reference =
          _storage.ref().child("images/${DateTime.now().toIso8601String()}");

      final uploadTask = reference.putFile(imageFile!);

      await uploadTask.whenComplete(() {});

      String downloadUrl = await reference.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> uploadImageWeb(
      Uint8List bytes, String filename, String fileExtension) async {
    try {
      final reference = _storage
          .ref()
          .child('images/$filename-${DateTime.now().toIso8601String()}');

      final uploadTask = reference.putData(
        bytes,
        SettableMetadata(contentType: 'image/$fileExtension'.toLowerCase()),
      );

      await uploadTask.whenComplete(() {});

      String downloadUrl = await reference.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  static Future<void> changePassword(String newPassword) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await user.updatePassword(newPassword);
        print(newPassword);
      } catch (e) {
        print(e);
        return;
      }
    }
  }
}
