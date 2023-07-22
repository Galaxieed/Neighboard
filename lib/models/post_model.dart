import 'package:neighboard/models/comment_model.dart';
import 'package:neighboard/data/posts_data.dart';

class PostModel {
  String postId;
  String authorId;
  String authorName;
  String profilePicture;
  String timeStamp;
  String title;
  String content;
  int noOfViews;
  List<CommentModel> comments;
  int noOfUpVotes;
  bool isUpVoted;
  List<String> tags;

  // Constructor
  PostModel({
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.profilePicture,
    required this.timeStamp,
    required this.title,
    required this.content,
    required this.noOfViews,
    required this.comments,
    required this.noOfUpVotes,
    required this.isUpVoted,
    required this.tags,
  });
}

addPostData(PostModel post) {
  posts.add(post);
}

triggerUpVote(PostModel post, postId) {
  if (post.postId == postId) {
    if (post.isUpVoted) {
      post.isUpVoted = false;
      post.noOfUpVotes -= 1;
    } else {
      post.isUpVoted = true;
      post.noOfUpVotes += 1;
    }
  }
}
