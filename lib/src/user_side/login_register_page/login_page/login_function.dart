// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/models/user_model.dart';
import 'package:neighboard/screen_direct.dart';
import 'package:neighboard/src/user_side/login_register_page/register_page/multi_factor_auth.dart';
import 'package:neighboard/widgets/notification/mini_notif/elegant_notif.dart';
import 'package:page_transition/page_transition.dart';

class LoginFunction {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> _emailAndPassword(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<String> login(
      String email, String password, BuildContext context) async {
    try {
      //logins
      await MyMFA.handleMultiFactorException(() async {
        await _emailAndPassword(email, password);
      }, context);
      if (_auth.currentUser != null) {
        final result = await _firestore
            .collection("users")
            .doc(_auth.currentUser!.uid)
            .get();
        UserModel userModel = UserModel.fromJson(result.data()!);
        if (userModel.role == "ADMIN") {
          return "ADMIN";
        }
        List<String> exemptedUser = [
          '2jB7wg7PFZUV382mpTId2dqoTyL2',
          '8Jnmea0EkxgwTOLNpA9PQjm85j72',
          'sJuGAwN3Ena76LVIdJIdudfPSmh2',
          'v0HBgPZPb3OxY4VsQAWrI2oY4rF2',
        ];
        if (exemptedUser.contains(_auth.currentUser!.uid)) {
          infoMessage(
              title: "Test User",
              desc: "No additional security required",
              context: context);
          Navigator.of(context).pushReplacement(PageTransition(
              child: const ScreenDirect(), type: PageTransitionType.fade));
          return "";
        }
        //if USERS
        final mfa = await _auth.currentUser!.multiFactor.getEnrolledFactors();
        if (mfa.isEmpty) {
          //IF no mfa
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("Is this you?"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: userModel.profilePicture.isNotEmpty
                        ? NetworkImage(userModel.profilePicture)
                        : const AssetImage(guestIcon) as ImageProvider,
                  ),
                  Text(userModel.username),
                  const Text("Click 'YES' to confirm"),
                ],
              ),
              actions: [
                OutlinedButton(
                  onPressed: () {
                    _auth.signOut();
                    Navigator.pop(context);
                  },
                  child: const Text("NO"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await MyMFA.enrollMultiFactorAuthentication(
                        "+63${userModel.contactNo}", context);
                  },
                  child: const Text("YES"),
                )
              ],
            ),
          );
          return "";
        } else {
          if (userModel.role == "ADMIN") {
            return "ADMIN";
          }
          return "USER";
        }
      } else {
        return "NOT LOGGED IN YET";
      }
    } on FirebaseAuthException catch (e) {
      String err = e.message.toString();
      return err;
    }
  }

  static Future<void> logout() async {
    await _auth.signOut();
  }

  static Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }
}
