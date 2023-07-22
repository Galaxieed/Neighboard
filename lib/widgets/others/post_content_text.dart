import 'package:flutter/material.dart';

class PostContentText extends StatelessWidget {
  const PostContentText({
    super.key,
    required this.content,
    this.maxLine,
    this.textOverflow,
  });

  final TextOverflow? textOverflow;
  final String content;
  final int? maxLine;

  @override
  Widget build(BuildContext context) {
    return Text(
      content,
      style: Theme.of(context).textTheme.bodyMedium,
      overflow: textOverflow,
      maxLines: maxLine,
      softWrap: true,
    );
  }
}
