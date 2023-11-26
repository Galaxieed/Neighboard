import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:neighboard/models/user_model.dart';
import 'package:neighboard/routes/routes.dart';
import 'package:neighboard/screen_direct.dart';
import 'package:neighboard/src/user_side/forum_page/ui/all_posts/all_posts.dart';
import 'package:neighboard/src/user_side/forum_page/ui/anonymous_posts/anonymous_posts.dart';
import 'package:neighboard/src/user_side/forum_page/ui/categories/categories.dart';
import 'package:neighboard/src/user_side/forum_page/ui/my_posts/my_posts.dart';
import 'package:neighboard/src/user_side/forum_page/ui/new_post/new_post.dart';
import 'package:neighboard/src/user_side/forum_page/ui/search_page/search_ui.dart';
import 'package:neighboard/src/profile_screen/profile_screen_function.dart';
import 'package:neighboard/src/user_side/login_register_page/login_page/login_page_ui.dart';
import 'package:neighboard/src/user_side/login_register_page/register_page/register_page_ui.dart';
import 'package:neighboard/widgets/chat/chat.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_bar.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_drawer.dart';
import 'package:neighboard/widgets/notification/notification_drawer.dart';
import 'package:responsive_builder/responsive_builder.dart';

class ForumPageMobile extends StatefulWidget {
  const ForumPageMobile(
      {super.key, required this.screenType, required this.isAdmin});

  final DeviceScreenType screenType;
  final bool isAdmin;

  @override
  State<ForumPageMobile> createState() => _ForumPageMobileState();
}

class _ForumPageMobileState extends State<ForumPageMobile>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String searchedText = "";
  String categoryText = "";
  late TabController _tabController;
  UserModel? userModel;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoggedIn = false;
  final scrollController = ScrollController();

  void getCurrentUserDetails() async {
    if (_auth.currentUser != null) {
      isLoggedIn = true;
      userModel = await ProfileFunction.getUserDetails(_auth.currentUser!.uid);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _openChat() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      context: context,
      builder: (context) {
        return const MyChat();
      },
    );
  }

  void _openNotification() {
    _scaffoldKey.currentState!.openEndDrawer();
  }

  void _showPopupMenu(Offset offset) async {
    categoryText = "";
    final screenSize = MediaQuery.of(context).size;
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy,
        screenSize.width - offset.dx,
        screenSize.height - offset.dy,
      ),
      items: [
        PopupMenuItem(
            onTap: () {
              categoryText = '';
              _tabController.animateTo(1);
              setState(() {});
            },
            child: const Text("All Posts")),
        PopupMenuItem(
            onTap: () {
              categoryText = 'General Discussion';
            },
            child: const Text("General Discussion")),
        PopupMenuItem(
            onTap: () {
              categoryText = 'Garbage Collection';
            },
            child: const Text("Garbage Collection")),
        PopupMenuItem(
            onTap: () {
              categoryText = 'Parking Space';
            },
            child: const Text("Parking Space")),
        PopupMenuItem(
            onTap: () {
              categoryText = 'Water Billing';
            },
            child: const Text("Water Billing")),
        PopupMenuItem(
            onTap: () {
              categoryText = 'Electric Billing';
            },
            child: const Text("Electric Billing")),
        PopupMenuItem(
            onTap: () {
              categoryText = 'Power Interruption';
            },
            child: const Text("Power Interruption")),
        PopupMenuItem(
            onTap: () {
              categoryText = 'Clubhouse Fees and Rental';
            },
            child: const Text("Clubhouse Fees and Rental")),
        PopupMenuItem(
            onTap: () {
              categoryText = 'Marketplace/Business';
            },
            child: const Text('Marketplace/Business')),
      ],
      elevation: 8.0,
    ).then((value) {
      if (categoryText != "") {
        _tabController.animateTo(1);
        setState(() {});
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        initialIndex: 1, length: widget.isAdmin ? 5 : 4, vsync: this);
    if (_auth.currentUser != null) {
      getCurrentUserDetails();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      appBar: widget.isAdmin
          ? null
          : AppBar(
              actions: [
                IconButton(
                  onPressed: () async {
                    await showSearch(
                      context: context,
                      delegate: SearchScreenUI(widget.screenType),
                    );
                  },
                  icon: const Icon(Icons.search),
                  tooltip: "Search Post Title",
                ),
                const SizedBox(
                  width: 10,
                ),
                //TODO: Chat count
                if (isLoggedIn)
                  NavBarBadges(
                    count: null,
                    icon: const Icon(Icons.chat_outlined),
                    callback: _openChat,
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
                    callback: _openNotification,
                  )
                else
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const LoginPage()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor:
                          Theme.of(context).colorScheme.onBackground,
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
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RegisterPage()));
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor:
                          Theme.of(context).colorScheme.inversePrimary,
                      foregroundColor:
                          Theme.of(context).colorScheme.onBackground,
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
                )
              ],
            ),
      bottomNavigationBar: TabBar(
        isScrollable: true,
        onTap: (value) {
          setState(() {
            _tabController.index = value;
          });
        },
        tabs: [
          const SizedBox(
            width: 70,
            child: Tab(
              icon: Icon(FontAwesomeIcons.userSecret),
              text: "Anon.",
            ),
          ),
          if (widget.isAdmin)
            const SizedBox(
              width: 70,
              child: Tab(
                icon: Icon(Icons.pending_actions_outlined),
                text: "Pending",
              ),
            ),
          const SizedBox(
            width: 70,
            child: Tab(
              icon: Icon(Icons.forum_rounded),
              text: "Posts",
            ),
          ),
          const SizedBox(
            width: 70,
            child: Tab(
              icon: Icon(Icons.my_library_books_rounded),
              text: "My Posts",
            ),
          ),
          const SizedBox(
            width: 70,
            child: Tab(
              icon: Icon(Icons.add),
              text: "New Post",
            ),
          ),
        ],
        controller: _tabController,
      ),
      drawer: widget.screenType == DeviceScreenType.mobile
          ? NavDrawer(
              isLoggedIn: isLoggedIn,
            )
          : null,
      endDrawer: NotificationDrawer(
        deviceScreenType: DeviceScreenType.mobile,
        stateSetter: setState,
      ),
      floatingActionButton: widget.isAdmin || _tabController.index != 1
          ? null
          : GestureDetector(
              onTapDown: (TapDownDetails details) {
                _showPopupMenu(details.globalPosition);
              },
              child: const FloatingActionButton(
                onPressed: null,
                child: Icon(Icons.category),
              ),
            ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  AnonymousPosts(
                      searchedText: searchedText,
                      isAdmin: false,
                      deviceScreenType: DeviceScreenType.desktop),
                  if (widget.isAdmin)
                    Categories(
                      searchedText: searchedText,
                      category: categoryText,
                      isAdmin: widget.isAdmin,
                      scrollController: scrollController,
                      deviceScreenType: widget.screenType,
                    ),
                  AllPosts(
                    searchedText: searchedText,
                    category: categoryText,
                    isAdmin: widget.isAdmin,
                    deviceScreenType: widget.screenType,
                  ),
                  MyPosts(search: searchedText),
                  NewPost(
                    deviceScreenType: widget.screenType,
                    isAdmin: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
