import 'package:flutter/material.dart';
import 'package:neighboard/src/user_side/login_register_page/login_page/login_page_desktop.dart';
import 'package:neighboard/src/user_side/login_register_page/login_page/login_page_mobile.dart';
import 'package:responsive_builder/responsive_builder.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, sizingInformation) {
      if (sizingInformation.deviceScreenType == DeviceScreenType.mobile) {
        return const LoginPageMobile(
          deviceScreenType: DeviceScreenType.mobile,
        );
      } else {
        return const LoginPageDesktop();
      }
    });
  }
}
