import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:neighboard/models/user_model.dart';

class PostInteractorsFunctions {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<List<UserModel>?> getPostInteractorsData(
      String postId, String collection) async {
    try {
      final result = await _firestore
          .collection("posts")
          .doc(postId)
          .collection(collection)
          .get();

      List<UserModel> userModels = [];
      for (var doc in result.docs) {
        final user = await _firestore
            .collection("users")
            .doc(doc.data()["user_id"])
            .get();

        if (user.exists) {
          userModels.add(UserModel.fromJson(user.data()!));
        } else {}
      }

      return userModels;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> isAlreadyViewed({required String postId}) async {
    try {
      final result = await _firestore
          .collection("posts")
          .doc(postId)
          .collection("views")
          .doc(_auth.currentUser!.uid)
          .get();

      return result.exists;
    } catch (e) {
      return false;
    }
  }

  static Future<void> onViewPost(
    String postId,
    bool isViewed,
  ) async {
    try {
      final postReference = _firestore.collection("posts").doc(postId);

      final postViewReference =
          postReference.collection("views").doc(_auth.currentUser!.uid);

      await _firestore.runTransaction((transaction) async {
        final post = await transaction.get(postReference);

        int postCount = post.data()!['no_of_views'];

        if (isViewed) {
          transaction.update(postReference, {"no_of_views": postCount + 1});
          transaction
              .set(postViewReference, {"user_id": _auth.currentUser!.uid});
        }
      });
    } catch (e) {
      return;
    }
  }
}
