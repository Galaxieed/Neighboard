class ChatModel {
  late String chatId;
  late String senderId;
  late String senderName;
  late String message;
  late String timestamp;

  ChatModel({
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
  });

  ChatModel.fromJson(Map<String, dynamic> json) {
    chatId = json['chat_id'];
    senderId = json['sender_id'];
    senderName = json['sender_name'];
    message = json['message'];
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['chat_id'] = chatId;
    data['sender_id'] = senderId;
    data['sender_name'] = senderName;
    data['message'] = message;
    data['timestamp'] = timestamp;
    return data;
  }
}
