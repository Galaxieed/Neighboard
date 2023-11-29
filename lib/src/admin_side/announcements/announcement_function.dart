import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neighboard/models/announcement_model.dart';

class AnnouncementFunction {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<bool> addAnnouncement(
      AnnouncementModel announcementModel) async {
    try {
      await _firestore
          .collection("announcements")
          .doc(announcementModel.announcementId)
          .set(announcementModel.toJson());

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<List<AnnouncementModel>?> getAllAnnouncements() async {
    try {
      final result = await _firestore.collection("announcements").get();
      List<AnnouncementModel> announcementModel = [];
      announcementModel =
          result.docs.map((e) => AnnouncementModel.fromJson(e.data())).toList();

      return announcementModel;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> removeAnnouncement(
      AnnouncementModel announcementModel) async {
    try {
      //transfer first
      await _firestore
          .collection("archived_announcements")
          .doc(announcementModel.announcementId)
          .set(announcementModel.toJson())
          .then((value) async {
        //remove announcement
        await _firestore
            .collection("announcements")
            .doc(announcementModel.announcementId)
            .delete();
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> retrieveArchivedAnnouncement(
      AnnouncementModel announcementModel) async {
    try {
      //transfer first
      await _firestore
          .collection("announcements")
          .doc(announcementModel.announcementId)
          .set(announcementModel.toJson())
          .then((value) async {
        //remove archived announcement
        await _firestore
            .collection("archived_announcements")
            .doc(announcementModel.announcementId)
            .delete();
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<List<AnnouncementModel>?> getArchivedAnnouncements() async {
    try {
      final result =
          await _firestore.collection("archived_announcements").get();
      List<AnnouncementModel> announcement = [];
      announcement =
          result.docs.map((e) => AnnouncementModel.fromJson(e.data())).toList();
      return announcement;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> updateAnnouncement(
      String announcementId, String title, String content) async {
    try {
      //update
      await _firestore
          .collection("announcements")
          .doc(announcementId)
          .update({"title": title, "details": content});
      return true;
    } catch (e) {
      return false;
    }
  }
}
