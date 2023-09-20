import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:neighboard/data/posts_data.dart';

class HOAVotingFunction {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> voteCandidate(
      String electionId, String candidateId) async {
    try {
      final candidateRef = _firestore
          .collection("election")
          .doc(electionId)
          .collection("candidates")
          .doc(candidateId);

      final candidateVotersRef = _firestore
          .collection("election")
          .doc(electionId)
          .collection("voters")
          .doc(_auth.currentUser!.uid);

      await _firestore.runTransaction((transaction) async {
        final noOfVotes = await transaction.get(candidateRef);

        int votesNo = noOfVotes.data()!["no_of_votes"];

        transaction.update(candidateRef, {"no_of_votes": votesNo + 1});
        transaction.set(candidateVotersRef, {"time_voted": formattedDate()});
        transaction.set(
            candidateVotersRef.collection("voted_candidates").doc(candidateId),
            {"voted_candidate_id": candidateId});
      });
    } catch (e) {
      return;
    }
  }

  static Future<bool> isAlreadyVoted(String electionId) async {
    try {
      final result = await _firestore
          .collection("election")
          .doc(electionId)
          .collection("voters")
          .doc(_auth.currentUser!.uid)
          .get();

      return result.exists;
    } catch (e) {
      return false;
    }
  }
}
