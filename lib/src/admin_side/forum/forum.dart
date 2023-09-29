import 'package:flutter/material.dart';
import 'package:neighboard/src/admin_side/forum/forum_desktop.dart';
import 'package:neighboard/src/user_side/forum_page/ui/forum_page/forum_page_mobile.dart';
import 'package:responsive_builder/responsive_builder.dart';

class AdminForum extends StatelessWidget {
  const AdminForum({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, sizingInformation) {
      if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
        return const AdminForumDesktop();
      } else if (sizingInformation.deviceScreenType ==
          DeviceScreenType.tablet) {
        return const Placeholder();
      } else {
        return const ForumPageMobile(
            isAdmin: true, screenType: DeviceScreenType.mobile);
        // return const AdminForumMobile(
        //   deviceScreenType: DeviceScreenType.mobile,
        // );
      }
    });
  }
}
