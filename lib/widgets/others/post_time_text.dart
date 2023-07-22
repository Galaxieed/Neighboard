import 'package:flutter/material.dart';

class PostTimeText extends StatelessWidget {
  const PostTimeText({
    super.key,
    required this.time,
  });

  final String time;

  @override
  Widget build(BuildContext context) {
    return Text(
      time,
      style:
      Theme.of(context).textTheme.labelSmall,
    );
  }
}