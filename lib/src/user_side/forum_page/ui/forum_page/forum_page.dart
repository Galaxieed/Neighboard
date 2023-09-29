import 'package:flutter/material.dart';
import 'package:neighboard/src/user_side/forum_page/ui/forum_page/forum_page_desktop.dart';
import 'package:neighboard/src/user_side/forum_page/ui/forum_page/forum_page_mobile.dart';

import 'package:responsive_builder/responsive_builder.dart';

class ForumPage extends StatelessWidget {
  const ForumPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, sizingInformation) {
      if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
        return const ForumPageDesktop();
      } else if (sizingInformation.deviceScreenType ==
          DeviceScreenType.tablet) {
        return const Placeholder();
      } else {
        return ForumPageMobile(
          isAdmin: false,
          screenType: sizingInformation.deviceScreenType,
        );
      }
    });
  }
}
