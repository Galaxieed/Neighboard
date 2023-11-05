import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:neighboard/models/candidates_model.dart';
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

  static Future<SiteModel?> getSiteSettings(docId) async {
    try {
      final result =
          await _firestore.collection("site_settings").doc(docId).get();
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

  static Future<void> setOfficers({
    required String adminId,
    required CandidateModel pres,
    required CandidateModel vp,
    required CandidateModel sec,
    required CandidateModel astSec,
    required CandidateModel tres,
    required CandidateModel aud,
    required CandidateModel astAud,
    required List<CandidateModel> bod,
  }) async {
    try {
      await _firestore
          .collection("site_settings")
          .doc(adminId)
          .collection("officers")
          .doc("president")
          .set(pres.toJson());
      await _firestore
          .collection("site_settings")
          .doc(adminId)
          .collection("officers")
          .doc("vice_president")
          .set(vp.toJson());
      await _firestore
          .collection("site_settings")
          .doc(adminId)
          .collection("officers")
          .doc("secretary")
          .set(sec.toJson());
      await _firestore
          .collection("site_settings")
          .doc(adminId)
          .collection("officers")
          .doc("assistant_secretary")
          .set(astSec.toJson());
      await _firestore
          .collection("site_settings")
          .doc(adminId)
          .collection("officers")
          .doc("treasurer")
          .set(tres.toJson());
      await _firestore
          .collection("site_settings")
          .doc(adminId)
          .collection("officers")
          .doc("auditor")
          .set(aud.toJson());
      await _firestore
          .collection("site_settings")
          .doc(adminId)
          .collection("officers")
          .doc("assistant_auditor")
          .set(astAud.toJson());
      await _firestore
          .collection("site_settings")
          .doc(adminId)
          .collection("officers")
          .doc("bod_1")
          .set(bod[0].toJson());
      await _firestore
          .collection("site_settings")
          .doc(adminId)
          .collection("officers")
          .doc("bod_2")
          .set(bod[1].toJson());
      await _firestore
          .collection("site_settings")
          .doc(adminId)
          .collection("officers")
          .doc("bod_3")
          .set(bod[2].toJson());
      await _firestore
          .collection("site_settings")
          .doc(adminId)
          .collection("officers")
          .doc("bod_4")
          .set(bod[3].toJson());
      await _firestore
          .collection("site_settings")
          .doc(adminId)
          .collection("officers")
          .doc("bod_5")
          .set(bod[4].toJson());
      await _firestore
          .collection("site_settings")
          .doc(adminId)
          .collection("officers")
          .doc("bod_6")
          .set(bod[5].toJson());
      await _firestore
          .collection("site_settings")
          .doc(adminId)
          .collection("officers")
          .doc("bod_7")
          .set(bod[6].toJson());
      await _firestore
          .collection("site_settings")
          .doc(adminId)
          .collection("officers")
          .doc("bod_8")
          .set(bod[7].toJson());
    } catch (e) {
      print(e);
      return;
    }
  }

  static Future<void> updateOfficers(
      String doc,
      Map<String, dynamic> officerDetails,
      String electionId,
      String candidateId) async {
    try {
      await _firestore
          .collection("election")
          .doc(electionId)
          .collection("candidates")
          .doc(candidateId)
          .update(officerDetails);
      await _firestore
          .collection("site_settings")
          .doc(_auth.currentUser!.uid)
          .collection("officers")
          .doc(doc)
          .update(officerDetails);
    } catch (e) {
      return;
    }
  }

  static Future<List<CandidateModel>?> getOfficers(String adminId) async {
    try {
      final result = await _firestore
          .collection("site_settings")
          .doc(adminId)
          .collection("officers")
          .get();
      List<CandidateModel> officersModel = [];
      officersModel =
          result.docs.map((e) => CandidateModel.fromJson(e.data())).toList();
      return officersModel;
    } catch (e) {
      return null;
    }
  }

  static Future<void> deleteOfficers(String adminId) async {
    try {
      final officersRef = _firestore
          .collection("site_settings")
          .doc(adminId)
          .collection("officers");

      final snapshots = await officersRef.get();
      for (var doc in snapshots.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print(e);
      return;
    }
  }
}
