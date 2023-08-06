class CommentModel {
  late String commentId;
  late String senderId;
  late String senderProfilePicture;
  late String senderName;
  late String timeStamp;
  late String commentMessage;
  late int noOfLikes;
  late int noOfDislikes;
  late int noOfReplies;

  CommentModel({
    required this.commentId,
    required this.senderId,
    required this.senderProfilePicture,
    required this.senderName,
    required this.timeStamp,
    required this.commentMessage,
    required this.noOfLikes,
    required this.noOfDislikes,
    required this.noOfReplies,
  });

  CommentModel.fromJson(Map<String, dynamic> json) {
    commentId = json['comment_id'];
    senderId = json['sender_id'];
    senderProfilePicture = json['sender_profile_picture'];
    senderName = json['sender_name'];
    timeStamp = json['time_stamp'];
    commentMessage = json['comment_message'];
    noOfLikes = json['no_of_likes'];
    noOfDislikes = json['no_of_dislikes'];
    noOfReplies = json['no_of_replies'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['comment_id'] = commentId;
    data['sender_id'] = senderId;
    data['sender_profile_picture'] = senderProfilePicture;
    data['sender_name'] = senderName;
    data['time_stamp'] = timeStamp;
    data['comment_message'] = commentMessage;
    data['no_of_likes'] = noOfLikes;
    data['no_of_dislikes'] = noOfDislikes;
    data['no_of_replies'] = noOfReplies;
    return data;
  }
}
