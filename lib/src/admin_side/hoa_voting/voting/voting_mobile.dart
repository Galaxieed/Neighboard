import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class VotingMobile extends StatefulWidget {
  const VotingMobile({super.key, required this.deviceScreenType});
  final DeviceScreenType deviceScreenType;
  @override
  State<VotingMobile> createState() => _VotingMobileState();
}

class _VotingMobileState extends State<VotingMobile> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
