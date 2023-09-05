import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neighboard/models/post_model.dart';

class PendingPostFunction {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> approvePendingPost(PostModel postModel) async {
    try {
      await _firestore
          .collection("posts")
          .doc(postModel.postId)
          .set(postModel.toJson());

      //updates the number of posts in a user
      final userReference =
          _firestore.collection("users").doc(postModel.authorId);

      await _firestore.runTransaction((transaction) async {
        final user = await transaction.get(userReference);

        int postCount = user.data()!['posts'];

        transaction.update(userReference, {"posts": postCount + 1});

        int rankCount = user.data()!['rank'];

        transaction.update(userReference, {"rank": rankCount + 10});
      });

      await removePendingPost(postModel);
    } catch (e) {
      return;
    }
  }

  static Future<void> removePendingPost(PostModel postModel) async {
    try {
      final pendingPostReference =
          _firestore.collection("pending_posts").doc(postModel.postId);

      await _firestore.runTransaction((transaction) async {
        transaction.delete(pendingPostReference);
      });
    } catch (e) {
      return;
    }
  }
}
