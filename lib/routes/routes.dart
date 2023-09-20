import 'package:flutter/material.dart';
import 'package:neighboard/src/user_side/community_page/ui/announcement_page/announcement_page.dart';
import 'package:neighboard/src/user_side/community_page/ui/community_map_page/community_map.dart';
import 'package:neighboard/src/user_side/community_page/ui/hoa_voting_page/hoa_voting.dart';
import 'package:neighboard/src/user_side/community_page/ui/stores_page/stores.dart';
import 'package:neighboard/src/user_side/forum_page/ui/forum_page/forum_page.dart';
import 'package:neighboard/src/landing_page/ui/landing_page.dart';
import 'package:neighboard/src/user_side/login_register_page/login_page/login_page_ui.dart';
import 'package:neighboard/src/user_side/login_register_page/register_page/register_page_ui.dart';

class Routes {
  navigate(String route, [BuildContext? context]) {
    if (route == 'Home') {
      Navigator.push(
          context!,
          MaterialPageRoute(
              builder: (BuildContext context) => const LandingPage()));
    }
    if (route == 'Forum') {
      Navigator.push(
          context!,
          MaterialPageRoute(
              builder: (BuildContext context) => const ForumPage()));
    }
    if (route == 'Login') {
      Navigator.push(
          context!,
          MaterialPageRoute(
              builder: (BuildContext context) => const LoginPage()));
    }
    if (route == 'Register') {
      Navigator.push(
          context!,
          MaterialPageRoute(
              builder: (BuildContext context) => const RegisterPage()));
    }
    if (route == 'Announcements') {
      Navigator.push(
          context!,
          MaterialPageRoute(
              builder: (BuildContext context) => const AnnouncementPage()));
    }
    if (route == 'Community Map') {
      Navigator.push(
          context!,
          MaterialPageRoute(
              builder: (BuildContext context) => const CommunityMap()));
    }
    if (route == 'Stores') {
      Navigator.push(
          context!,
          MaterialPageRoute(
              builder: (BuildContext context) => const StoresPage()));
    }
    if (route == 'HOA Voting') {
      Navigator.push(
          context!,
          MaterialPageRoute(
              builder: (BuildContext context) => const HOAVoting()));
    }
  }
}
