import 'package:flutter/material.dart';
import 'package:neighboard/src/user_side/login_register_page/register_page/register_page_desktop.dart';
import 'package:neighboard/src/user_side/login_register_page/register_page/register_page_mobile.dart';
import 'package:responsive_builder/responsive_builder.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, sizingInformation) {
      if (sizingInformation.deviceScreenType == DeviceScreenType.mobile) {
        return const RegisterPageMobile(
          deviceScreenType: DeviceScreenType.mobile,
        );
      } else {
        return const RegisterPageDesktop();
      }
    });
  }
}
