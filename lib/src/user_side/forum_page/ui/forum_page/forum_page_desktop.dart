import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/models/post_model.dart';
import 'package:neighboard/models/user_model.dart';
import 'package:neighboard/src/loading_screen/loading_screen.dart';
import 'package:neighboard/src/user_side/forum_page/ui/all_posts/all_posts.dart';
import 'package:neighboard/src/user_side/forum_page/ui/all_posts/all_posts_function.dart';
import 'package:neighboard/src/user_side/forum_page/ui/categories/categories.dart';
import 'package:neighboard/src/user_side/forum_page/ui/my_posts/my_posts.dart';
import 'package:neighboard/src/user_side/forum_page/ui/new_post/new_post.dart';
import 'package:neighboard/src/profile_screen/profile_screen_function.dart';
import 'package:neighboard/widgets/chat/chat.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_bar.dart';
import 'package:neighboard/widgets/notification/notification_drawer.dart';
import 'package:neighboard/widgets/post/post_modal.dart';
import 'package:responsive_builder/responsive_builder.dart';

class ForumPageDesktop extends StatefulWidget {
  const ForumPageDesktop({super.key});

  @override
  State<ForumPageDesktop> createState() => _ForumPageDesktopState();
}

class _ForumPageDesktopState extends State<ForumPageDesktop> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String searchedText = "";
  String categoryText = "";
  int pageIndex = 0;
  changePage(int num) {
    setState(() {
      pageIndex = num;
    });
  }

  UserModel? userModel;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void getCurrentUserDetails() async {
    userModel = await ProfileFunction.getUserDetails(_auth.currentUser!.uid);
  }

  void _openNotification() {
    _scaffoldKey.currentState!.openEndDrawer();
  }

  void _openChat() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return const MyChat();
      },
    );
  }

  bool isLoading = true;

  List<PostModel> postModels = [];
  void getAllPost() async {
    setState(() {
      isLoading = true;
    });
    postModels = await AllPostsFunction.getAllPost() ?? [];
    setState(() {
      isLoading = false;
    });
  }

  final scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    if (_auth.currentUser != null) {
      getCurrentUserDetails();
    }
    getAllPost();
  }

  @override
  void dispose() {
    scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: NavBar(
        openNotification: _openNotification,
        openChat: _openChat,
        currentPage: "Forum",
      ),
      endDrawer: NotificationDrawer(
        deviceScreenType: DeviceScreenType.desktop,
        stateSetter: setState,
      ),
      body: isLoading
          ? const LoadingScreen()
          : Scrollbar(
              controller: scrollCtrl,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 0, vertical: 10.h),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SearchBar(
                              leading: const Icon(Icons.search),
                              hintText: 'Search...',
                              constraints: const BoxConstraints(
                                minWidth: double.infinity,
                                minHeight: 50,
                              ),
                              onChanged: (String searchText) {
                                setState(() {
                                  searchedText = searchText.trim();
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
                                          callback: (int index,
                                              [String? text]) {
                                            final TabController controller =
                                                DefaultTabController.of(
                                                    context);
                                            if (!controller.indexIsChanging) {
                                              if (text != null) {
                                                categoryText = text;
                                              }
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
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15.w, vertical: 0),
                                          child: TabBarView(
                                            children: [
                                              Categories(
                                                searchedText: searchedText,
                                                category: categoryText,
                                                isAdmin: false,
                                                deviceScreenType:
                                                    DeviceScreenType.desktop,
                                              ),
                                              AllPosts(
                                                scrollController: scrollCtrl,
                                                searchedText: searchedText,
                                                category: "",
                                                isAdmin: false,
                                                deviceScreenType:
                                                    DeviceScreenType.desktop,
                                              ),
                                              MyPosts(search: searchedText),
                                              const NewPost(
                                                deviceScreenType:
                                                    DeviceScreenType.desktop,
                                              ),
                                            ],
                                          ),
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 0, vertical: 10.h),
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 20.h),
                            child: pageIndex == 0 ||
                                    pageIndex == 1 ||
                                    userModel == null
                                ? otherLinks(context, postModels, getAllPost)
                                : miniProfile(context, userModel!),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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

      if (newValue == 'All Posts') {
        widget.callback(1);
      } else if (newValue == 'My Posts') {
        widget.callback(2);
      } else if (newValue == 'New Post') {
        widget.callback(3);
      } else {
        widget.callback(0, newValue);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        PopupMenuButton(
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                  onTap: () {
                    changingButton('General Discussion');
                  },
                  child: const Text("General Discussion")),
              PopupMenuItem(
                  onTap: () {
                    changingButton('Garbage Collection');
                  },
                  child: const Text("Garbage Collection")),
              PopupMenuItem(
                  onTap: () {
                    changingButton('Parking Space');
                  },
                  child: const Text("Parking Space")),
              PopupMenuItem(
                  onTap: () {
                    changingButton('Water Billing');
                  },
                  child: const Text("Water Billing")),
              PopupMenuItem(
                  onTap: () {
                    changingButton('Electric Billing');
                  },
                  child: const Text("Electric Billing")),
              PopupMenuItem(
                  onTap: () {
                    changingButton('Power Interruption');
                  },
                  child: const Text("Power Interruption")),
              PopupMenuItem(
                  onTap: () {
                    changingButton('Clubhouse Fees and Rental');
                  },
                  child: const Text("Clubhouse Fees and Rental")),
            ];
          },
          child: IgnorePointer(
            child: ForumPageNavButton(
              selectedSubButton: selectedSubButton,
              label: selectedSubButton != 'All Posts' &&
                      selectedSubButton != 'My Posts' &&
                      selectedSubButton != 'New Post'
                  ? selectedSubButton
                  : "Categories",
              callback: changingButton,
            ),
          ),
        ),
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
            : ccForumButtonBGColor(context),
        foregroundColor: selectedSubButton == label
            ? ccForumSelectedButtonFGColor(context)
            : ccForumButtonFGColor(context),
      ),
      child: Row(
        children: [
          if (label == "New Post") const Icon(Icons.add),
          Text(label),
        ],
      ),
    );
  }
}

Widget miniProfile(BuildContext context, UserModel userModel) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisSize: MainAxisSize.max,
    children: [
      Text(
        "User Engagement",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 6.sp,
        ),
      ),
      CircleAvatar(
        radius: 40.sp,
        backgroundImage: NetworkImage(userModel.profilePicture.toString()),
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
            color: Theme.of(context).colorScheme.inversePrimary,
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
              color: Theme.of(context).colorScheme.inversePrimary,
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

Widget otherLinks(context, List<PostModel> postModels, stateSetter) => Center(
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
                    Icons.remove_red_eye_outlined,
                    weight: 3,
                  ),
                  SizedBox(
                    width: 2.w,
                  ),
                  Expanded(
                    child: Text(
                      'Most Viewed Posts',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
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
              //dito
              ListView.builder(
                itemCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  postModels.sort((a, b) => b.noOfViews.compareTo(a.noOfViews));
                  return TheLinks(
                      postModel: postModels[index], stateSetter: stateSetter);
                },
              ),
              SizedBox(
                height: 10.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.arrow_upward_outlined,
                    weight: 3,
                  ),
                  SizedBox(
                    width: 2.w,
                  ),
                  Expanded(
                    child: Text(
                      'Most Upvoted Posts',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
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
              ListView.builder(
                itemCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  postModels
                      .sort((a, b) => b.noOfUpVotes.compareTo(a.noOfUpVotes));
                  return TheLinks(
                      postModel: postModels[index], stateSetter: stateSetter);
                },
              ),
              //dito
            ],
          ),
        ),
      ),
    );

class TheLinks extends StatefulWidget {
  const TheLinks(
      {super.key, required this.postModel, required this.stateSetter});

  final PostModel postModel;
  final Function stateSetter;

  @override
  State<TheLinks> createState() => _TheLinksState();
}

class _TheLinksState extends State<TheLinks> {
  bool _isHovering = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) => Dialog(
                  child: PostModal(
                postModel: widget.postModel,
                deviceScreenType: DeviceScreenType.desktop,
                stateSetter: widget.stateSetter,
              )),
            );
          },
          child: Text(
            widget.postModel.title,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: _isHovering
                    ? Theme.of(context).colorScheme.inversePrimary
                    : Theme.of(context).colorScheme.onBackground),
          ),
        ),
      ),
    );
  }
}
