import 'package:flutter/material.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';
import 'package:neighboard/main.dart';

const String guestIcon = 'assets/guest_icon.png';
const String noImage = 'assets/no_image.jpg';
const String robotInfo = 'assets/robot.png';
const String robotThanks = 'assets/robot_thanks.png';
const String noPost = 'assets/no_posts.png';
const String noStore = 'assets/stores.png';
const String noChat = 'assets/chats.png';
const String announcement = 'assets/announcements.png';
const String electionImg = 'assets/election.png';
const String loginFirstImg = 'assets/login_first.png';
const String noElectionImg = 'assets/no_election.png';
const String notificationImg = 'assets/notifications.png';

const String siteAdminId = "sJuGAwN3Ena76LVIdJIdudfPSmh2";

//LandPage Styles
double ccLandPageBGOpacity = 1;

Color ccExploreButtonBGColor([context]) =>
    Theme.of(context).colorScheme.primary;

Color ccExploreButtonFGColor(context) =>
    Theme.of(context).colorScheme.inversePrimary;

Color ccSubHeaderFGColor(context) => Theme.of(context).colorScheme.onBackground;

Color ccHeaderFGColor(context) => Theme.of(context).colorScheme.inversePrimary;

//NavDrawer Styles
Color ccNavDrawerBGColor(context) =>
    Theme.of(context).colorScheme.background.withAlpha(230);

const Color ccNavDrawerShadowColor = Colors.black12;

Color ccNavDrawerHeaderColor([context]) =>
    Theme.of(context).colorScheme.primary;

const Color ccNavDrawerWelcomeColor = Colors.white;

//forum styles
Color ccForumButtonBGColor(context) =>
    Theme.of(context).disabledColor.withOpacity(0.1);

Color ccForumSelectedButtonBGColor([context]) =>
    Theme.of(context).colorScheme.primary;

Color ccForumButtonFGColor(context) => isDarkMode ? Colors.white : Colors.black;

Color ccForumSelectedButtonFGColor(context) =>
    Theme.of(context).colorScheme.onPrimary;

Color ccForumButtonBorderColor([context]) => Colors.transparent;

const Color ccForumSelectedButtonBorderColor = Colors.transparent;

const Color ccForumLinksColor = Colors.blue;

//other links styles
const Color ccForumDividerColor = Colors.black;

//mypost styles
Color ccMyPostCommentButtonBGColor(context) => colorFromHex(saveColor);
Color ccMyPostCommentButtonFGColor(context) => Colors.white;

Color ccMyPostUpVotedBGColor(context) => Theme.of(context).disabledColor;
Color ccMyPostUpVoteBGColor(context) => Theme.of(context).colorScheme.primary;
Color ccMyPostUpVotedFGColor(context) => Colors.white;
Color ccMyPostUpVoteFGColor(context) => Theme.of(context).colorScheme.onPrimary;

//announcements colors
Color ccOtherAnnouncementBannerColor([context]) =>
    Theme.of(context).colorScheme.primary.withOpacity(0.85);

Color ccMainAnnouncementBannerColor([context]) =>
    Theme.of(context).colorScheme.primary;

//community map styles
Color ccMapPinColor([context]) => Theme.of(context).colorScheme.primary;

//stores styles
Color ccStoresBannerColor([context]) =>
    Theme.of(context).colorScheme.primary.withOpacity(0.85);

//login and register styles
Color ccLoginButtonBGColor(context) =>
    Theme.of(context).colorScheme.inversePrimary;
Color ccLoginButtonFGColor(context) =>
    Theme.of(context).colorScheme.onBackground;
Color ccLoginRegisterButtonFGColor(context) =>
    Theme.of(context).colorScheme.onBackground;

Color ccRegisterButtonBGColor(context) =>
    Theme.of(context).colorScheme.inversePrimary;
Color ccRegisterButtonFGColor(context) =>
    Theme.of(context).colorScheme.onBackground;
Color ccRegisterLoginButtonFGColor(context) =>
    Theme.of(context).colorScheme.onBackground;

//HOA Voting
Color ccHOATitleBannerColor(context) => Theme.of(context).colorScheme.primary;
Color ccHOANextButtonBGColor(context) => Theme.of(context).colorScheme.primary;
Color ccHOANextButtonFGColor(context) =>
    Theme.of(context).colorScheme.onBackground;

//Profile Screen
Color? ccProfileUserNameTextColor = Colors.grey[700];
const Color ccProfileContainerBorderColor = Colors.grey;
const Color ccProfileInfoTextColor = Colors.grey;

//widgets
Container hoaTitleBanner(BuildContext context, String title) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(8.0),
    color: ccHOATitleBannerColor(context),
    child: Text(
      title,
      style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
    ),
  );
}

Reaction<String> selectedReaction(BuildContext context, String react) {
  if (react == "Like") {
    return Reaction(
      value: "Like",
      icon: Icon(
        Icons.thumb_up,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: const Text("Like"),
    );
  } else if (react == "Love") {
    return const Reaction(
      value: "Love",
      icon: Icon(
        Icons.favorite,
        color: Colors.red,
      ),
      title: Text("Love"),
    );
  } else if (react == "Star") {
    return const Reaction(
      value: "Star",
      icon: Icon(
        Icons.star,
        color: Colors.amber,
      ),
      title: Text("Star"),
    );
  } else {
    return const Reaction(
      value: null,
      icon: Icon(Icons.thumb_up_outlined),
    );
  }
}

String saveColor = "#29C948";
String discardColor = "#EF3E36";
Color colorFromHex(String hexString) {
  final buffer = StringBuffer();
  if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
  buffer.write(hexString.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}
