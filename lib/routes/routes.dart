import 'package:flutter/material.dart';
import 'package:neighboard/src/user_side/community_page/ui/announcement_page/announcement_page.dart';
import 'package:neighboard/src/user_side/community_page/ui/community_map_page/community_map.dart';
import 'package:neighboard/src/user_side/community_page/ui/hoa_voting_page/hoa_voting.dart';
import 'package:neighboard/src/user_side/community_page/ui/stores_page/stores.dart';
import 'package:neighboard/src/user_side/forum_page/ui/forum_page/forum_page.dart';
import 'package:neighboard/src/landing_page/ui/landing_page.dart';
import 'package:neighboard/src/user_side/login_register_page/login_page/login_page_ui.dart';
import 'package:neighboard/src/user_side/login_register_page/register_page/register_page_ui.dart';
import 'package:page_transition/page_transition.dart';

class Routes {
  navigate(String route, [BuildContext? context]) {
    if (route == 'Home') {
      Navigator.of(context!).push(PageTransition(
          duration: const Duration(milliseconds: 500),
          child: const LandingPage(),
          type: PageTransitionType.fade));
    }
    if (route == 'Forum') {
      Navigator.of(context!).push(PageTransition(
          duration: const Duration(milliseconds: 500),
          child: ForumPage(),
          type: PageTransitionType.fade));
    }
    if (route == 'Login') {
      Navigator.of(context!).push(PageTransition(
          duration: const Duration(milliseconds: 500),
          child: const LoginPage(),
          type: PageTransitionType.fade));
    }
    if (route == 'Register') {
      Navigator.of(context!).push(PageTransition(
          duration: const Duration(milliseconds: 500),
          child: const RegisterPage(),
          type: PageTransitionType.fade));
    }
    if (route == 'Announcements') {
      Navigator.of(context!).push(PageTransition(
          duration: const Duration(milliseconds: 500),
          child: const AnnouncementPage(),
          type: PageTransitionType.fade));
    }
    if (route == 'Community Map') {
      Navigator.of(context!).push(PageTransition(
          duration: const Duration(milliseconds: 500),
          child: const CommunityMap(),
          type: PageTransitionType.fade));
    }
    if (route == 'Stores') {
      Navigator.of(context!).push(PageTransition(
          duration: const Duration(milliseconds: 500),
          child: const StoresPage(),
          type: PageTransitionType.fade));
    }
    if (route == 'HOA Voting') {
      Navigator.of(context!).push(PageTransition(
          duration: const Duration(milliseconds: 500),
          child: const HOAVoting(),
          type: PageTransitionType.fade));
    }
  }
}
