import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:neighboard/main.dart';
import 'package:neighboard/routes/routes.dart';
import 'package:neighboard/screen_direct.dart';
import 'package:neighboard/src/landing_page/ui/landing_page_desktop.dart';
import 'package:neighboard/src/landing_page/ui/landing_page_mobile.dart';
import 'package:neighboard/src/user_side/login_register_page/login_page/login_page_ui.dart';
import 'package:neighboard/src/user_side/login_register_page/register_page/register_page_ui.dart';
import 'package:neighboard/widgets/chat/chat.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_bar.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_drawer.dart';
import 'package:neighboard/widgets/notification/notification_drawer.dart';
import 'package:page_transition/page_transition.dart';
import 'package:responsive_builder/responsive_builder.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  String subdName = "";
  String header = "";
  String subHeader = "";
  String about = "";
  String backgroundImage = "";
  String aboutImage = "";

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  void siteDataInitialization() {
    subdName = siteModel?.siteSubdName ?? 'Sample Subd Name';
    header = siteModel?.siteHeader ?? 'Sample Header';
    subHeader = siteModel?.siteSubheader ?? 'Sample Subheader';
    about = siteModel?.siteAbout ?? 'Sample About';
    backgroundImage = siteModel?.siteHomepageImage ?? '';
    aboutImage = siteModel?.siteAboutImage ?? '';
  }

  void openNotification() {
    scaffoldKey.currentState!.openEndDrawer();
  }

  void openChat() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return const MyChat();
      },
    );
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoggedIn = false;
  checkIfLoggedIn() {
    if (_auth.currentUser != null) {
      isLoggedIn = true;
    }
  }

  void _openChat() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      context: context,
      builder: (context) {
        return const MyChat();
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkIfLoggedIn();
    siteDataInitialization();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, sizingInformation) {
      if (sizingInformation.deviceScreenType == DeviceScreenType.mobile) {
        return Scaffold(
          key: scaffoldKey,
          appBar: AppBar(
            actions: [
              //TODO: Chat count
              if (isLoggedIn)
                NavBarBadges(
                  count: null,
                  icon: const Icon(Icons.chat_outlined),
                  callback: _openChat,
                ),
              if (isLoggedIn)
                const SizedBox(
                  width: 10,
                ),
              if (isLoggedIn)
                NavBarBadges(
                  count: notificationModels
                      .where((element) => !element.isRead)
                      .toList()
                      .length
                      .toString(),
                  icon: const Icon(Icons.notifications_outlined),
                  callback: openNotification,
                )
              else
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(PageTransition(
                        duration: const Duration(milliseconds: 500),
                        child: const LoginPage(),
                        type: PageTransitionType.fade));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Theme.of(context).colorScheme.onBackground,
                    elevation: 0,
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              const SizedBox(
                width: 10,
              ),
              if (isLoggedIn)
                NavBarCircularImageDropDownButton(
                  callback: Routes().navigate,
                  isAdmin: false,
                )
              else
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(PageTransition(
                        duration: const Duration(milliseconds: 500),
                        child: const RegisterPage(),
                        type: PageTransitionType.fade));
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor:
                        Theme.of(context).colorScheme.inversePrimary,
                    foregroundColor: Theme.of(context).colorScheme.onBackground,
                  ),
                  child: const Text(
                    "Register",
                    style: TextStyle(
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              const SizedBox(
                width: 10,
              ),
            ],
          ),
          drawer: sizingInformation.deviceScreenType == DeviceScreenType.mobile
              ? const NavDrawer()
              : null,
          endDrawer: NotificationDrawer(
            deviceScreenType: sizingInformation.deviceScreenType,
            stateSetter: setState,
          ),
          body: LandingPageMobile(
            subdName: subdName,
            header: header,
            subHeader: subHeader,
            about: about,
            bgImage: backgroundImage,
            aboutImage: aboutImage,
          ),
        );
      } else {
        return Scaffold(
          key: scaffoldKey,
          appBar: NavBar(
            openNotification: openNotification,
            openChat: openChat,
            currentPage: "Home",
          ),
          endDrawer: NotificationDrawer(
            deviceScreenType: sizingInformation.deviceScreenType,
            stateSetter: setState,
          ),
          body: LandingPageDesktop(
            subdName: subdName,
            header: header,
            subHeader: subHeader,
            about: about,
            bgImage: backgroundImage,
            aboutImage: aboutImage,
          ),
        );
      }
    });
  }
}
