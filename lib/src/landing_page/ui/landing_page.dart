import 'package:flutter/material.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/src/landing_page/ui/landing_page_desktop.dart';
import 'package:neighboard/src/landing_page/ui/landing_page_mobile.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_bar.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_drawer.dart';
import 'package:responsive_builder/responsive_builder.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String header = 'LA ALDEA \nCOMMUNITY \nFORUM';
    String subHeader =
        'A place where you can freely share your thoughts with one'
        ' another.\nShare your ideas and ask your fellow '
        'residents, Ka-Aldea!';
    String about = 'La Aldea Subdivision is situated along McArthur'
        ' Highway in the so-called Golden Triangle in'
        ' Guiguinto, Bulacan which serves as the center'
        ' of Bulacan. \n\nHighly accessible having '
        'the distinct advantage of being located at '
        'a short distance (approximately 1.5kms) from '
        'the convergence of Bulacan\'s three major '
        'national road networks, otherwise known as '
        'the Central Bulacan Interchange.';

    String backgroundImage = homepageImage;
    String aboutImage = homeImage;

    return ResponsiveBuilder(builder: (context, sizingInformation) {
      if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
        return Scaffold(
          appBar: const NavBar(),
          body: LandingPageDesktop(
            header: header,
            subHeader: subHeader,
            about: about,
            bgImage: backgroundImage,
            aboutImage: aboutImage,
          ),
        );
      } else if (sizingInformation.deviceScreenType ==
          DeviceScreenType.tablet) {
        return const Placeholder(
          color: Colors.green,
        );
      } else {
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
      }
    });
  }
}
