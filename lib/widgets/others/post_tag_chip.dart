import 'package:flutter/material.dart';

class PostTagChip extends StatelessWidget {
  const PostTagChip({
    super.key,
    required this.tag,
  });

  final String tag;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: CircleAvatar(
        backgroundColor: Theme.of(context).secondaryHeaderColor,
        child: Text(tag.substring(0,1)),
      ),
      label: Text(tag,
        style: Theme.of(context).textTheme.labelSmall,),
      backgroundColor: Theme.of(context).disabledColor,
      side: BorderSide.none,
      onPressed: (){

      },
    );
  }
}
