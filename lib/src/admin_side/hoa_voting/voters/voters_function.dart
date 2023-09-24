import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neighboard/models/user_model.dart';
import 'package:neighboard/models/voter_model.dart';

class VotersFunction {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<List<VoterModel>?> getAllVoters(String electionId) async {
    try {
      final result = await _firestore
          .collection("election")
          .doc(electionId)
          .collection("voters")
          .get();
      List<VoterModel> thisVoter = [];
      thisVoter =
          result.docs.map((e) => VoterModel.fromJson(e.data())).toList();
      return thisVoter;
    } catch (e) {
      return null;
    }
  }

  static Future<List<UserModel>?> getAllUsers() async {
    try {
      final usersList = await _firestore.collection("users").get();

      List<UserModel> thisUser = [];
      thisUser =
          usersList.docs.map((e) => UserModel.fromJson(e.data())).toList();

      return thisUser;
    } catch (e) {
      return null;
    }
  }
}
