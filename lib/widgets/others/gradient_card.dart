import 'package:flutter/material.dart';

class GradientCard extends StatelessWidget {
  final Widget child;
  final BorderRadiusGeometry? borderRadius;
  final List<Color>? colors;

  const GradientCard(
      {super.key, required this.child, this.borderRadius, this.colors});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: borderRadius == null
          ? null
          : RoundedRectangleBorder(borderRadius: borderRadius!),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Container(
        decoration: BoxDecoration(
          gradient: colors == null
              ? null
              : LinearGradient(
                  colors: colors!,
                ),
        ),
        child: child,
      ),
    );
  }
}
