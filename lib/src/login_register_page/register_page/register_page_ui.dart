import 'package:flutter/material.dart';
import 'package:neighboard/src/login_register_page/register_page/register_page_desktop.dart';
import 'package:neighboard/src/login_register_page/register_page/register_page_mobile.dart';
import 'package:responsive_builder/responsive_builder.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, sizingInformation) {
      if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
        return const RegisterPageDesktop();
      } else if (sizingInformation.deviceScreenType ==
          DeviceScreenType.tablet) {
        return const Placeholder();
      } else {
        return const RegisterPageMobile(
          deviceScreenType: DeviceScreenType.mobile,
        );
      }
    });
  }
}
