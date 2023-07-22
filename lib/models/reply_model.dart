import 'package:neighboard/models/comment_model.dart';
import 'package:neighboard/models/post_model.dart';

class ReplyModel {
  String replyId;
  String senderId;
  String senderName;
  String recipientId;
  String recipientName;
  String replyMessage;
  List<ReplyModel> replies;

  ReplyModel({
    required this.replyId,
    required this.senderId,
    required this.senderName,
    required this.recipientId,
    required this.recipientName,
    required this.replyMessage,
    required this.replies,
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

addNestedReplyData(PostModel post, commentId, replyId, ReplyModel reply) {
  for (CommentModel comment in post.comments) {
    if (comment.commentId == commentId) {
      for(ReplyModel reply in comment.replies) {
        if (reply.replyId == replyId) {
          reply.replies.add(reply);
          break;
        }
      }
      break;
    }
  }
}