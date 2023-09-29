import 'package:flutter/material.dart';
import 'package:neighboard/src/admin_side/site_settings/site_settings_desktop.dart';
import 'package:responsive_builder/responsive_builder.dart';

class AdminSiteSettings extends StatelessWidget {
  const AdminSiteSettings({super.key, required this.drawer});

  final void Function() drawer;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, sizingInformation) {
      if (sizingInformation.deviceScreenType == DeviceScreenType.mobile) {
        return SiteSettingsDesktop(
            drawer: drawer, deviceScreenType: DeviceScreenType.mobile);
      } else {
        return SiteSettingsDesktop(
          drawer: drawer,
          deviceScreenType: DeviceScreenType.desktop,
        );
      }
    });
  }
}
