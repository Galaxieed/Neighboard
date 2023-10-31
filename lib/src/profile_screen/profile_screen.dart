import "package:flutter/material.dart";
import 'package:neighboard/src/profile_screen/profile_screen_desktop.dart';
import 'package:neighboard/src/profile_screen/profile_screen_mobile.dart';
import "package:responsive_builder/responsive_builder.dart";

class ProfileScreen extends StatelessWidget {
  const ProfileScreen(
      {super.key,
      required this.userId,
      required this.isAdmin,
      required this.stateSetter});

  final String userId;
  final bool isAdmin;
  final Function stateSetter;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, sizingInformation) {
      if (sizingInformation.deviceScreenType == DeviceScreenType.mobile) {
        return ProfileScreenMobile(
          deviceScreenType: DeviceScreenType.mobile,
          userId: userId,
          isAdmin: isAdmin,
        );
      } else {
        return ProfileScreenDesktop(
          userId: userId,
          isAdmin: isAdmin,
          stateSetter: stateSetter,
        );
      }
    });
  }
}
