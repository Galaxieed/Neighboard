import 'package:flutter/material.dart';
import 'package:neighboard/src/user_side/community_page/ui/hoa_voting_page/hoa_voting_desktop.dart';
import 'package:neighboard/src/user_side/community_page/ui/hoa_voting_page/hoa_voting_mobile.dart';
import 'package:responsive_builder/responsive_builder.dart';

class HOAVoting extends StatelessWidget {
  const HOAVoting({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, sizingInformation) {
      if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
        return const HOAVotingDesktop();
      } else if (sizingInformation.deviceScreenType ==
          DeviceScreenType.tablet) {
        return const Placeholder();
      } else {
        return const HOAVotingMobile(
          deviceScreenType: DeviceScreenType.mobile,
        );
      }
    });
  }
}
