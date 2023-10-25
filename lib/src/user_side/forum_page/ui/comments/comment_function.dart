import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:neighboard/models/comment_model.dart';
import 'package:neighboard/models/reply_model.dart';

class CommentFunction {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> postComment({
    required String postId,
    required CommentModel commentModel,
  }) async {
    try {
      //saves the comment
      await _firestore
          .collection("posts")
          .doc(postId)
          .collection("comments")
          .doc(commentModel.commentId)
          .set(commentModel.toJson());

      //updates the number of comments in a post
      final postReference = _firestore.collection("posts").doc(postId);

      await _firestore.runTransaction((transaction) async {
        final post = await transaction.get(postReference);

        int commentsCount = post.data()!['no_of_comments'];

        transaction
            .update(postReference, {"no_of_comments": commentsCount + 1});
      });

      //updates the rank of the user
      final userReference =
          _firestore.collection("users").doc(_auth.currentUser!.uid);

      await _firestore.runTransaction((transaction) async {
        final user = await transaction.get(userReference);

        int rankCount = user.data()!['rank'];

        transaction.update(userReference, {"rank": rankCount + 5});
      });
    } catch (e) {
      return;
    }
  }

  static Future<bool> removeComment({
    required String postId,
    required String commentId,
  }) async {
    try {
      //remove comment
      await _firestore
          .collection("posts")
          .doc(postId)
          .collection("comments")
          .doc(commentId)
          .delete();

      //updates the number of comments in a post
      final postReference = _firestore.collection("posts").doc(postId);

      await _firestore.runTransaction((transaction) async {
        final post = await transaction.get(postReference);

        int commentsCount = post.data()!['no_of_comments'];

        transaction
            .update(postReference, {"no_of_comments": commentsCount - 1});
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateComment({
    required String postId,
    required String commentId,
    required String commentMessage,
  }) async {
    try {
      //updates the comment
      await _firestore
          .collection("posts")
          .doc(postId)
          .collection("comments")
          .doc(commentId)
          .update({"comment_message": commentMessage});

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<List<CommentModel>?> getAllComments(
      {required String postId}) async {
    try {
      final result = await _firestore
          .collection("posts")
          .doc(postId)
          .collection("comments")
          .get();

      List<CommentModel> commentModel = [];
      commentModel =
          result.docs.map((e) => CommentModel.fromJson(e.data())).toList();

      return commentModel;
    } catch (e) {
      return null;
    }
  }

  static Future<void> postReply(
      {required String postId,
      required String commentId,
      required ReplyModel replyModel}) async {
    try {
      //saves reply in new collection
      await _firestore
          .collection("posts")
          .doc(postId)
          .collection("comments")
          .doc(commentId)
          .collection("replies")
          .doc(replyModel.replyId)
          .set(replyModel.toJson());

      //updates the number of replies in a comment
      final commentReference = _firestore
          .collection("posts")
          .doc(postId)
          .collection("comments")
          .doc(commentId);

      await _firestore.runTransaction((transaction) async {
        final comment = await transaction.get(commentReference);

        int repliesCount = comment.data()!['no_of_replies'];

        transaction
            .update(commentReference, {"no_of_replies": repliesCount + 1});
      });
    } catch (e) {
      return;
    }
  }

  static Future<bool> removeReply({
    required String postId,
    required String commentId,
    required String replyId,
  }) async {
    try {
      //remove comment
      await _firestore
          .collection("posts")
          .doc(postId)
          .collection("comments")
          .doc(commentId)
          .collection("replies")
          .doc(replyId)
          .delete();

      //updates the number of replies in a comment
      final commentReference = _firestore
          .collection("posts")
          .doc(postId)
          .collection("comments")
          .doc(commentId);

      await _firestore.runTransaction((transaction) async {
        final comment = await transaction.get(commentReference);

        int repliesCount = comment.data()!['no_of_replies'];

        transaction
            .update(commentReference, {"no_of_replies": repliesCount - 1});
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateReply({
    required String postId,
    required String commentId,
    required String replyId,
    required String replyMessage,
  }) async {
    try {
      //updates the comment
      await _firestore
          .collection("posts")
          .doc(postId)
          .collection("comments")
          .doc(commentId)
          .collection("replies")
          .doc(replyId)
          .update({"reply_message": replyMessage});

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<List<ReplyModel>?> getAllReplies(
      {required String postId, required String commentId}) async {
    try {
      final result = await _firestore
          .collection("posts")
          .doc(postId)
          .collection("comments")
          .doc(commentId)
          .collection("replies")
          .get();

      List<ReplyModel> replyModel = [];
      replyModel =
          result.docs.map((e) => ReplyModel.fromJson(e.data())).toList();

      return replyModel;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> isAlreadyLiked(
      {required String postId, required String commentId}) async {
    try {
      final result = await _firestore
          .collection("posts")
          .doc(postId)
          .collection("comments")
          .doc(commentId)
          .collection("likes")
          .doc(_auth.currentUser!.uid)
          .get();

      return result.exists;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isAlreadyDisliked(
      {required String postId, required String commentId}) async {
    try {
      final result = await _firestore
          .collection("posts")
          .doc(postId)
          .collection("comments")
          .doc(commentId)
          .collection("dislikes")
          .doc(_auth.currentUser!.uid)
          .get();

      return result.exists;
    } catch (e) {
      return false;
    }
  }

  static Future<void> onLikeAndUnlike(
      {required String postId,
      required String commentId,
      required bool isLiked}) async {
    try {
      final commentReference = _firestore
          .collection("posts")
          .doc(postId)
          .collection("comments")
          .doc(commentId);

      final commentLikeReference =
          commentReference.collection("likes").doc(_auth.currentUser!.uid);

      await _firestore.runTransaction((transaction) async {
        final comment = await transaction.get(commentReference);

        int likesCount = comment.data()!['no_of_likes'];

        if (isLiked) {
          transaction.update(commentReference, {"no_of_likes": likesCount + 1});
          transaction
              .set(commentLikeReference, {"sender_id": _auth.currentUser!.uid});
        } else {
          transaction.update(commentReference, {"no_of_likes": likesCount - 1});
          transaction.delete(commentLikeReference);
        }
      });
    } catch (e) {
      return;
    }
  }

  static Future<void> onDislikeAndUnDislike(
      {required String postId,
      required String commentId,
      required bool isDisliked}) async {
    try {
      final commentReference = _firestore
          .collection("posts")
          .doc(postId)
          .collection("comments")
          .doc(commentId);

      final commentDislikeReference =
          commentReference.collection("dislikes").doc(_auth.currentUser!.uid);

      await _firestore.runTransaction((transaction) async {
        final comment = await transaction.get(commentReference);

        int dislikesCount = comment.data()!['no_of_dislikes'];

        if (isDisliked) {
          transaction
              .update(commentReference, {"no_of_dislikes": dislikesCount += 1});
          transaction.set(
              commentDislikeReference, {"sender_id": _auth.currentUser!.uid});
        } else {
          transaction
              .update(commentReference, {"no_of_dislikes": dislikesCount -= 1});
          transaction.delete(commentDislikeReference);
        }
      });
    } catch (e) {
      return;
    }
  }
}
