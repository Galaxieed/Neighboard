import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class VotersMobile extends StatefulWidget {
  const VotersMobile({super.key, required this.deviceScreenType});
  final DeviceScreenType deviceScreenType;
  @override
  State<VotersMobile> createState() => _VotersMobileState();
}

class _VotersMobileState extends State<VotersMobile> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
