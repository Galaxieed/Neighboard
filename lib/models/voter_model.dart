class VoterModel {
  late String voterId;
  late String timeVoted;
  late String name;
  late String address;

  VoterModel(
      {required this.voterId,
      required this.timeVoted,
      required this.name,
      required this.address});

  VoterModel.fromJson(Map<String, dynamic> json) {
    voterId = json['voter_id'];
    timeVoted = json['time_voted'];
    name = json['name'];
    address = json['address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['voter_id'] = voterId;
    data['time_voted'] = timeVoted;
    data['name'] = name;
    data['address'] = address;
    return data;
  }
}
