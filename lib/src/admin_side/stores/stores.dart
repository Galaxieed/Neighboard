import 'package:flutter/material.dart';
import 'package:neighboard/src/user_side/community_page/ui/stores_page/stores_desktop.dart';
import 'package:neighboard/src/user_side/community_page/ui/stores_page/stores_mobile.dart';
import 'package:responsive_builder/responsive_builder.dart';

class AdminStores extends StatelessWidget {
  const AdminStores({super.key, required this.drawer});

  final Function drawer;
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, sizingInformation) {
      if (sizingInformation.deviceScreenType == DeviceScreenType.mobile) {
        return const StoresMobile(
          deviceScreenType: DeviceScreenType.mobile,
          isAdmin: true,
        );
      } else {
        return StoresDesktop(isAdmin: true, drawer: drawer);
      }
    });
  }
}
