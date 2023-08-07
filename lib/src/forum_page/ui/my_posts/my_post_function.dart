import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:neighboard/models/post_model.dart';

class MyPostFunction {
  static final FirebaseFirestore _firebaseFirestore =
      FirebaseFirestore.instance;

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<List<PostModel>?> getMyPost({required String authorId}) async {
    try {
      final result = await _firebaseFirestore
          .collection("posts")
          .where("author_id", isEqualTo: authorId)
          .get();
      List<PostModel> postModels = [];
      postModels =
          result.docs.map((e) => PostModel.fromJson(e.data())).toList();
      return postModels;
    } catch (e) {
      return null;
    }
  }

  static Future<List<PostModel>?> getMyPostByTitle(
      {required String authorId, required String title}) async {
    try {
      final result = await _firebaseFirestore
          .collection("posts")
          .where("author_id", isEqualTo: authorId)
          .where("title", isGreaterThanOrEqualTo: title)
          .get();
      List<PostModel> postModels = [];
      postModels =
          result.docs.map((e) => PostModel.fromJson(e.data())).toList();

      return postModels;
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<bool> isAlreadyUpvoted({required String postId}) async {
    try {
      final result = await _firebaseFirestore
          .collection("posts")
          .doc(postId)
          .collection("upvotes")
          .doc(_auth.currentUser!.uid)
          .get();

      return result.exists;
    } catch (e) {
      return false;
    }
  }

  static Future<void> onUpvoteAndUnUpvote(
      {required String postId, required bool isUpvoted}) async {
    try {
      final postReference = _firebaseFirestore.collection("posts").doc(postId);

      final postUpvoteReference =
          postReference.collection("upvotes").doc(_auth.currentUser!.uid);

      await _firebaseFirestore.runTransaction((transaction) async {
        final upvotes = await transaction.get(postReference);

        int noOfUpVotes = upvotes.data()!['no_of_upVotes'];

        if (isUpvoted) {
          transaction.update(postReference, {"no_of_upVotes": noOfUpVotes + 1});
          transaction
              .set(postUpvoteReference, {"user_id": _auth.currentUser!.uid});
        } else {
          transaction.update(postReference, {"no_of_upVotes": noOfUpVotes - 1});
          transaction.delete(postUpvoteReference);
        }
      });

      if (isUpvoted) {
        //updates the rank of the user
        final userReference =
            _firebaseFirestore.collection("users").doc(_auth.currentUser!.uid);

        await _firebaseFirestore.runTransaction((transaction) async {
          final user = await transaction.get(userReference);

          int rankCount = user.data()!['rank'];

          transaction.update(userReference, {"rank": rankCount + 1});
        });
      }
    } catch (e) {
      return;
    }
  }
}
