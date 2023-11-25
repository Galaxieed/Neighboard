class ElectionModel {
  late String electionId;
  late String electionStartDate;
  late String electionStartTime;
  late String electionEndTime;
  late String electionNote;

  ElectionModel({
    required this.electionId,
    required this.electionStartDate,
    required this.electionStartTime,
    required this.electionEndTime,
    required this.electionNote,
  });

  ElectionModel.fromJson(Map<String, dynamic> json) {
    electionId = json['election_id'];
    electionStartDate = json['election_start_date'];
    electionStartTime = json['election_start_time'];
    electionEndTime = json['election_end_time'];
    electionNote = json['election_note'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['election_id'] = electionId;
    data['election_start_date'] = electionStartDate;
    data['election_start_time'] = electionStartTime;
    data['election_end_time'] = electionEndTime;
    data['election_note'] = electionNote;
    return data;
  }
}
