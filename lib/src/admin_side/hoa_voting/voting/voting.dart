import 'package:flutter/material.dart';
import 'package:neighboard/src/admin_side/hoa_voting/voting/voting_desktop.dart';
import 'package:responsive_builder/responsive_builder.dart';

class AdminHOAVoting extends StatelessWidget {
  const AdminHOAVoting({super.key, required this.drawer});

  final Function drawer;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, sizingInformation) {
      if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
        return VotingDesktop(
            drawer: drawer, deviceScreenType: DeviceScreenType.desktop);
      } else if (sizingInformation.deviceScreenType ==
          DeviceScreenType.tablet) {
        return const Placeholder();
      } else {
        return VotingDesktop(
            drawer: drawer, deviceScreenType: DeviceScreenType.mobile);
      }
    });
  }
}
