import "package:flutter/material.dart";
import 'package:neighboard/src/profile_screen/profile_screen_desktop.dart';
import 'package:neighboard/src/profile_screen/profile_screen_mobile.dart';
import "package:responsive_builder/responsive_builder.dart";

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.userId, required this.isAdmin});

  final String userId;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, sizingInformation) {
      if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
        return ProfileScreenDesktop(
          userId: userId,
          isAdmin: isAdmin,
        );
      } else if (sizingInformation.deviceScreenType ==
          DeviceScreenType.tablet) {
        return const Placeholder();
      } else {
        return ProfileScreenMobile(
          deviceScreenType: DeviceScreenType.mobile,
          userId: userId,
          isAdmin: isAdmin,
        );
      }
    });
  }
}
