import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neighboard/models/chatmessage_model.dart';

class ChatFunction {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> sendChat(ChatModel chatModel) async {
    try {
      await _firestore
          .collection("chats")
          .doc(chatModel.chatId)
          .set(chatModel.toJson());
    } catch (e) {
      return;
    }
  }
}
