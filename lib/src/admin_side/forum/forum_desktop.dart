import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/src/user_side/forum_page/ui/all_posts/all_posts.dart';
import 'package:neighboard/src/user_side/forum_page/ui/categories/categories.dart';
import 'package:neighboard/src/user_side/forum_page/ui/my_posts/my_posts.dart';
import 'package:neighboard/src/user_side/forum_page/ui/new_post/new_post.dart';
import 'package:responsive_builder/responsive_builder.dart';

class AdminForumDesktop extends StatefulWidget {
  const AdminForumDesktop({super.key});

  @override
  State<AdminForumDesktop> createState() => _AdminForumDesktopState();
}

class _AdminForumDesktopState extends State<AdminForumDesktop> {
  String searchedText = "";
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 15.w),
      child: Column(
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 0),
                      child: ForumPageNavBar(
                        callback: (index) {
                          final TabController controller =
                              DefaultTabController.of(context);
                          if (!controller.indexIsChanging) {
                            controller.animateTo(index);
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    Expanded(
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 15.w, vertical: 0),
                        child: TabBarView(
                          children: [
                            Categories(
                              searchedText: searchedText,
                              category: "",
                              isAdmin: true,
                              deviceScreenType: DeviceScreenType.desktop,
                            ),
                            AllPosts(
                              searchedText: searchedText,
                              category: "",
                              isAdmin: true,
                              deviceScreenType: DeviceScreenType.desktop,
                            ),
                            MyPosts(search: searchedText),
                            const NewPost(
                              deviceScreenType: DeviceScreenType.desktop,
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
      if (newValue == 'Pending Posts') {
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
            label: 'Pending Posts',
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
