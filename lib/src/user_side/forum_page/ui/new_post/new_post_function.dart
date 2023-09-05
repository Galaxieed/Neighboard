import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neighboard/models/post_model.dart';

class NewPostFunction {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<bool> createNewPost(PostModel postModel) async {
    try {
      //saves the post
      await _firestore
          .collection("pending_posts")
          .doc(postModel.postId)
          .set(postModel.toJson());

      // //updates the number of posts in a user
      // final userReference =
      //     _firestore.collection("users").doc(_auth.currentUser!.uid);

      // await _firestore.runTransaction((transaction) async {
      //   final user = await transaction.get(userReference);

      //   int postCount = user.data()!['posts'];

      //   transaction.update(userReference, {"posts": postCount + 1});

      //   int rankCount = user.data()!['rank'];

      //   transaction.update(userReference, {"rank": rankCount + 10});
      // });
      return true;
    } catch (e) {
      return false;
    }
  }
}
