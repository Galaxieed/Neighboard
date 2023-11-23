import 'package:firebase_auth/firebase_auth.dart';

class MFA {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static late User user;

  static Future<void> enrollMFA() async {
    try {
      MultiFactorSession session =
          await _auth.currentUser!.multiFactor.getSession();

      // Prompt the user for the verification code (received via SMS)
      // In a real-world scenario, you would implement UI to collect this code from the user
      String verificationCode = "123456"; // Replace with the actual user input

      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: session.id,
        smsCode: verificationCode,
      );

      MultiFactorAssertion assertion =
          PhoneMultiFactorGenerator.getAssertion(phoneAuthCredential);

      await _auth.currentUser!.multiFactor.enroll(assertion);

      user = _auth.currentUser!;

      // Send a notification to the user
      // _sendNotification();
    } catch (e) {
      return;
    }
  }
}
