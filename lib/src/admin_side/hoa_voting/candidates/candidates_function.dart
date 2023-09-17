import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neighboard/models/candidates_model.dart';
import 'package:neighboard/models/election_model.dart';

class CandidatesFunctions {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<bool> addCandidates(CandidateModel candidateModel) async {
    try {
      await _firestore
          .collection("candidates")
          .doc(candidateModel.candidateId)
          .set(candidateModel.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> startElection(ElectionModel electionModel) async {
    try {
      await _firestore
          .collection("election")
          .doc(electionModel.electionId)
          .set(electionModel.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<List<CandidateModel>?> getAllCandidate() async {
    try {
      final result = await _firestore.collection("candidates").get();
      List<CandidateModel> candidatesModel = [];
      candidatesModel =
          result.docs.map((e) => CandidateModel.fromJson(e.data())).toList();

      return candidatesModel;
    } catch (e) {
      return null;
    }
  }
}
