import 'package:flutter/material.dart';
import 'package:neighboard/main.dart';

const String homepageImage = 'assets/homepage.jpg';
const String homeImage = 'assets/home.jpeg';
const String bigScoopImage = 'assets/bigscoop.jpg';
const String walterMartImage = 'assets/waltermart.jpg';
const String guestIcon = 'assets/guest_icon.png';
const String noImage = 'assets/no_image.jpg';
const String robotInfo = 'assets/robot.png';
const String robotThanks = 'assets/robot_thanks.png';

//LandPage Styles
double ccLandPageBGOpacity = 1;

Color ccExploreButtonBGColor([context]) => isDarkMode
    ? Theme.of(context).primaryColor
    : Theme.of(context).colorScheme.inversePrimary;

Color ccExploreButtonFGColor(context) =>
    Theme.of(context).colorScheme.onBackground;

Color ccSubHeaderFGColor(context) => Theme.of(context).colorScheme.onBackground;

Color ccHeaderFGColor(context) => Theme.of(context).colorScheme.inversePrimary;

//NavDrawer Styles
Color ccNavDrawerBGColor(context) =>
    Theme.of(context).colorScheme.background.withAlpha(230);

const Color ccNavDrawerShadowColor = Colors.black12;

Color ccNavDrawerHeaderColor([context]) => Theme.of(context).primaryColor;

const Color ccNavDrawerWelcomeColor = Colors.white;

//forum styles
Color ccForumButtonBGColor(context) =>
    Theme.of(context).disabledColor.withOpacity(0.1);

Color ccForumSelectedButtonBGColor([context]) =>
    Theme.of(context).colorScheme.inversePrimary;

Color ccForumButtonFGColor(context) => isDarkMode ? Colors.white : Colors.black;

Color ccForumSelectedButtonFGColor(context) =>
    isDarkMode ? Colors.white : Colors.black;

Color ccForumButtonBorderColor([context]) => Colors.transparent;

const Color ccForumSelectedButtonBorderColor = Colors.transparent;

const Color ccForumLinksColor = Colors.blue;

//other links styles
const Color ccForumDividerColor = Colors.black;

//mini profile styles
Color? ccLightBulbColor = Colors.amber[500];

Color? ccRankColor = Colors.amber[500];

//bottom tab bar styles
const Color ccBottomTabBarColor = Colors.amber;

//mypost styles
Color? ccExpansionPostColor([context]) =>
    Theme.of(context).colorScheme.inversePrimary;
Color ccMyPostCommentButtonBGColor(context) =>
    Theme.of(context).colorScheme.inversePrimary;
Color ccMyPostCommentButtonFGColor(context) =>
    Theme.of(context).colorScheme.onBackground;

Color ccMyPostUpVotedBGColor(context) => Theme.of(context).disabledColor;
Color ccMyPostUpVoteBGColor(context) =>
    Theme.of(context).colorScheme.inversePrimary;
Color ccMyPostUpVotedFGColor(context) => Colors.white;
Color ccMyPostUpVoteFGColor(context) =>
    Theme.of(context).colorScheme.onBackground;

//announcements colors
Color ccOtherAnnouncementBannerColor([context]) =>
    Theme.of(context).colorScheme.inversePrimary.withOpacity(0.85);

Color ccMainAnnouncementBannerColor([context]) =>
    Theme.of(context).colorScheme.inversePrimary;

//community map styles
Color ccMapPinColor([context]) => Colors.red;

//stores styles
Color ccStoresBannerColor([context]) =>
    Theme.of(context).colorScheme.inversePrimary.withOpacity(0.85);

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
Color ccHOATitleBannerColor(context) =>
    Theme.of(context).colorScheme.inversePrimary;
Color ccHOANextButtonBGColor(context) =>
    Theme.of(context).colorScheme.inversePrimary;
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
      style: Theme.of(context)
          .textTheme
          .titleLarge!
          .copyWith(fontWeight: FontWeight.w800),
    ),
  );
}
