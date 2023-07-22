import 'package:neighboard/models/post_model.dart';
import 'package:neighboard/models/reply_model.dart';

class CommentModel {
  String commentId;
  String senderId;
  String senderName;
  String timeStamp;
  String commentMessage;
  int noOfLikes;
  bool isLiked;
  int noOfDislikes;
  bool isDisliked;
  List<ReplyModel> replies;

  // Constructor
  CommentModel({
    required this.commentId,
    required this.senderId,
    required this.senderName,
    required this.timeStamp,
    required this.commentMessage,
    required this.noOfLikes,
    required this.isLiked,
    required this.noOfDislikes,
    required this.isDisliked,
    required this.replies,
  });
}

addCommentData(PostModel post, CommentModel comment) {
  post.comments.add(comment);
}

triggerLikeComment (PostModel post, commentId) {
  for (CommentModel comment in post.comments) {
    if (comment.commentId == commentId) {
      if (comment.isDisliked) {
        comment.isDisliked = false;
        comment.noOfDislikes -= 1;
      }
      if(comment.isLiked) {
        comment.isLiked = false;
        comment.noOfLikes -= 1;
      } else {
        comment.isLiked = true;
        comment.noOfLikes += 1;
      }
    }
  }
}

triggerDislikeComment (PostModel post, commentId) {
  for (CommentModel comment in post.comments) {
    if (comment.commentId == commentId) {
      if (comment.isLiked) {
        comment.isLiked = false;
        comment.noOfLikes -= 1;
      }
      if(comment.isDisliked) {
        comment.isDisliked = false;
        comment.noOfDislikes -= 1;
      } else {
        comment.isDisliked = true;
        comment.noOfDislikes += 1;
      }
    }
  }
}