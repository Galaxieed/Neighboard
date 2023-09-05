import 'package:flutter/material.dart';
import 'package:neighboard/src/user_side/community_page/ui/announcement_page/announcement_desktop.dart';
import 'package:neighboard/src/user_side/community_page/ui/announcement_page/announcement_mobile.dart';
import 'package:responsive_builder/responsive_builder.dart';

class AnnouncementPage extends StatelessWidget {
  const AnnouncementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, sizingInformation) {
      if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
        return const AnnouncementDesktop();
      } else if (sizingInformation.deviceScreenType ==
          DeviceScreenType.tablet) {
        return const Placeholder();
      } else {
        return const AnnouncementMobile(
          deviceScreenType: DeviceScreenType.mobile,
        );
      }
    });
  }
}
