import 'package:flutter/material.dart';
import 'package:neighboard/src/admin_side/hoa_voting/candidates/candidates_desktop.dart';
import 'package:neighboard/src/admin_side/hoa_voting/candidates/candidates_mobile.dart';
import 'package:responsive_builder/responsive_builder.dart';

class AdminHOACandidates extends StatelessWidget {
  const AdminHOACandidates({super.key, required this.drawer});

  final Function drawer;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, sizingInformation) {
      if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
        return CandidatesDesktop(
          drawer: drawer,
        );
      } else if (sizingInformation.deviceScreenType ==
          DeviceScreenType.tablet) {
        return const Placeholder();
      } else {
        return const CandidatesMobile(
          deviceScreenType: DeviceScreenType.mobile,
        );
      }
    });
  }
}
