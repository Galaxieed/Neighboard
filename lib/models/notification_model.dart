class NotificationModel {
  late String notifId;
  late String notifTitle;
  late String notifBody;
  late String notifTime;
  late String notifLocation;
  late bool isRead;
  late bool isArchived;

  NotificationModel({
    required this.notifId,
    required this.notifTitle,
    required this.notifBody,
    required this.notifTime,
    required this.notifLocation,
    required this.isRead,
    required this.isArchived,
  });

  NotificationModel.fromJson(Map<String, dynamic> json) {
    notifId = json['notif_id'];
    notifTitle = json['notif_title'];
    notifBody = json['notif_body'];
    notifTime = json['notif_time'];
    notifLocation = json['notif_location'];
    isRead = json['isRead'];
    isArchived = json['isArchived'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['notif_id'] = notifId;
    data['notif_title'] = notifTitle;
    data['notif_body'] = notifBody;
    data['notif_time'] = notifTime;
    data['notif_location'] = notifLocation;
    data['isRead'] = isRead;
    data['isArchived'] = isArchived;
    return data;
  }
}
