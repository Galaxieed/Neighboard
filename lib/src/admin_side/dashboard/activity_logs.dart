import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neighboard/models/notification_model.dart';

class ActivityLogsFunction {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> addLogs(NotificationModel model) async {
    try {
      await _firestore
          .collection("admin_logs")
          .doc(model.notifId)
          .set(model.toJson());
    } catch (e) {
      return;
    }
  }

  static Future<List<NotificationModel>?> getLogs() async {
    try {
      final result = await _firestore.collection("admin_logs").get();
      List<NotificationModel> logs = [];
      logs =
          result.docs.map((e) => NotificationModel.fromJson(e.data())).toList();
      return logs;
    } catch (e) {
      return null;
    }
  }
}
