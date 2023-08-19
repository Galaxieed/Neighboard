import 'package:flutter/material.dart';
import 'package:neighboard/main.dart';

const String homepageImage = 'assets/homepage.jpg';
const String homeImage = 'assets/home.jpg';
const String bigScoopImage = 'assets/bigscoop.jpg';
const String walterMartImage = 'assets/waltermart.jpg';
const String guestIcon = 'assets/guest_icon.png';

//LandPage Styles
Color ccExploreButtonBGColor([context]) => isDarkMode
    ? Theme.of(context).primaryColor
    : Theme.of(context).colorScheme.inversePrimary;

Color ccExploreButtonFGColor(context) =>
    Theme.of(context).colorScheme.onBackground;

Color ccSubHeaderFGColor(context) => isDarkMode ? Colors.white : Colors.black;

Color ccHeaderFGColor(context) => isDarkMode ? Colors.white : Colors.black;

//NavDrawer Styles
Color ccNavDrawerBGColor(context) =>
    Theme.of(context).colorScheme.background.withAlpha(230);

const Color ccNavDrawerShadowColor = Colors.black12;

Color ccNavDrawerHeaderColor([context]) => Theme.of(context).primaryColor;

const Color ccNavDrawerWelcomeColor = Colors.white;

//forum styles
const Color ccForumButtonBGColor = Colors.transparent;

Color ccForumSelectedButtonBGColor([context]) => isDarkMode
    ? Theme.of(context).colorScheme.inversePrimary
    : Theme.of(context).primaryColor;

Color ccForumButtonFGColor(context) => isDarkMode ? Colors.white : Colors.black;

const Color ccForumSelectedButtonFGColor = Colors.white;

Color ccForumButtonBorderColor([context]) => isDarkMode
    ? Theme.of(context).colorScheme.inversePrimary
    : Theme.of(context).primaryColor;

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
    Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5);

Color ccMainAnnouncementBannerColor([context]) =>
    Theme.of(context).colorScheme.inversePrimary;

//community map styles
Color ccMapPinColor([context]) => Colors.red;

//stores styles
Color ccStoresBannerColor([context]) =>
    Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5);

//login and register styles
Color ccLoginButtonBGColor(context) => Theme.of(context).primaryColor;
Color ccLoginButtonFGColor(context) => Colors.white;
Color ccLoginRegisterButtonFGColor(context) =>
    isDarkMode ? Colors.white : Colors.black;

Color ccRegisterButtonBGColor(context) => Theme.of(context).primaryColor;
Color ccRegisterButtonFGColor(context) => Colors.white;
Color ccRegisterLoginButtonFGColor(context) =>
    isDarkMode ? Colors.white : Colors.black;
