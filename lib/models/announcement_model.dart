class AnnouncementModel {
  String announcementId;
  String title;
  String details;
  String timeStamp;
  String image;
  bool isMainAnnouncement;

  AnnouncementModel({
    required this.announcementId,
    required this.title,
    required this.details,
    required this.timeStamp,
    required this.image,
    required this.isMainAnnouncement,
  });
}
