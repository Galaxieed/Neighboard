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
      {required String authorId, required String searchedWord}) async {
    try {
      final result = await _firebaseFirestore
          .collection("posts")
          .where("author_id", isEqualTo: authorId)
          .get();
      List<PostModel> postModels = [];
      postModels =
          result.docs.map((e) => PostModel.fromJson(e.data())).toList();

      // .toLowerCase to case insensitive
      searchedWord = searchedWord.toLowerCase();
      //search all postModels based on title or searchedWord
      List<PostModel> postByTitle = [];
      postByTitle = postModels
          .where((post) =>
              post.authorName.toLowerCase().contains(searchedWord) ||
              post.content.toLowerCase().contains(searchedWord) ||
              post.tags
                  .any((tag) => tag.toLowerCase().contains(searchedWord)) ||
              post.timeStamp.toLowerCase().contains(searchedWord) ||
              post.title.toLowerCase().contains(searchedWord))
          .toList();
      return postByTitle;
    } catch (e) {
      return null;
    }
  }

  static Future<String> isAlreadyUpvoted({required String postId}) async {
    try {
      final result = await _firebaseFirestore
          .collection("posts")
          .doc(postId)
          .collection("upvotes")
          .doc(_auth.currentUser!.uid)
          .get();

      return result.data()?['reaction'] ?? "";
    } catch (e) {
      return "";
    }
  }

  static Future<void> onUpvoteAndUnUpvote(
      {required String postId,
      required String isUpvoted,
      required String react}) async {
    try {
      final postReference = _firebaseFirestore.collection("posts").doc(postId);

      final postUpvoteReference =
          postReference.collection("upvotes").doc(_auth.currentUser!.uid);

      await _firebaseFirestore.runTransaction((transaction) async {
        final upvotes = await transaction.get(postReference);

        int noOfUpVotes = upvotes.data()!['no_of_upVotes'];

        if (isUpvoted.isNotEmpty) {
          if (isUpvoted == "new") {
            transaction
                .update(postReference, {"no_of_upVotes": noOfUpVotes + 1});
            transaction.set(postUpvoteReference, {
              "user_id": _auth.currentUser!.uid,
              "reaction": react,
            });
          } else {
            transaction.set(postUpvoteReference, {
              "user_id": _auth.currentUser!.uid,
              "reaction": react,
            });
          }
        } else {
          transaction.update(postReference, {"no_of_upVotes": noOfUpVotes - 1});
          transaction.delete(postUpvoteReference);
        }
      });

      if (isUpvoted == "new") {
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
