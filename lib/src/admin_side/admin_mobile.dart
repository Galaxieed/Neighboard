import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neighboard/models/user_model.dart';
import 'package:neighboard/routes/routes.dart';
import 'package:neighboard/src/admin_side/announcements/announcements.dart';
import 'package:neighboard/src/admin_side/community_map/community_map.dart';
import 'package:neighboard/src/admin_side/dashboard/dashboard.dart';
import 'package:neighboard/src/admin_side/forum/forum.dart';
import 'package:neighboard/src/admin_side/hoa_voting/candidates/candidates.dart';
import 'package:neighboard/src/admin_side/hoa_voting/voters/voters.dart';
import 'package:neighboard/src/admin_side/hoa_voting/voting/voting.dart';
import 'package:neighboard/src/admin_side/navigation/navigation_drawer.dart';
import 'package:neighboard/src/admin_side/site_settings/site_settings.dart';
import 'package:neighboard/src/admin_side/stores/stores.dart';
import 'package:neighboard/src/loading_screen/loading_screen.dart';
import 'package:neighboard/src/profile_screen/profile_screen.dart';
import 'package:neighboard/src/profile_screen/profile_screen_function.dart';
import 'package:neighboard/src/user_side/forum_page/ui/search_page/search_ui.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_bar.dart';
import 'package:responsive_builder/responsive_builder.dart';

class AdminMobile extends StatefulWidget {
  const AdminMobile({super.key, required this.deviceScreenType});

  final DeviceScreenType deviceScreenType;

  @override
  State<AdminMobile> createState() => _AdminMobileState();
}

class _AdminMobileState extends State<AdminMobile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  UserModel? userModel;
  bool isLoggedIn = false;
  bool isLoading = true;

  getCurrentUserDetails() async {
    userModel = await ProfileFunction.getUserDetails(_auth.currentUser!.uid);

    setState(() {
      isLoading = false;
    });
  }

  bool checkIfLoggedIn() {
    if (_auth.currentUser != null) {
      getCurrentUserDetails();
      return isLoggedIn = true;
    }
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
    super.initState();
    checkIfLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const LoadingScreen()
        : DefaultTabController(
            initialIndex: 1,
            length: 10,
            child: Builder(builder: (context) {
              final TabController controller = DefaultTabController.of(context);
              return Scaffold(
                appBar: AppBar(
                  title: Text(selectedPage),
                  centerTitle: false,
                  actions: [
                    if (selectedPage == "Forum")
                      IconButton(
                        onPressed: () async {
                          await showSearch(
                            context: context,
                            delegate: SearchScreenUI(widget.deviceScreenType),
                          );
                        },
                        icon: const Icon(Icons.search),
                        tooltip: "Search Post Title",
                      ),
                    NavBarCircularImageDropDownButton(
                      callback: Routes().navigate,
                      isAdmin: true,
                    ),
                    SizedBox(
                      width: 2.5.w,
                    )
                  ],
                ),
                drawer: AdminNavDrawer(
                  userModel: userModel!,
                  selectedPage: selectedPage,
                  isDrawerExpanded: isDrawerExpanded,
                  callback: (index) {
                    switchPage(controller, index);
                    Navigator.pop(context);
                  },
                ),
                body: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    isLoggedIn
                        ? ProfileScreen(
                            userId: _auth.currentUser!.uid,
                            isAdmin: true,
                          )
                        : const Placeholder(),
                    Dashboard(
                      callback: (i) {
                        switchPage(controller, i);
                      },
                      deviceScreenType: widget.deviceScreenType,
                    ),
                    const AdminForum(),
                    AdminAnnouncement(drawer: onExpandCollapseDrawer),
                    AdminCommunityMap(
                        deviceScreenType: widget.deviceScreenType),
                    AdminStores(drawer: onExpandCollapseDrawer),
                    AdminHOACandidates(
                      drawer: onExpandCollapseDrawer,
                    ),
                    AdminHOAVoting(
                      drawer: onExpandCollapseDrawer,
                    ),
                    AdminHOAVoters(
                      drawer: onExpandCollapseDrawer,
                    ),
                    AdminSiteSettings(
                      drawer: onExpandCollapseDrawer,
                    ),
                  ],
                ),
              );
            }),
          );
  }
}
