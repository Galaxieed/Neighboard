import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neighboard/models/candidates_model.dart';
import 'package:neighboard/models/election_model.dart';

class CandidatesFunctions {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  static Future<void> addCandidate(
      String electionId, CandidateModel candidateModel) async {
    try {
      await _firestore
          .collection("election")
          .doc(electionId)
          .collection("candidates")
          .doc(candidateModel.candidateId)
          .set(candidateModel.toJson());
    } catch (e) {
      return;
    }
  }

  static Future<ElectionModel?> getLatestElection() async {
    try {
      final result = await _firestore
          .collection("election")
          .orderBy('election_start_date', descending: true)
          .limit(1)
          .get();

      ElectionModel electionModel =
          ElectionModel.fromJson(result.docs.first.data());
      return electionModel;
    } catch (e) {
      return null;
    }
  }

  static Future<List<ElectionModel>?> getAllElection() async {
    try {
      final result = await _firestore.collection("election").get();
      List<ElectionModel> electionModel = [];
      electionModel =
          result.docs.map((e) => ElectionModel.fromJson(e.data())).toList();

      return electionModel;
    } catch (e) {
      return null;
    }
  }

  static Future<List<CandidateModel>?> getAllCandidate(
      String electionId) async {
    try {
      final result = await _firestore
          .collection("election")
          .doc(electionId)
          .collection("candidates")
          .get();
      List<CandidateModel> candidatesModel = [];
      candidatesModel =
          result.docs.map((e) => CandidateModel.fromJson(e.data())).toList();

      return candidatesModel;
    } catch (e) {
      return null;
    }
  }
}
