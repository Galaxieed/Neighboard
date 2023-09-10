import 'package:flutter/material.dart';
import 'package:neighboard/routes/routes.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_bar.dart';

class AdminNavBar extends StatelessWidget implements PreferredSizeWidget {
  const AdminNavBar({Key? key})
      : preferredSize = const Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      actions: [
        const SizedBox(
          width: 10,
        ),
        const NavBarTitle(title: 'NEIGHBOARD'),
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
