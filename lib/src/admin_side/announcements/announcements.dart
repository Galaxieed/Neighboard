import 'package:flutter/material.dart';
import 'package:neighboard/src/admin_side/announcements/announcement_desktop.dart';
import 'package:neighboard/src/admin_side/announcements/announcement_mobile.dart';
import 'package:responsive_builder/responsive_builder.dart';

class AdminAnnouncement extends StatelessWidget {
  const AdminAnnouncement({super.key, required this.drawer});

  final Function drawer;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, sizingInformation) {
      if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
        return AdminAnnouncementDesktop(drawer: drawer);
      } else if (sizingInformation.deviceScreenType ==
          DeviceScreenType.tablet) {
        return const Placeholder();
      } else {
        return const AdminAnnouncemetMobile(
          deviceScreenType: DeviceScreenType.mobile,
        );
      }
    });
  }
}
