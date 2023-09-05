class CandidateModel {
  late String candidateId;
  late String firstName;
  late String lastName;
  late String profilePicture;
  late String address;
  late String position;
  late int noOfVotes;

  CandidateModel({
    required this.candidateId,
    required this.firstName,
    required this.lastName,
    required this.profilePicture,
    required this.address,
    required this.position,
    required this.noOfVotes,
  });

  CandidateModel.fromJson(Map<String, dynamic> json) {
    candidateId = json['candidate_id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    profilePicture = json['profile_picture'];
    address = json['address'];
    position = json['position'];
    noOfVotes = json['no_of_votes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['candidate_id'] = candidateId;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['profile_picture'] = profilePicture;
    data['address'] = address;
    data['position'] = position;
    data['no_of_votes'] = noOfVotes;
    return data;
  }
}
