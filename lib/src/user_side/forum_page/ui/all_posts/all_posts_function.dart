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

  static Future<List<PostModel>?> getTopPost() async {
    try {
      //top 3 views
      final viewsQuery = await _firebaseFirestore
          .collection("posts")
          .orderBy('no_of_views', descending: true)
          .limit(3)
          .get();
      //top 3 upvotes
      final upVotesQuery = await _firebaseFirestore
          .collection("posts")
          .orderBy('no_of_upVotes', descending: true)
          .limit(3)
          .get();
      // Use a Set to keep track of unique post IDs
      Set<String> uniquePostIds = Set<String>();

      // Combine the results without duplicates
      List<PostModel> topPosts = [];

      // Add posts from viewsQuery
      for (QueryDocumentSnapshot doc in viewsQuery.docs) {
        String postId = doc['post_id'];
        if (!uniquePostIds.contains(postId)) {
          uniquePostIds.add(postId);
          topPosts.add(PostModel.fromJson(doc.data() as Map<String, dynamic>));
        }
      }

      // Add posts from upVotesQuery
      for (QueryDocumentSnapshot doc in upVotesQuery.docs) {
        String postId = doc['post_id'];
        if (!uniquePostIds.contains(postId)) {
          uniquePostIds.add(postId);
          topPosts.add(PostModel.fromJson(doc.data() as Map<String, dynamic>));
        }
      }

      return topPosts;
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
