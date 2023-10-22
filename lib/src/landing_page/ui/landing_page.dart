import 'package:flutter/material.dart';
import 'package:neighboard/main.dart';
import 'package:neighboard/src/landing_page/ui/landing_page_desktop.dart';
import 'package:neighboard/src/landing_page/ui/landing_page_mobile.dart';
import 'package:neighboard/widgets/chat/chat.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_bar.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_drawer.dart';
import 'package:neighboard/widgets/notification/notification_drawer.dart';
import 'package:responsive_builder/responsive_builder.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    // String header = 'LA ALDEA \nCOMMUNITY \nFORUM';
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

    return ResponsiveBuilder(builder: (context, sizingInformation) {
      if (sizingInformation.deviceScreenType == DeviceScreenType.mobile) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("NEIGHBOARD"),
            centerTitle: true,
          ),
          drawer: sizingInformation.deviceScreenType == DeviceScreenType.mobile
              ? const NavDrawer()
              : null,
          body: LandingPageMobile(
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
