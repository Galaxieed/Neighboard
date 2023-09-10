import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:neighboard/src/admin_side/announcements/announcements.dart';
import 'package:neighboard/src/admin_side/community_map/community_map.dart';
import 'package:neighboard/src/admin_side/dashboard/dashboard.dart';
import 'package:neighboard/src/admin_side/forum/forum.dart';
import 'package:neighboard/src/admin_side/hoa_voting/candidates/candidates.dart';
import 'package:neighboard/src/admin_side/hoa_voting/voters/voters.dart';
import 'package:neighboard/src/admin_side/hoa_voting/voting/voting.dart';
import 'package:neighboard/src/admin_side/navigation/navigation_bar.dart';
import 'package:neighboard/src/admin_side/site_settings/site_settings.dart';
import 'package:neighboard/src/admin_side/stores/stores.dart';
import 'package:neighboard/src/landing_page/ui/landing_page.dart';
import 'package:neighboard/src/profile_screen/profile_screen.dart';

class AdminDesktop extends StatefulWidget {
  const AdminDesktop({super.key});

  @override
  State<AdminDesktop> createState() => _AdminDesktopState();
}

class _AdminDesktopState extends State<AdminDesktop> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoggedIn = false;

  bool checkIfLoggedIn() {
    if (_auth.currentUser != null) {
      return isLoggedIn = true;
    }
    //Navigator.pop(context);

    return isLoggedIn = false;
  }

  String selectedPage = "Dashboard";

  bool isDrawerExpanded = true;

  void onExpandCollapseDrawer() {
    setState(() {
      isDrawerExpanded = !isDrawerExpanded;
    });
  }

  switchPage(controller, int index) {
    if (!controller.indexIsChanging) {
      if (index == 0) {
        selectedPage = "User";
      } else if (index == 1) {
        selectedPage = "Dashboard";
      } else if (index == 2) {
        selectedPage = "Forum";
      } else if (index == 3) {
        selectedPage = "Announcements";
      } else if (index == 4) {
        selectedPage = "Community Map";
      } else if (index == 5) {
        selectedPage = "Stores";
      } else if (index == 6) {
        selectedPage = "Candidates";
      } else if (index == 7) {
        selectedPage = "Voting";
      } else if (index == 8) {
        selectedPage = "Voters";
      } else if (index == 9) {
        selectedPage = "Site Settings";
      }

      controller.animateTo(index);
    }
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkIfLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminNavBar(),
      body: DefaultTabController(
        initialIndex: 1,
        length: 10,
        child: Builder(
          builder: (context) {
            final TabController controller = DefaultTabController.of(context);
            return Row(
              children: [
                MyDrawer(
                  selectedPage: selectedPage,
                  isDrawerExpanded: isDrawerExpanded,
                  callback: (index) {
                    switchPage(controller, index);
                  },
                ),
                Expanded(
                  child: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      isLoggedIn
                          ? ProfileScreen(
                              userId: _auth.currentUser!.uid,
                              isAdmin: true,
                            )
                          : const Placeholder(),
                      Dashboard(callback: (i) {
                        switchPage(controller, i);
                      }),
                      const AdminForum(),
                      AdminAnnouncement(drawer: onExpandCollapseDrawer),
                      const AdminCommunityMap(),
                      AdminStores(drawer: onExpandCollapseDrawer),
                      AdminHOACandidates(
                        drawer: onExpandCollapseDrawer,
                      ),
                      const AdminHOAVoting(),
                      const AdminHOAVoters(),
                      AdminSiteSettings(
                        drawer: onExpandCollapseDrawer,
                      ),
                    ],
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}

class MyDrawer extends StatefulWidget {
  const MyDrawer(
      {super.key,
      required this.callback,
      required this.selectedPage,
      required this.isDrawerExpanded});

  final Function callback;
  final String selectedPage;
  final bool isDrawerExpanded;

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  final ExpansionTileController _controller = ExpansionTileController();
  String selectedSubButton = "";

  changingButton(String newValue) {
    setState(() {
      selectedSubButton = newValue;
      if (newValue == 'User') {
        widget.callback(0);
      }
      if (newValue == 'Dashboard') {
        widget.callback(1);
      }
      if (newValue == 'Forum') {
        widget.callback(2);
      }
      if (newValue == 'Announcements') {
        widget.callback(3);
      }
      if (newValue == 'Community Map') {
        widget.callback(4);
      }
      if (newValue == 'Stores') {
        widget.callback(5);
      }
      if (newValue == 'Candidates') {
        widget.callback(6);
      }
      if (newValue == 'Voting') {
        widget.callback(7);
      }
      if (newValue == 'Voters') {
        widget.callback(8);
      }
      if (newValue == 'Site Settings') {
        widget.callback(9);
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedSubButton = widget.selectedPage;
  }

  @override
  void didUpdateWidget(covariant MyDrawer oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    selectedSubButton = widget.selectedPage;
    if (selectedSubButton == "Voting") {
      _controller.expand();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      color: Colors.grey[300]!.withOpacity(0.3),
      width: widget.isDrawerExpanded ? 304 : 95,
      duration: const Duration(milliseconds: 500),
      curve: Curves.decelerate,
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: 8,
        separatorBuilder: (BuildContext context, int index) {
          return const Divider(
            color: Colors.grey,
            height: 1,
          );
        },
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return ListTile(
              minVerticalPadding: 30,
              leading: const CircleAvatar(
                radius: 25,
                child: Icon(Icons.person),
              ),
              title: const Text(
                "User",
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                changingButton("User");
              },
              selected: selectedSubButton == "User",
              selectedColor: Theme.of(context).colorScheme.onBackground,
              selectedTileColor: Colors.amber,
            );
          }

          if (index == 6) {
            return Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                controller: _controller,
                textColor: Theme.of(context).primaryColor,
                iconColor: Theme.of(context).primaryColor,
                tilePadding: const EdgeInsets.only(left: 0, right: 5),
                title: const Row(
                  children: <Widget>[
                    SizedBox(
                      width: 16,
                    ),
                    Icon(Icons.people),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        "HOA Voting",
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                        bottom: BorderSide(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: drawerItem(
                        context,
                        Icons.people_outline,
                        "Candidates",
                        selectedSubButton == "Candidates",
                        const EdgeInsets.only(left: 50)),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: drawerItem(
                        context,
                        Icons.how_to_vote,
                        "Voting",
                        selectedSubButton == "Voting",
                        const EdgeInsets.only(left: 50)),
                  ),
                  drawerItem(
                      context,
                      Icons.card_membership_outlined,
                      "Voters",
                      selectedSubButton == "Voters",
                      const EdgeInsets.only(left: 50)),
                ],
              ),
            );
          }
          if (index == 1) {
            return drawerItem(context, Icons.dashboard_outlined, "Dashboard",
                selectedSubButton == "Dashboard");
          }
          if (index == 2) {
            return drawerItem(context, Icons.forum_outlined, "Forum",
                selectedSubButton == "Forum");
          }
          if (index == 3) {
            return drawerItem(context, Icons.announcement_outlined,
                "Announcements", selectedSubButton == "Announcements");
          }
          if (index == 4) {
            return drawerItem(context, Icons.map_outlined, "Community Map",
                selectedSubButton == "Community Map");
          }
          if (index == 5) {
            return drawerItem(context, Icons.store_outlined, "Stores",
                selectedSubButton == "Stores");
          }
          if (index == 7) {
            return drawerItem(context, Icons.settings_outlined, "Site Settings",
                selectedSubButton == "Site Settings");
          } else {
            return null;
          }
        },
      ),
    );
  }

  ListTile drawerItem(
      BuildContext context, IconData icon, String title, bool isSelected,
      [EdgeInsetsGeometry? padding]) {
    return ListTile(
      contentPadding: padding,
      leading: Icon(icon),
      title: Text(
        title,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        changingButton(title);
        setState(() {});
      },
      selected: isSelected,
      selectedColor: Theme.of(context).colorScheme.onBackground,
      selectedTileColor: Theme.of(context).colorScheme.inversePrimary,
    );
  }
}
