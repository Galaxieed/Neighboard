class ElectionModel {
  late String electionId;
  late String electionStartDate;
  late String electionEndDate;
  late String electionNote;

  ElectionModel({
    required this.electionId,
    required this.electionStartDate,
    required this.electionEndDate,
    required this.electionNote,
  });

  ElectionModel.fromJson(Map<String, dynamic> json) {
    electionId = json['election_id'];
    electionStartDate = json['election_start_date'];
    electionEndDate = json['election_end_date'];
    electionNote = json['election_note'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['election_id'] = electionId;
    data['election_start_date'] = electionStartDate;
    data['election_end_date'] = electionEndDate;
    data['election_note'] = electionNote;
    return data;
  }
}
