import 'package:flutter/material.dart';
import 'package:neighboard/src/user_side/community_page/ui/stores_page/stores_desktop.dart';
import 'package:neighboard/src/user_side/community_page/ui/stores_page/stores_mobile.dart';
import 'package:responsive_builder/responsive_builder.dart';

class StoresPage extends StatelessWidget {
  const StoresPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, sizingInformation) {
      if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
        return const StoresDesktop(
          isAdmin: false,
        );
      } else if (sizingInformation.deviceScreenType ==
          DeviceScreenType.tablet) {
        return const Placeholder();
      } else {
        return const StoresMobile(
          deviceScreenType: DeviceScreenType.mobile,
          isAdmin: false,
        );
      }
    });
  }
}
