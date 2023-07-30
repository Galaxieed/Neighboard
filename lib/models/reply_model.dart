import 'package:neighboard/models/comment_model.dart';
import 'package:neighboard/models/post_model.dart';

class ReplyModel {
  String replyId;
  String senderId;
  String senderName;
  String recipientId;
  String recipientName;
  String replyMessage;

  ReplyModel({
    required this.replyId,
    required this.senderId,
    required this.senderName,
    required this.recipientId,
    required this.recipientName,
    required this.replyMessage,
  });
}

addReplyData(PostModel post, commentId, ReplyModel reply) {
  for (CommentModel comment in post.comments) {
    if (comment.commentId == commentId) {
      comment.replies.add(reply);
      break;
    }
  }
}
