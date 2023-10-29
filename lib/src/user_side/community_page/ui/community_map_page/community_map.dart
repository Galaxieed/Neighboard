import 'package:flutter/material.dart';
import 'package:neighboard/src/user_side/community_page/ui/community_map_page/community_map_desktop.dart';
import 'package:neighboard/src/user_side/community_page/ui/community_map_page/community_map_mobile.dart';
import 'package:responsive_builder/responsive_builder.dart';

class CommunityMap extends StatelessWidget {
  const CommunityMap({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, sizingInformation) {
      if (sizingInformation.deviceScreenType == DeviceScreenType.mobile) {
        return const CommunityMapMobile(
          deviceScreenType: DeviceScreenType.mobile,
        );
      } else {
        return const CommunityMapDesktop();
      }
    });
  }
}
