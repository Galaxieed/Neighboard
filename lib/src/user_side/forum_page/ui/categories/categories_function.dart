import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neighboard/models/post_model.dart';

class CategoriesFunction {
  static final FirebaseFirestore _firebaseFirestore =
      FirebaseFirestore.instance;

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
      {required String searchedWord}) async {
    try {
      final result = await _firebaseFirestore.collection("posts").get();
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

  static Future<List<PostModel>?> getPostsByCategoryAndTitle(
      {required String category, required String searchedWord}) async {
    try {
      final result = await _firebaseFirestore.collection("posts").get();
      List<PostModel> postModels = [];
      postModels =
          result.docs.map((e) => PostModel.fromJson(e.data())).toList();
      // .toLowerCase to case insensitive
      category = category.toLowerCase();
      searchedWord = searchedWord.toLowerCase();
      //search all postModels based on title or searchedWord
      List<PostModel> postByTitle = [];
      if (category == "general discussion") {
        print("GENERAL");
        postByTitle = postModels
            .where((post) =>
                post.tags.any((tag) => ![
                      'Water Billing',
                      'Parking Space',
                      'Electric Billing',
                      'Garbage Collection',
                      'Power Interruption',
                      'Marketplace/Business',
                      'Clubhouse Fees and Rental',
                    ].contains(tag)) &&
                (post.authorName.toLowerCase().contains(searchedWord) ||
                    post.content.toLowerCase().contains(searchedWord) ||
                    post.tags.any(
                        (tag) => tag.toLowerCase().contains(searchedWord)) ||
                    post.timeStamp.toLowerCase().contains(searchedWord) ||
                    post.title.toLowerCase().contains(searchedWord)))
            .toList();
      } else {
        postByTitle = postModels
            .where((post) =>
                post.tags.any((tag) => tag.toLowerCase().contains(category)) &&
                (post.authorName.toLowerCase().contains(searchedWord) ||
                    post.content.toLowerCase().contains(searchedWord) ||
                    post.tags.any(
                        (tag) => tag.toLowerCase().contains(searchedWord)) ||
                    post.timeStamp.toLowerCase().contains(searchedWord) ||
                    post.title.toLowerCase().contains(searchedWord)))
            .toList();
      }

      return postByTitle;
    } catch (e) {
      return null;
    }
  }
}
