class UserModel {
  late String firstName;
  late String userId;
  late String lastName;
  late String username;
  late String email;
  late List<String> socialMediaLinks;
  late int rank;
  late int posts;
  late String profilePicture;

  UserModel({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.socialMediaLinks,
    required this.rank,
    required this.posts,
    required this.profilePicture,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    username = json['username'];
    email = json['email'];
    socialMediaLinks = json['social_media_links'].cast<String>();
    rank = json['rank'];
    posts = json['posts'];
    profilePicture = json['profile_picture'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['username'] = username;
    data['email'] = email;
    data['social_media_links'] = socialMediaLinks;
    data['rank'] = rank;
    data['posts'] = posts;
    data['profile_picture'] = profilePicture;
    return data;
  }
}
