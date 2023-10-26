import 'package:flutter/material.dart';
import 'package:neighboard/routes/routes.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_bar.dart';

class AdminNavBar extends StatelessWidget implements PreferredSizeWidget {
  const AdminNavBar({Key? key, required this.callback})
      : preferredSize = const Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;
  final Function callback;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      actions: [
        const SizedBox(
          width: 10,
        ),
        NavBarTitle(
          title: 'NEIGHBOARD',
          isAdmin: true,
          callback: callback,
        ),
        const Spacer(),
        NavBarCircularImageDropDownButton(
          callback: Routes().navigate,
          isAdmin: true,
        ),
        const SizedBox(
          width: 10,
        ),
      ],
    );
  }
}
