class ReplyModel {
  late String replyId;
  late String senderId;
  late String senderName;
  late String recipientId;
  late String recipientName;
  late String replyMessage;

  ReplyModel({
    required this.replyId,
    required this.senderId,
    required this.senderName,
    required this.recipientId,
    required this.recipientName,
    required this.replyMessage,
  });

  ReplyModel.fromJson(Map<String, dynamic> json) {
    replyId = json['reply_id'];
    senderId = json['sender_id'];
    senderName = json['sender_name'];
    recipientId = json['recipient_id'];
    recipientName = json['recipient_name'];
    replyMessage = json['reply_message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['reply_id'] = replyId;
    data['sender_id'] = senderId;
    data['sender_name'] = senderName;
    data['recipient_id'] = recipientId;
    data['recipient_name'] = recipientName;
    data['reply_message'] = replyMessage;
    return data;
  }
}
