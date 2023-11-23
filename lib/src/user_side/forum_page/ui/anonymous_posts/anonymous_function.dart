import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neighboard/models/post_model.dart';

class AnonymousFunction {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<List<PostModel>?> getAllAnonymousPosts() async {
    try {
      final result = await _firestore
          .collection("posts")
          .where("as_anonymous", isEqualTo: true)
          .get();
      List<PostModel> postModels = [];
      postModels =
          result.docs.map((e) => PostModel.fromJson(e.data())).toList();

      return postModels;
    } catch (e) {
      return null;
    }
  }

  static Future<List<PostModel>?> getPostsBySearch(
      {required String searchedWord}) async {
    try {
      final result = await _firestore
          .collection("posts")
          .where("as_anonymous", isEqualTo: true)
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
}
