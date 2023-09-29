import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:neighboard/models/user_model.dart';
import 'package:neighboard/src/admin_side/admin_side.dart';
import 'package:neighboard/src/landing_page/ui/landing_page.dart';
import 'package:neighboard/src/loading_screen/loading_screen.dart';
import 'package:neighboard/src/profile_screen/profile_screen_function.dart';
import 'package:neighboard/src/user_side/forum_page/ui/forum_page/forum_page.dart';

class ScreenDirect extends StatefulWidget {
  const ScreenDirect({super.key});

  @override
  State<ScreenDirect> createState() => _ScreenDirectState();
}

class _ScreenDirectState extends State<ScreenDirect> {
  bool isLoggedIn = false, isLoading = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel? userModel;

  void checkIfUserLoggedIn() async {
    setState(() {
      isLoading = true;
    });
    if (_auth.currentUser != null) {
      await getUserDetails(_auth.currentUser!.uid);
      isLoggedIn = true;
    }
    setState(() {
      isLoading = false;
    });
  }

  getUserDetails(userId) async {
    userModel = await ProfileFunction.getUserDetails(userId);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkIfUserLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const LoadingScreen();
    }
    if (isLoggedIn) {
      if (userModel!.role == "ADMIN") {
        return const AdminSide();
      } else {
        return const ForumPage();
      }
    } else {
      return const LandingPage();
    }
  }
}
