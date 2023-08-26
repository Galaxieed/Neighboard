import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/models/user_model.dart';
import 'package:neighboard/src/forum_page/ui/categories/categories.dart';
import 'package:neighboard/src/forum_page/ui/my_posts/my_posts.dart';
import 'package:neighboard/src/forum_page/ui/new_post/new_post.dart';
import 'package:neighboard/src/profile_screen/profile_screen_function.dart';
import 'package:neighboard/widgets/others/launch_url.dart';
import 'package:responsive_builder/responsive_builder.dart';

class ForumPageDesktop extends StatefulWidget {
  const ForumPageDesktop({super.key});

  @override
  State<ForumPageDesktop> createState() => _ForumPageDesktopState();
}

class _ForumPageDesktopState extends State<ForumPageDesktop> {
  String searchedText = "";
  int pageIndex = 0;
  changePage(int num) {
    setState(() {
      pageIndex = num;
    });
  }

  UserModel? userModel;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void getCurrentUserDetails() async {
    userModel = await ProfileFunction.getUserDetails();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    if (_auth.currentUser != null) {
      getCurrentUserDetails();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10.h),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SearchBar(
                    leading: const Icon(Icons.search),
                    hintText: 'Search Post Title...',
                    constraints: const BoxConstraints(
                      minWidth: double.infinity,
                      minHeight: 50,
                    ),
                    onChanged: (String searchText) {
                      setState(() {
                        searchedText = searchText;
                      });
                    },
                    onTap: () {
                      // showSearch(
                      //     context: context, delegate: SearchScreenUI());
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  DefaultTabController(
                    initialIndex: 1,
                    length: 4,
                    child: Builder(
                      builder: (context) => Expanded(
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 0),
                              child: ForumPageNavBar(
                                callback: (index) {
                                  final TabController controller =
                                      DefaultTabController.of(context);
                                  if (!controller.indexIsChanging) {
                                    controller.animateTo(index);
                                    changePage(index);
                                  }
                                },
                              ),
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            Expanded(
                              child: TabBarView(
                                children: [
                                  Categories(
                                    category: searchedText,
                                  ),
                                  Categories(
                                    category: searchedText,
                                  ),
                                  MyPosts(search: searchedText),
                                  const NewPost(
                                    deviceScreenType: DeviceScreenType.desktop,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 10.w,
          ),
          Expanded(
            // MGA LINKS SA KANAN
            flex: 2,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10.h),
              child: Card(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
                  child: pageIndex == 0 || pageIndex == 1 || userModel == null
                      ? otherLinks
                      : miniProfile(userModel!),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ForumPageNavBar extends StatefulWidget {
  const ForumPageNavBar({
    super.key,
    required this.callback,
  });
  final Function callback;

  @override
  State<ForumPageNavBar> createState() => _ForumPageNavBarState();
}

class _ForumPageNavBarState extends State<ForumPageNavBar> {
  String selectedSubButton = 'All Posts';

  changingButton(String newValue) {
    setState(() {
      selectedSubButton = newValue;
      if (newValue == 'Categories') {
        widget.callback(0);
      }
      if (newValue == 'All Posts') {
        widget.callback(1);
      }
      if (newValue == 'My Posts') {
        widget.callback(2);
      }
      if (newValue == 'New Post') {
        widget.callback(3);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ForumPageNavButton(
            selectedSubButton: selectedSubButton,
            label: 'Categories',
            callback: changingButton),
        SizedBox(
          width: 5.w,
        ),
        ForumPageNavButton(
            selectedSubButton: selectedSubButton,
            label: 'All Posts',
            callback: changingButton),
        SizedBox(
          width: 5.w,
        ),
        ForumPageNavButton(
            selectedSubButton: selectedSubButton,
            label: 'My Posts',
            callback: changingButton),
        const Spacer(),
        ForumPageNavButton(
            selectedSubButton: selectedSubButton,
            label: 'New Post',
            callback: changingButton),
      ],
    );
  }
}

// ignore: must_be_immutable
class ForumPageNavButton extends StatelessWidget {
  ForumPageNavButton({
    super.key,
    required this.selectedSubButton,
    required this.label,
    required this.callback,
  });

  final Function callback;
  final String label;

  String selectedSubButton;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        selectedSubButton = label;
        callback(label);
      },
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: selectedSubButton == label
              ? ccForumSelectedButtonBorderColor
              : ccForumButtonBorderColor(context),
        ),
        disabledBackgroundColor: Colors.grey,
        backgroundColor: selectedSubButton == label
            ? ccForumSelectedButtonBGColor(context)
            : ccForumButtonBGColor,
        foregroundColor: selectedSubButton == label
            ? ccForumSelectedButtonFGColor
            : ccForumButtonFGColor(context),
      ),
      child: Text(label),
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
              Text(
                'Must-read posts',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 6.sp,
                ),
                overflow: TextOverflow.ellipsis,
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
                overflow: TextOverflow.ellipsis,
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
