import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neighboard/models/post_model.dart';

class CategoriesFunction {
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

  static Future<List<PostModel>?> getPostsByCategory(
      {required String category}) async {
    try {
      final result = await _firebaseFirestore
          .collection("posts")
          .where("tags", arrayContainsAny: [category]).get();
      List<PostModel> postModels = [];
      postModels =
          result.docs.map((e) => PostModel.fromJson(e.data())).toList();

      return postModels;
    } catch (e) {
      return null;
    }
  }

  static Future<List<PostModel>?> getPostsByTitle(
      {required String title}) async {
    try {
      final result = await _firebaseFirestore
          .collection("posts")
          .where("title", isGreaterThanOrEqualTo: title)
          .get();
      List<PostModel> postModels = [];
      postModels =
          result.docs.map((e) => PostModel.fromJson(e.data())).toList();

      return postModels;
    } catch (e) {
      return null;
    }
  }
}
