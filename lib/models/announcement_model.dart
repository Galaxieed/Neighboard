class AnnouncementModel {
  late String announcementId;
  late String title;
  late String details;
  late String timeStamp;
  late String datePosted;
  late String image;

  AnnouncementModel({
    required this.announcementId,
    required this.title,
    required this.details,
    required this.timeStamp,
    required this.datePosted,
    required this.image,
  });

  AnnouncementModel.fromJson(Map<String, dynamic> json) {
    announcementId = json['announcement_id'];
    title = json['title'];
    details = json['details'];
    timeStamp = json['time_stamp'];
    datePosted = json['date_posted'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['announcement_id'] = announcementId;
    data['title'] = title;
    data['details'] = details;
    data['time_stamp'] = timeStamp;
    data['date_posted'] = datePosted;
    data['image'] = image;
    return data;
  }
}
