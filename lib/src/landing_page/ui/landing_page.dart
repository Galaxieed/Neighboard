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
  // String header = 'LA ALDEA \nCOMMUNITY \nFORUM';
  String subdName = siteModel?.siteSubdName ?? 'Sample Subd Name';
  String header = siteModel?.siteHeader ?? 'Sample Header';
  // String subHeader =
  //     'A place where you can freely share your thoughts with one'
  //     ' another.\nShare your ideas and ask your fellow '
  //     'residents, Ka-Aldea!';
  String subHeader = siteModel?.siteSubheader ?? 'Sample Subheader';
  String about = siteModel?.siteAbout ?? 'Sample About';
  // String about = 'La Aldea Subdivision is situated along McArthur'
  //     ' Highway in the so-called Golden Triangle in'
  //     ' Guiguinto, Bulacan which serves as the center'
  //     ' of Bulacan. \n\nHighly accessible having '
  //     'the distinct advantage of being located at '
  //     'a short distance (approximately 1.5kms) from '
  //     'the convergence of Bulacan\'s three major '
  //     'national road networks, otherwise known as '
  //     'the Central Bulacan Interchange.';

  String backgroundImage = siteModel?.siteHomepageImage ?? '';
  // String backgroundImage = homepageImage;
  String aboutImage = siteModel?.siteAboutImage ?? '';
  // String aboutImage = homeImage;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

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
