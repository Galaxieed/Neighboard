import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class SiteSettingsMobile extends StatefulWidget {
  const SiteSettingsMobile({super.key, required this.deviceScreenType});

  final DeviceScreenType deviceScreenType;

  @override
  State<SiteSettingsMobile> createState() => _SiteSettingsMobileState();
}

class _SiteSettingsMobileState extends State<SiteSettingsMobile> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
