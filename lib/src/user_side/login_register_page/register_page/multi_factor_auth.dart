// ignore_for_file: use_build_context_synchronously

import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:neighboard/screen_direct.dart';
import 'package:neighboard/widgets/notification/mini_notif/elegant_notif.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class MyMFA {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static late User user;

  static Future<String?> getSmsCodeFromUser(BuildContext context) async {
    String? smsCode;
    String? currentText;
    // Update the UI - wait for the user to enter the SMS code
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(builder: (context, st) {
          return AlertDialog(
            title: const Text('SMS code:'),
            actions: [
              OutlinedButton(
                onPressed: () {
                  smsCode = null;
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(smsCode);
                },
                child: const Text('Sign in'),
              ),
            ],
            content: SizedBox(
              width: 350,
              child: PinCodeTextField(
                length: 6,
                obscureText: false,
                animationType: AnimationType.fade,
                keyboardType: TextInputType.phone,
                autoFocus: true,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(5),
                  fieldHeight: 45,
                  fieldWidth: 35,
                  activeFillColor: Colors.white,
                ),
                animationDuration: const Duration(milliseconds: 300),
                onCompleted: (v) {
                  smsCode = currentText;
                },
                onChanged: (value) {
                  st(() {
                    currentText = value;
                  });
                },
                appContext: context,
              ),
            ),
          );
        });
      },
    );

    return smsCode;
  }

  static Future<void> enrollMultiFactorAuthentication(
      String phoneNumber, BuildContext context) async {
    try {
      user = _auth.currentUser!;
      final session = await user.multiFactor.getSession();
      final auth = FirebaseAuth.instance;
      await auth.verifyPhoneNumber(
        multiFactorSession: session,
        phoneNumber: phoneNumber,
        verificationCompleted: (_) {},
        verificationFailed: (e) {
          errorMessage(
              title: "Something went wrong",
              desc: e.message.toString(),
              context: context);
        },
        codeSent: (String verificationId, int? resendToken) async {
          // See `firebase_auth` example app for a method of retrieving user's sms code:
          // https://github.com/firebase/flutterfire/blob/master/packages/firebase_auth/firebase_auth/example/lib/auth.dart#
          successMessage(
              title: "Sent!", desc: "SMS Code Sent!", context: context);

          final smsCode = await getSmsCodeFromUser(context);

          if (smsCode != null) {
            // Create a PhoneAuthCredential with the code
            final credential = PhoneAuthProvider.credential(
              verificationId: verificationId,
              smsCode: smsCode,
            );

            try {
              await user.multiFactor.enroll(
                PhoneMultiFactorGenerator.getAssertion(
                  credential,
                ),
              );
              successMessage(
                title: "Logged In",
                desc: "Successfully Logged In",
                context: context,
              );
              Navigator.of(context).pushReplacement(PageTransition(
                  child: const ScreenDirect(), type: PageTransitionType.fade));
            } on FirebaseAuthException catch (e) {
              errorMessage(
                  title: "Error", desc: e.message.toString(), context: context);
            }
          }
        },
        codeAutoRetrievalTimeout: (_) {},
      );
    } catch (e) {
      errorMessage(title: "Error", desc: e.toString(), context: context);
    }
  }

  static Future<void> handleMultiFactorException(
      Future<void> Function() authFunction, BuildContext context) async {
    try {
      await authFunction();
    } on FirebaseAuthMultiFactorException catch (e) {
      final firstTotpHint = e.resolver.hints
          .firstWhereOrNull((element) => element is TotpMultiFactorInfo);
      if (firstTotpHint != null) {
        final code = await getSmsCodeFromUser(context);
        final assertion = await TotpMultiFactorGenerator.getAssertionForSignIn(
          firstTotpHint.uid,
          code!,
        );
        await e.resolver.resolveSignIn(assertion);
        return;
      }

      final firstPhoneHint = e.resolver.hints
          .firstWhereOrNull((element) => element is PhoneMultiFactorInfo);

      if (firstPhoneHint is! PhoneMultiFactorInfo) {
        return;
      }
      await _auth.verifyPhoneNumber(
        multiFactorSession: e.resolver.session,
        multiFactorInfo: firstPhoneHint,
        verificationCompleted: (_) {},
        verificationFailed: (e) {
          errorMessage(title: "Invalid", desc: "Wrong Code", context: context);
        },
        codeSent: (String verificationId, int? resendToken) async {
          final smsCode = await getSmsCodeFromUser(context);

          if (smsCode != null) {
            // Create a PhoneAuthCredential with the code
            final credential = PhoneAuthProvider.credential(
              verificationId: verificationId,
              smsCode: smsCode,
            );

            try {
              await e.resolver.resolveSignIn(
                PhoneMultiFactorGenerator.getAssertion(
                  credential,
                ),
              );
              successMessage(
                title: "Logged In",
                desc: "Successfully Logged In",
                context: context,
              );
              Navigator.of(context).pushReplacement(PageTransition(
                  child: const ScreenDirect(), type: PageTransitionType.fade));
            } on FirebaseAuthException catch (e) {
              errorMessage(
                  title: "Error", desc: e.message.toString(), context: context);
            }
          }
        },
        codeAutoRetrievalTimeout: print,
      );
    } on FirebaseAuthException catch (e) {
      errorMessage(
          title: "Error", desc: e.message.toString(), context: context);
    } catch (e) {
      errorMessage(title: "Error", desc: e.toString(), context: context);
    }
  }
}
