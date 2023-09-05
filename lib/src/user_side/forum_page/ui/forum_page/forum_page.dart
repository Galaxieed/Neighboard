import 'package:flutter/material.dart';
import 'package:neighboard/src/user_side/forum_page/ui/forum_page/forum_page_desktop.dart';
import 'package:neighboard/src/user_side/forum_page/ui/forum_page/forum_page_mobile.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_bar.dart';
import 'package:responsive_builder/responsive_builder.dart';

class ForumPage extends StatelessWidget {
  const ForumPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, sizingInformation) {
      if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
        return const Scaffold(
          appBar: NavBar(),
          body: ForumPageDesktop(),
        );
      } else if (sizingInformation.deviceScreenType ==
          DeviceScreenType.tablet) {
        return const Placeholder();
      } else {
        return ForumPageMobile(
          screenType: sizingInformation.deviceScreenType,
        );
      }
    });
  }
}
