import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:neighboard/models/site_model.dart';
import 'package:universal_io/io.dart';

class SiteSettingsFunction {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static Future<bool> saveNewSiteSettings(SiteModel siteModel) async {
    try {
      await _firestore
          .collection("site_settings")
          .doc(_auth.currentUser!.uid)
          .set(siteModel.toJson());

      return true;
    } catch (e) {
      print("saveNew : $e");
      return false;
    }
  }

  static Future<void> updateSiteSettings(
      Map<String, dynamic> siteDetails) async {
    try {
      await _firestore
          .collection("site_settings")
          .doc(_auth.currentUser!.uid)
          .update(siteDetails);
    } catch (e) {
      return;
    }
  }

  static Future<SiteModel?> getSiteSettings() async {
    try {
      final result = await _firestore
          .collection("site_settings")
          .doc(_auth.currentUser!.uid)
          .get();
      SiteModel siteModel = SiteModel.fromJson(result.data()!);
      return siteModel;
    } catch (e) {
      return null;
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
}
