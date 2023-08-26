import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neighboard/models/post_model.dart';

class SearchFunction {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<List<PostModel>?> searchPosts({required String query}) async {
    try {
      final result = await _firestore
          .collection("posts")
          .where("title", isEqualTo: query)
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
