import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:neighboard/main.dart';
import 'package:neighboard/models/user_model.dart';
import 'package:neighboard/routes/routes.dart';
import 'package:neighboard/screen_direct.dart';
import 'package:neighboard/shared_preferences/shared_preferences.dart';
import 'package:neighboard/src/user_side/login_register_page/login_page/login_function.dart';
import 'package:neighboard/src/profile_screen/profile_screen.dart';
import 'package:neighboard/src/profile_screen/profile_screen_function.dart';
import 'package:neighboard/src/user_side/login_register_page/login_page/login_page_ui.dart';
import 'package:neighboard/src/user_side/login_register_page/register_page/register_page_ui.dart';

// ignore: must_be_immutable
class NavBar extends StatelessWidget implements PreferredSizeWidget {
  NavBar(
      {Key? key,
      this.openNotification,
      this.openChat,
      required this.currentPage})
      : preferredSize = const Size.fromHeight(kToolbarHeight),
        super(key: key);
  final Function? openNotification, openChat;
  @override
  final Size preferredSize;
  final String currentPage;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoggedIn = false;
  void checkIfLoggedIn() {
    if (_auth.currentUser != null) {
      isLoggedIn = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    checkIfLoggedIn();
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      actions: [
        const SizedBox(
          width: 10,
        ),
        const NavBarTitle(
          title: 'NEIGHBOARD',
          isAdmin: false,
        ),
        const Spacer(),
        NavBarTextButton(
          text: 'Home',
          callback: Routes().navigate,
          currentPage: currentPage,
        ),
        const SizedBox(
          width: 10,
        ),
        NavBarTextButton(
          text: 'Forum',
          callback: Routes().navigate,
          currentPage: currentPage,
        ),
        const SizedBox(
          width: 5,
        ),
        NavBarDropDownButton(
          callback: Routes().navigate,
          currentPage: currentPage,
        ),
        const SizedBox(
          width: 10,
        ),
        const LightDarkMode(),
        const SizedBox(
          width: 10,
        ),
        if (isLoggedIn)
          NavBarBadges(
            count: null,
            icon: const Icon(Icons.chat_outlined),
            callback: () {
              openChat != null ? openChat!() : null;
            },
          ),
        if (isLoggedIn)
          const SizedBox(
            width: 10,
          ),
        if (isLoggedIn)
          NavBarBadges(
            count: notificationModels
                .where((element) => !element.isRead)
                .toList()
                .length
                .toString(),
            icon: const Icon(Icons.notifications_outlined),
            callback: () {
              openNotification != null ? openNotification!() : null;
            },
          )
        else
          ElevatedButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const LoginPage()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Theme.of(context).colorScheme.onBackground,
              elevation: 0,
            ),
            child: const Text(
              "Login",
              style: TextStyle(
                letterSpacing: 1,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        const SizedBox(
          width: 10,
        ),
        if (isLoggedIn)
          NavBarCircularImageDropDownButton(
            callback: Routes().navigate,
            isAdmin: false,
          )
        else
          ElevatedButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const RegisterPage()));
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              foregroundColor: Theme.of(context).colorScheme.onBackground,
            ),
            child: const Text(
              "Register",
              style: TextStyle(
                letterSpacing: 1,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        const SizedBox(
          width: 10,
        ),
      ],
    );
  }
}

class NavBarTitle extends StatelessWidget {
  const NavBarTitle(
      {Key? key, required this.title, required this.isAdmin, this.callback})
      : super(key: key);

  final String title;
  final bool isAdmin;
  final Function? callback;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        isAdmin ? callback!(1) : Routes().navigate("Home", context);
      },
      child: Row(
        children: [
          siteModel == null
              ? const Icon(Icons.api_sharp)
              : siteModel!.siteLogo == ''
                  ? const Icon(Icons.api_sharp)
                  : Image.network(
                      isDarkMode
                          ? siteModel!.siteLogoDark != ''
                              ? siteModel!.siteLogoDark
                              : siteModel!.siteLogo
                          : siteModel!.siteLogo,
                      fit: BoxFit.contain,
                      height: 40,
                    ),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class NavBarTextButton extends StatefulWidget {
  const NavBarTextButton({
    super.key,
    required this.text,
    required this.callback,
    required this.currentPage,
  });

  final String text;
  final Function callback;
  final String currentPage;

  @override
  State<NavBarTextButton> createState() => _NavBarTextButtonState();
}

class _NavBarTextButtonState extends State<NavBarTextButton> {
  bool _isHovering = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) => setState(() => _isHovering = true),
      onExit: (event) => setState(() => _isHovering = false),
      child: Container(
        decoration: BoxDecoration(
          border: _isHovering || widget.currentPage == widget.text
              ? Border(
                  bottom: BorderSide(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    width: 2.0,
                  ),
                )
              : null,
        ),
        child: TextButton(
          onPressed: () {
            widget.callback(widget.text, context);
          },
          style: ButtonStyle(
            overlayColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.hovered)) {
                  return Colors.transparent;
                }
                return Colors.transparent;
                // Use the component's default.
              },
            ),
          ),
          child: Text(
            widget.text,
            style: TextStyle(
              letterSpacing: 1,
              fontWeight: FontWeight.bold,
              color: _isHovering || widget.currentPage == widget.text
                  ? Theme.of(context).colorScheme.inversePrimary
                  : isDarkMode
                      ? Colors.white
                      : Theme.of(context)
                          .colorScheme
                          .onBackground
                          .withOpacity(.7),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

class NavBarDropDownButton extends StatefulWidget {
  const NavBarDropDownButton(
      {Key? key, required this.callback, required this.currentPage})
      : super(key: key);

  final Function callback;
  final String currentPage;

  @override
  State<NavBarDropDownButton> createState() => _NavBarDropDownButtonState();
}

class _NavBarDropDownButtonState extends State<NavBarDropDownButton> {
  bool _isHovering = false;
  static const menuItems = <String>[
    'Announcements',
    'Community Map',
    'Stores',
    'HOA Voting',
  ];

  List<PopupMenuItem<String>> _popUpMenuItems(context) => menuItems
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
                          ? const Icon(Icons.store)
                          : value == 'HOA Voting'
                              ? const Icon(Icons.how_to_vote)
                              : Container(),
              const SizedBox(
                width: 10,
              ),
              Text(
                value,
                style: const TextStyle(letterSpacing: 1.5),
                overflow: TextOverflow.ellipsis,
              )
            ],
          ),
        ),
      )
      .toList();

  late String selectedValue;
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        highlightColor: Colors.transparent, // Change this to the color you want
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
      child: MouseRegion(
        onHover: (event) => setState(() => _isHovering = true),
        onExit: (event) => setState(() => _isHovering = false),
        child: Container(
          decoration: BoxDecoration(
            border: _isHovering || widget.currentPage == "Community"
                ? Border(
                    bottom: BorderSide(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      width: 2.0,
                    ),
                  )
                : null,
          ),
          child: PopupMenuButton<String>(
            position: PopupMenuPosition.under,
            tooltip: 'Show Community Options',
            onSelected: (String newValue) {
              selectedValue = newValue;
              widget.callback(newValue, context);
            },
            itemBuilder: (BuildContext context) => _popUpMenuItems(context),
            child: IgnorePointer(
              ignoring: true,
              child: TextButton(
                onPressed: () {},
                child: Text(
                  'Community',
                  style: TextStyle(
                    letterSpacing: 1,
                    fontWeight: FontWeight.bold,
                    color: _isHovering || widget.currentPage == "Community"
                        ? Theme.of(context).colorScheme.inversePrimary
                        : isDarkMode
                            ? Colors.white
                            : Theme.of(context)
                                .colorScheme
                                .onBackground
                                .withOpacity(.7),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LightDarkMode extends StatefulWidget {
  const LightDarkMode({super.key});

  @override
  State<LightDarkMode> createState() => _LightDarkModeState();
}

class _LightDarkModeState extends State<LightDarkMode> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          isDarkMode = !isDarkMode;
          SharedPrefHelper.saveThemeMode(isDarkMode);
          themeNotifier.value = themeNotifier.value == ThemeMode.light
              ? ThemeMode.dark
              : ThemeMode.light;
          setState(() {});
        },
        icon: isDarkMode
            ? const Icon(Icons.light_mode_outlined)
            : const Icon(Icons.dark_mode_outlined));
  }
}

class NavBarBadges extends StatefulWidget {
  const NavBarBadges({
    Key? key,
    this.count,
    required this.icon,
    required this.callback,
  }) : super(key: key);

  final String? count;
  final Icon icon;
  final Function callback;

  @override
  State<NavBarBadges> createState() => _NavBarBadgesState();
}

class _NavBarBadgesState extends State<NavBarBadges> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: () {
        widget.callback();
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Badge(
          label: widget.count != null ? Text(widget.count!) : null,
          backgroundColor: Colors.blue,
          isLabelVisible:
              widget.count == null || widget.count == "0" ? false : true,
          child: widget.icon,
        ),
      ),
    );
  }
}

class NavBarCircularImageDropDownButton extends StatefulWidget {
  const NavBarCircularImageDropDownButton(
      {Key? key, required this.callback, required this.isAdmin})
      : super(key: key);
  final Function callback;
  final bool isAdmin;

  @override
  State<NavBarCircularImageDropDownButton> createState() =>
      _NavBarCircularImageDropDownButtonState();
}

class _NavBarCircularImageDropDownButtonState
    extends State<NavBarCircularImageDropDownButton> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  UserModel? userModel;
  bool isLoading = true;

  Future<void> getUserDetails() async {
    userModel = await ProfileFunction.getUserDetails(_auth.currentUser!.uid);
    setState(() {
      isLoading = false;
    });
  }

  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    isLoggedIn = _auth.currentUser != null;
    if (isLoggedIn) {
      getUserDetails();
    }
  }

  late String selectedValue;
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
        position: PopupMenuPosition.under,
        icon: isLoading
            ? !isLoggedIn
                ? const CircleAvatar(
                    child: Icon(Icons.person),
                  )
                : const CircularProgressIndicator()
            : userModel!.profilePicture.isEmpty
                ? const CircleAvatar(
                    child: Icon(Icons.person),
                  )
                : CircleAvatar(
                    backgroundImage: NetworkImage(userModel!.profilePicture),
                  ),
        //child: Icon(Icons.keyboard_arrow_down),
        onSelected: (String newValue) async {
          if (newValue == "Logout") {
            await LoginFunction.logout();
            notifSubscription?.cancel();
            chatSubscription?.cancel();
            notificationModels.clear();
            // ignore: use_build_context_synchronously
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const ScreenDirect()),
                (route) => false);
          } else if (newValue == "User") {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                        userId: userModel!.userId,
                        isAdmin: widget.isAdmin,
                      )),
            );
          } else {
            selectedValue = newValue;
            widget.callback(newValue, context);
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              if (!widget.isAdmin)
                isLoggedIn
                    ? PopupMenuItem(
                        value: "User",
                        child: Row(
                          children: [
                            userModel!.profilePicture.isEmpty
                                ? const CircleAvatar()
                                : CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(userModel!.profilePicture),
                                  ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(userModel!.username),
                          ],
                        ),
                      )
                    : const PopupMenuItem(
                        value: "Login",
                        child: Row(
                          children: [
                            Icon(Icons.login),
                            SizedBox(
                              width: 10,
                            ),
                            Text('Login'),
                          ],
                        ),
                      ),
              isLoggedIn
                  ? const PopupMenuItem(
                      value: "Logout",
                      child: Row(
                        children: [
                          Icon(Icons.logout),
                          SizedBox(
                            width: 10,
                          ),
                          Text("Logout"),
                        ],
                      ),
                    )
                  : const PopupMenuItem(
                      value: "Register",
                      child: Row(
                        children: [
                          Icon(Icons.app_registration),
                          SizedBox(
                            width: 10,
                          ),
                          Text('Register'),
                        ],
                      ),
                    ),
            ]);
  }
}
