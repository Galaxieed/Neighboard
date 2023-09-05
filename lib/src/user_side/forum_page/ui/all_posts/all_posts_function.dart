import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neighboard/models/post_model.dart';

class AllPostsFunction {
  static final FirebaseFirestore _firebaseFirestore =
      FirebaseFirestore.instance;

  static Future<List<PostModel>?> getAllPost() async {
    try {
      final result = await _firebaseFirestore.collection("posts").get();
      List<PostModel> postModels = [];
      postModels =
          result.docs.map((e) => PostModel.fromJson(e.data())).toList();

      return postModels;
    } catch (e) {
      return null;
    }
  }

  static Future<List<PostModel>?> getAllPendingPost() async {
    try {
      final result = await _firebaseFirestore.collection("pending_posts").get();
      List<PostModel> postModels = [];
      postModels =
          result.docs.map((e) => PostModel.fromJson(e.data())).toList();

      return postModels;
    } catch (e) {
      return null;
    }
  }
}
