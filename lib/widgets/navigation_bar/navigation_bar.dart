import 'package:flutter/material.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/routes/routes.dart';

class NavBar extends StatelessWidget implements PreferredSizeWidget {
  const NavBar({Key? key})
      : preferredSize = const Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 5,
      actions: [
        const SizedBox(
          width: 10,
        ),
        const NavBarTitle(title: 'NEIGHBOARD'),
        const Spacer(),
        NavBarTextButton(text: 'Home', callback: Routes().navigate),
        const SizedBox(
          width: 10,
        ),
        NavBarTextButton(text: 'Forum', callback: Routes().navigate),
        const SizedBox(
          width: 10,
        ),
        NavBarDropDownButton(callback: Routes().navigate),
        const SizedBox(
          width: 10,
        ),
        const NavBarBadges(count: '3'),
        const SizedBox(
          width: 10,
        ),
        NavBarCircularImageDropDownButton(
            image: homeImage, callback: Routes().navigate),
        const SizedBox(
          width: 10,
        ),
      ],
    );
  }
}

class NavBarTitle extends StatelessWidget {
  const NavBarTitle({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall,
    );
  }
}

class NavBarTextButton extends StatelessWidget {
  const NavBarTextButton({
    super.key,
    required this.text,
    required this.callback,
  });

  final String text;
  final Function callback;

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () {
          callback(text, context);
        },
        child: Text(text));
  }
}

class NavBarDropDownButton extends StatefulWidget {
  const NavBarDropDownButton({Key? key, required this.callback})
      : super(key: key);

  final Function callback;

  @override
  State<NavBarDropDownButton> createState() => _NavBarDropDownButtonState();
}

class _NavBarDropDownButtonState extends State<NavBarDropDownButton> {
  static const menuItems = <String>[
    'Announcements',
    'Community Map',
    'Stores',
    'HOA Voting',
  ];

  final List<PopupMenuItem<String>> _popUpMenuItems = menuItems
      .map(
        (String value) => PopupMenuItem<String>(
          value: value,
          child: Row(
            children: [
              value == 'Announcements'
                  ? const Icon(Icons.announcement)
                  : value == 'Community Map'
                      ? const Icon(Icons.map)
                      : value == 'Stores'
                          ? const Icon(Icons.shopping_cart)
                          : value == 'HOA Voting'
                              ? const Icon(Icons.how_to_vote)
                              : Container(),
              const SizedBox(
                width: 10,
              ),
              Text(value)
            ],
          ),
        ),
      )
      .toList();

  late String selectedValue;
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      position: PopupMenuPosition.under,
      tooltip: 'Show Community Options',
      child: IgnorePointer(
        ignoring: true,
        child: TextButton(onPressed: () {}, child: const Text('Community')),
      ),
      onSelected: (String newValue) {
        selectedValue = newValue;
        widget.callback(newValue, context);
      },
      itemBuilder: (BuildContext context) => _popUpMenuItems,
    );
  }
}

class NavBarBadges extends StatefulWidget {
  const NavBarBadges({Key? key, required this.count}) : super(key: key);

  final String count;

  @override
  State<NavBarBadges> createState() => _NavBarBadgesState();
}

class _NavBarBadgesState extends State<NavBarBadges> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Badge(
          label: Text(widget.count),
          child: const Icon(Icons.notifications_outlined),
        ),
      ),
    );
  }
}

class NavBarCircularImageDropDownButton extends StatefulWidget {
  const NavBarCircularImageDropDownButton(
      {Key? key, required this.callback, required this.image})
      : super(key: key);
  final String image;
  final Function callback;
  @override
  State<NavBarCircularImageDropDownButton> createState() =>
      _NavBarCircularImageDropDownButtonState();
}

class _NavBarCircularImageDropDownButtonState
    extends State<NavBarCircularImageDropDownButton> {
  static const menuItems = <String>[
    'User',
    'Login',
    'Register',
  ];

  final List<PopupMenuItem<String>> _popUpMenuItems = menuItems
      .map(
        (String value) => PopupMenuItem<String>(
          value: value,
          child: Row(
            children: [
              value == 'User'
                  ? const Icon(Icons.person)
                  : value == 'Login'
                      ? const Icon(Icons.login)
                      : value == 'Register'
                          ? const Icon(Icons.app_registration)
                          : Container(),
              const SizedBox(
                width: 10,
              ),
              Text(value)
            ],
          ),
        ),
      )
      .toList();

  late String selectedValue;
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      position: PopupMenuPosition.under,
      icon: CircleAvatar(
        backgroundImage: AssetImage(widget.image),
      ),
      //child: Icon(Icons.keyboard_arrow_down),
      onSelected: (String newValue) {
        selectedValue = newValue;
        widget.callback(newValue, context);
      },
      itemBuilder: (BuildContext context) => _popUpMenuItems,
    );
  }
}
