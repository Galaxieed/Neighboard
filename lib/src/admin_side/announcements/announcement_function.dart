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
}
