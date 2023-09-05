import 'package:flutter/material.dart';
import 'package:neighboard/src/admin_side/admin_desktop.dart';
import 'package:neighboard/src/admin_side/admin_mobile.dart';
import 'package:responsive_builder/responsive_builder.dart';

class AdminSide extends StatelessWidget {
  const AdminSide({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, sizingInformation) {
      if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
        return const AdminDesktop();
      } else if (sizingInformation.deviceScreenType ==
          DeviceScreenType.tablet) {
        return const Placeholder();
      } else {
        return const AdminMobile(
          deviceScreenType: DeviceScreenType.mobile,
        );
      }
    });
  }
}
