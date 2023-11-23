import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:neighboard/src/user_side/forum_page/ui/forum_page/forum_page_desktop.dart';
import 'package:neighboard/src/user_side/forum_page/ui/forum_page/forum_page_mobile.dart';
import 'package:neighboard/src/user_side/login_register_page/login_page/login_page_ui.dart';

import 'package:responsive_builder/responsive_builder.dart';

class ForumPage extends StatelessWidget {
  ForumPage({Key? key}) : super(key: key);

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, sizingInformation) {
      if (_auth.currentUser != null) {
        if (sizingInformation.deviceScreenType == DeviceScreenType.mobile) {
          return ForumPageMobile(
            isAdmin: false,
            screenType: sizingInformation.deviceScreenType,
          );
        } else {
          return const ForumPageDesktop();
        }
      } else {
        return const LoginPage();
      }
    });
  }
}
