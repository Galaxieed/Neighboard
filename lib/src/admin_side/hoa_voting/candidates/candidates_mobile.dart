import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class CandidatesMobile extends StatefulWidget {
  const CandidatesMobile({super.key, required this.deviceScreenType});

  final DeviceScreenType deviceScreenType;

  @override
  State<CandidatesMobile> createState() => _CandidatesMobileState();
}

class _CandidatesMobileState extends State<CandidatesMobile> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
