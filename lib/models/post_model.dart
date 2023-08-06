class PostModel {
  late String postId;
  late String authorId;
  late String authorName;
  late String profilePicture;
  late String timeStamp;
  late String title;
  late String content;
  late int noOfComments;
  late int noOfViews;
  late int noOfUpVotes;
  late List<String> tags;

  PostModel({
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.profilePicture,
    required this.timeStamp,
    required this.title,
    required this.content,
    required this.noOfComments,
    required this.noOfViews,
    required this.noOfUpVotes,
    required this.tags,
  });

  PostModel.fromJson(Map<String, dynamic> json) {
    postId = json['post_id'];
    authorId = json['author_id'];
    authorName = json['author_name'];
    profilePicture = json['profile_picture'];
    timeStamp = json['time_stamp'];
    title = json['title'];
    content = json['content'];
    noOfComments = json['no_of_comments'];
    noOfViews = json['no_of_views'];
    noOfUpVotes = json['no_of_upVotes'];
    tags = json['tags'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['post_id'] = postId;
    data['author_id'] = authorId;
    data['author_name'] = authorName;
    data['profile_picture'] = profilePicture;
    data['time_stamp'] = timeStamp;
    data['title'] = title;
    data['content'] = content;
    data['no_of_comments'] = noOfComments;
    data['no_of_views'] = noOfViews;
    data['no_of_upVotes'] = noOfUpVotes;
    data['tags'] = tags;
    return data;
  }
}
