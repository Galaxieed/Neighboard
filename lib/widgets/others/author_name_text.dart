import 'package:flutter/material.dart';

class AuthorNameText extends StatelessWidget {
  const AuthorNameText({
    super.key,
    required this.authorName,
  });

  final String authorName;

  @override
  Widget build(BuildContext context) {
    return Text(
      authorName,
      style:
      Theme.of(context).textTheme.titleSmall,
    );
  }
}