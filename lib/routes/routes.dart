import 'package:flutter/material.dart';
import 'package:neighboard/src/community_page/ui/announcement_page/announcement_page.dart';
import 'package:neighboard/src/community_page/ui/community_map_page/community_map.dart';
import 'package:neighboard/src/community_page/ui/stores_page/stores.dart';
import 'package:neighboard/src/forum_page/ui/forum_page.dart';
import 'package:neighboard/src/landing_page/ui/landing_page.dart';

class Routes {
  navigate(String route, [BuildContext? context]) {
    if (route == 'Home') {
      Navigator.pushReplacement(
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
              builder: (BuildContext context) => const Placeholder()));
    }
    if (route == 'Register') {
      Navigator.push(
          context!,
          MaterialPageRoute(
              builder: (BuildContext context) => const Placeholder()));
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
              builder: (BuildContext context) => const Placeholder()));
    }
  }
}
