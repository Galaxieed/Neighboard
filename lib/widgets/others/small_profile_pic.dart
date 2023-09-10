import 'package:flutter/material.dart';

class SmallProfilePic extends StatelessWidget {
  const SmallProfilePic({
    super.key,
    required this.profilePic,
  });

  final String profilePic;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 30,
      backgroundImage: profilePic == ""
          ? null
          : NetworkImage(
              profilePic,
            ),
    );
  }
}
