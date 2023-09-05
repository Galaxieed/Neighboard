class UserModel {
  late String firstName;
  late String userId;
  late String lastName;
  late String username;
  late String email;
  late String address;
  late String contactNo;
  late List<String> socialMediaLinks;
  late int rank;
  late int posts;
  late String profilePicture;
  late String role;

  UserModel({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.address,
    required this.contactNo,
    required this.socialMediaLinks,
    required this.rank,
    required this.posts,
    required this.profilePicture,
    required this.role,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    username = json['username'];
    email = json['email'];
    address = json['address'];
    contactNo = json['contact_no'];
    socialMediaLinks = json['social_media_links'].cast<String>();
    rank = json['rank'];
    posts = json['posts'];
    profilePicture = json['profile_picture'];
    role = json['role'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['username'] = username;
    data['email'] = email;
    data['address'] = address;
    data['contact_no'] = contactNo;
    data['social_media_links'] = socialMediaLinks;
    data['rank'] = rank;
    data['posts'] = posts;
    data['profile_picture'] = profilePicture;
    data['role'] = role;
    return data;
  }
}
