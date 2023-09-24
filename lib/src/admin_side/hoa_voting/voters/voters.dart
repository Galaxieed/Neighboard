import 'package:flutter/material.dart';
import 'package:neighboard/src/admin_side/hoa_voting/voters/voters_desktop.dart';
import 'package:neighboard/src/admin_side/hoa_voting/voters/voters_mobile.dart';
import 'package:responsive_builder/responsive_builder.dart';

class AdminHOAVoters extends StatelessWidget {
  const AdminHOAVoters({super.key, required this.drawer});

  final Function drawer;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, sizingInformation) {
      if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
        return VotersDesktop(
          drawer: drawer,
        );
      } else if (sizingInformation.deviceScreenType ==
          DeviceScreenType.tablet) {
        return const Placeholder();
      } else {
        return const VotersMobile(
          deviceScreenType: DeviceScreenType.mobile,
        );
      }
    });
  }
}
