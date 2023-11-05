import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neighboard/models/post_model.dart';

class SearchFunction {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<List<PostModel>?> searchPosts({required String query}) async {
    try {
      final result = await _firestore.collection("posts").get();
      query = query.toLowerCase();
      List<PostModel> postModels = [];
      postModels =
          result.docs.map((e) => PostModel.fromJson(e.data())).toList();

      List<PostModel> postByTitle = [];
      postByTitle = postModels
          .where((post) =>
              post.authorName.toLowerCase().contains(query) ||
              post.content.toLowerCase().contains(query) ||
              post.tags.any((tag) => tag.toLowerCase().contains(query)) ||
              post.timeStamp.toLowerCase().contains(query) ||
              post.title.toLowerCase().contains(query))
          .toList();
      return postByTitle;
    } catch (e) {
      return null;
    }
  }
}
