import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:neighboard/models/user_model.dart';
import 'package:neighboard/src/forum_page/ui/categories/categories.dart';
import 'package:neighboard/src/forum_page/ui/my_posts/my_posts.dart';
import 'package:neighboard/src/forum_page/ui/new_post/new_post.dart';
import 'package:neighboard/src/profile_screen/profile_screen_function.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_bar.dart';
import 'package:neighboard/widgets/others/launch_url.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({Key? key}) : super(key: key);

  static const forumPages = <Widget>[
    Categories(),
    Categories(),
    MyPosts(),
    NewPost(),
  ];

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  UserModel? userModel;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  void initState() {
    super.initState();
    if (_auth.currentUser != null) {
      getCurrentUserDetails();
    }
  }

  void getCurrentUserDetails() async {
    userModel = await ProfileFunction.getUserDetails();
    setState(() {});
  }

  int pageIndex = 0;
  changePage(int num) {
    setState(() {
      pageIndex = num;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NavBar(),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 0, vertical: 40),
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
                        minHeight: 60,
                      ),
                      onChanged: (String searchText) {},
                      onTap: () {},
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    DefaultTabController(
                      initialIndex: 1,
                      length: ForumPage.forumPages.length,
                      child: Builder(
                        builder: (BuildContext context) => Expanded(
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 0),
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
                              const SizedBox(
                                height: 20,
                              ),
                              const Expanded(
                                child:
                                    TabBarView(children: ForumPage.forumPages),
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
            const SizedBox(
              width: 60,
            ),
            Expanded(
              // MGA LINKS SA KANAN
              flex: 2,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 0, vertical: 40),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 40),
                    child: pageIndex == 0 || pageIndex == 1 || userModel == null
                        ? otherLinks
                        : miniProfile(userModel!),
                  ),
                ),
              ),
            ),
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
        radius: 80,
        backgroundImage: NetworkImage(userModel.profilePicture.toString()),
      ),
      const SizedBox(
        height: 20,
      ),
      Text(
        "@${userModel.username}",
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          letterSpacing: 1,
        ),
      ),
      const SizedBox(
        height: 10,
      ),
      const Divider(),
      const SizedBox(
        height: 10,
      ),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lightbulb_sharp,
            color: Colors.amber[500],
            size: 18,
            weight: 2,
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            '${userModel.rank} [${userModel.posts}]',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.amber[500],
            ),
          ),
        ],
      ),
      const SizedBox(
        height: 10,
      ),
      const Divider(),
      const SizedBox(
        height: 10,
      ),
      userModel.socialMediaLinks.isNotEmpty
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.link),
                ),
                const SizedBox(
                  width: 10,
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.linked_camera),
                ),
                const SizedBox(
                  width: 10,
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

Widget otherLinks = Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  mainAxisSize: MainAxisSize.max,
  children: [
    const Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(
          Icons.star_border,
          weight: 3,
        ),
        SizedBox(
          width: 10,
        ),
        Text(
          'Must-read posts',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    ),
    const Divider(
      color: Colors.black,
    ),
    const SizedBox(
      height: 10,
    ),
    RichText(
      text: TextSpan(
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 18,
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
    const SizedBox(
      height: 10,
    ),
    const Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(
          Icons.link,
          weight: 3,
        ),
        SizedBox(
          width: 10,
        ),
        Text(
          'Featured links',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    ),
    const Divider(
      color: Colors.black,
    ),
    const SizedBox(
      height: 10,
    ),
    RichText(
      text: TextSpan(
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 18,
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
);

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
  Color subButtonColor = Colors.transparent;

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
            color: subButtonColor,
            label: 'Categories',
            callback: changingButton),
        const SizedBox(
          width: 20,
        ),
        ForumPageNavButton(
            selectedSubButton: selectedSubButton,
            color: subButtonColor,
            label: 'All Posts',
            callback: changingButton),
        const SizedBox(
          width: 20,
        ),
        ForumPageNavButton(
            selectedSubButton: selectedSubButton,
            color: subButtonColor,
            label: 'My Posts',
            callback: changingButton),
        const Spacer(),
        ForumPageNavButton(
            selectedSubButton: selectedSubButton,
            color: subButtonColor,
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
    required this.color,
    required this.label,
    required this.callback,
  });

  final Function callback;
  final String label;
  Color color;
  String selectedSubButton;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        selectedSubButton = label;
        callback(label);
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: selectedSubButton == label
            ? color = Theme.of(context).primaryColor
            : color = Colors.transparent,
        foregroundColor: selectedSubButton == label
            ? color = Theme.of(context).colorScheme.onPrimary
            : color = Theme.of(context).primaryColor,
      ),
      child: Text(label),
    );
  }
}
