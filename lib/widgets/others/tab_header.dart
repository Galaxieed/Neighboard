import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TabHeader extends StatelessWidget {
  const TabHeader({
    super.key,
    required this.title,
    required this.callback,
  });
  final String title;
  final Function callback;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            callback();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        SizedBox(
          width: 2.w,
        ),
        Text(title,
            style: Theme.of(context)
                .textTheme
                .headlineSmall!
                .copyWith(fontWeight: FontWeight.bold, letterSpacing: 2.5))
      ],
    );
  }
}
