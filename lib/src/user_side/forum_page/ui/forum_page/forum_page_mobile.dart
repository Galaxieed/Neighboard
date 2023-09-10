import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/models/user_model.dart';
import 'package:neighboard/routes/routes.dart';
import 'package:neighboard/src/user_side/forum_page/ui/all_posts/all_posts.dart';
import 'package:neighboard/src/user_side/forum_page/ui/categories/categories.dart';
import 'package:neighboard/src/user_side/forum_page/ui/my_posts/my_posts.dart';
import 'package:neighboard/src/user_side/forum_page/ui/new_post/new_post.dart';
import 'package:neighboard/src/user_side/forum_page/ui/search_page/search_ui.dart';
import 'package:neighboard/src/profile_screen/profile_screen_function.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_bar.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_drawer.dart';
import 'package:neighboard/widgets/others/launch_url.dart';
import 'package:responsive_builder/responsive_builder.dart';

class ForumPageMobile extends StatefulWidget {
  const ForumPageMobile({super.key, required this.screenType});

  final DeviceScreenType screenType;

  @override
  State<ForumPageMobile> createState() => _ForumPageMobileState();
}

class _ForumPageMobileState extends State<ForumPageMobile>
    with SingleTickerProviderStateMixin {
  String searchedText = "";
  late TabController _tabController;
  UserModel? userModel;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void getCurrentUserDetails() async {
    userModel = await ProfileFunction.getUserDetails(_auth.currentUser!.uid);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
      appBar: AppBar(
        title: const Text("NEIGHBOARD"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              await showSearch(
                context: context,
                delegate: SearchScreenUI(),
              );
            },
            icon: const Icon(Icons.search),
            tooltip: "Search Post Title",
          ),
          NavBarCircularImageDropDownButton(
            callback: Routes().navigate,
            isAdmin: false,
          ),
          SizedBox(
            width: 2.5.w,
          )
        ],
      ),
      bottomNavigationBar: Material(
        child: TabBar(
          tabs: const [
            Tab(
              icon: Icon(Icons.category),
              text: "Category",
            ),
            Tab(
              icon: Icon(Icons.forum_rounded),
              text: "Posts",
            ),
            Tab(
              icon: Icon(Icons.my_library_books_rounded),
              text: "My Posts",
            ),
            Tab(
              icon: Icon(Icons.add),
              text: "New Post",
            ),
          ],
          controller: _tabController,
        ),
      ),
      drawer: widget.screenType == DeviceScreenType.mobile
          ? const NavDrawer()
          : null,
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
                  Categories(
                    category: searchedText,
                    isAdmin: false,
                  ),
                  AllPosts(
                    category: searchedText,
                    isAdmin: false,
                  ),
                  MyPosts(search: searchedText),
                  NewPost(
                    deviceScreenType: widget.screenType,
                  ),
                ],
              ),
            ),
            // SizedBox(
            //   width: 10.w,
            // ),
            // Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10.h),
            //   child: Card(
            //     child: Padding(
            //       padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
            //       child: pageIndex == 0 || pageIndex == 1 || userModel == null
            //           ? otherLinks
            //           : miniProfile(userModel!),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

Widget miniProfile(UserModel userModel) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisSize: MainAxisSize.max,
    children: [
      CircleAvatar(
        radius: 40.sp,
        backgroundImage: NetworkImage(userModel.profilePicture.toString()),
      ),
      SizedBox(
        height: 10.h,
      ),
      Text(
        "@${userModel.username}",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 6.sp,
          letterSpacing: 1,
        ),
      ),
      SizedBox(
        height: 5.h,
      ),
      const Divider(),
      SizedBox(
        height: 5.h,
      ),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lightbulb_sharp,
            color: ccLightBulbColor,
            size: 6.sp,
            weight: 2,
          ),
          SizedBox(
            width: 2.w,
          ),
          Text(
            '${userModel.rank} [${userModel.posts}]',
            style: TextStyle(
              fontSize: 6.sp,
              fontWeight: FontWeight.bold,
              color: ccRankColor,
            ),
          ),
        ],
      ),
      SizedBox(
        height: 5.h,
      ),
      const Divider(),
      SizedBox(
        height: 5.h,
      ),
      userModel.socialMediaLinks.isNotEmpty
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.link),
                ),
                SizedBox(
                  width: 2.w,
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.linked_camera),
                ),
                SizedBox(
                  width: 2.w,
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.facebook),
                ),
              ],
            )
          : Container(),
    ],
  );
}

Widget otherLinks = Center(
  child: Align(
    alignment: Alignment.topCenter,
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(
                Icons.star_border,
                weight: 3,
              ),
              SizedBox(
                width: 2.w,
              ),
              const Text(
                'Must-read posts',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  //fontSize: 6.sp,
                ),
              ),
            ],
          ),
          const Divider(
            color: ccForumDividerColor,
          ),
          SizedBox(
            height: 5.h,
          ),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                color: ccForumLinksColor,
                //fontSize: 5.sp,
              ),
              children: [
                TextSpan(
                  text:
                      'Please read rules before you start working on the platform.\n\n',
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launcherUrl('https://www.youtube.com');
                    },
                ),
                TextSpan(
                  text: 'Vision and Strategy of Alemhelp\n',
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launcherUrl('https://www.youtube.com');
                    },
                ),
              ],
            ),
          ),
          SizedBox(
            height: 5.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(
                Icons.link,
                weight: 3,
              ),
              SizedBox(
                width: 2.w,
              ),
              Text(
                'Featured links',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 6.sp,
                ),
              ),
            ],
          ),
          const Divider(
            color: ccForumDividerColor,
          ),
          SizedBox(
            height: 5.h,
          ),
          RichText(
            text: TextSpan(
              style: TextStyle(
                color: ccForumLinksColor,
                fontSize: 5.sp,
              ),
              children: [
                TextSpan(
                  text: 'Alemhelp source code on GitHub.\n\n',
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launcherUrl(
                          'https://github.com/Galaxieed/Neighboard/tree/master');
                    },
                ),
                TextSpan(
                  text: 'Golang best practices\n\n',
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launcherUrl('https://www.youtube.com');
                    },
                ),
                TextSpan(
                  text: 'Alem School dashboard',
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launcherUrl('https://www.youtube.com');
                    },
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
);
