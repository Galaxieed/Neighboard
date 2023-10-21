import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:neighboard/models/notification_model.dart';

class NotificationFunction {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> addNotification(
      NotificationModel notificationModel, otherUserId) async {
    try {
      await _firestore.collection("notifications").doc(otherUserId).set({
        "user_id": otherUserId,
      }, SetOptions(merge: true));

      await _firestore
          .collection("notifications")
          .doc(otherUserId)
          .collection("all")
          .doc(notificationModel.notifId)
          .set(notificationModel.toJson());

      await _firestore.runTransaction((transaction) async {});
    } catch (e) {
      print("ADDNOTIF: $e");
    }
  }

  static Future<List<NotificationModel>?> getAllNotification() async {
    try {
      final result = await _firestore
          .collection("notifications")
          .doc(_auth.currentUser!.uid)
          .collection("all")
          .get();

      List<NotificationModel> notificationModels = [];

      notificationModels =
          result.docs.map((e) => NotificationModel.fromJson(e.data())).toList();

      return notificationModels;
    } catch (e) {
      return null;
    }
  }

  static Future<void> readAllNotification() async {
    try {
      final result = _firestore
          .collection("notifications")
          .doc(_auth.currentUser!.uid)
          .collection("all");

      result.get().then((value) {
        for (var element in value.docs) {
          result.doc(element.id).update({"isRead": true});
        }
      });
    } catch (e) {
      return;
    }
  }

  static Future<void> archiveAllNotification() async {
    try {
      final result = _firestore
          .collection("notifications")
          .doc(_auth.currentUser!.uid)
          .collection("all");

      result.get().then((value) {
        for (var element in value.docs) {
          result.doc(element.id).update({"isArchived": true});
        }
      });
    } catch (e) {
      return;
    }
  }

  static Future<void> readNotification(notificationId) async {
    try {
      final result = _firestore
          .collection("notifications")
          .doc(_auth.currentUser!.uid)
          .collection("all")
          .doc(notificationId);

      result.update({"isRead": true});
    } catch (e) {
      return;
    }
  }

  static Future<void> archiveNotification(notificationId) async {
    try {
      final result = _firestore
          .collection("notifications")
          .doc(_auth.currentUser!.uid)
          .collection("all")
          .doc(notificationId);

      result.update({"isArchived": true});
    } catch (e) {
      return;
    }
  }
}
