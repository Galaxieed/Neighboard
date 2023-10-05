import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neighboard/models/post_model.dart';
import 'package:neighboard/src/loading_screen/loading_screen.dart';
import 'package:neighboard/src/user_side/forum_page/ui/all_posts/all_posts_function.dart';
import 'package:neighboard/src/user_side/forum_page/ui/categories/categories_function.dart';
import 'package:neighboard/widgets/post/post_interactors.dart';
import 'package:neighboard/widgets/post/post_interactors_function.dart';
import 'package:neighboard/widgets/post/post_modal.dart';
import 'package:neighboard/widgets/others/author_name_text.dart';
import 'package:neighboard/widgets/others/post_content_text.dart';
import 'package:neighboard/widgets/others/post_time_text.dart';
import 'package:neighboard/widgets/others/post_title_text.dart';
import 'package:neighboard/widgets/others/small_profile_pic.dart';
import 'package:responsive_builder/responsive_builder.dart';

class AllPosts extends StatefulWidget {
  const AllPosts({
    super.key,
    required this.isAdmin,
    required this.category,
    required this.deviceScreenType,
  });

  final bool isAdmin;
  final String category;
  final DeviceScreenType deviceScreenType;

  @override
  State<AllPosts> createState() => _AllPostsState();
}

class _AllPostsState extends State<AllPosts> {
  List<PostModel> postModels = [];
  bool isLoading = true;

  void getAllPost() async {
    postModels = await AllPostsFunction.getAllPost() ?? [];
    postModels.sort((a, b) => b.postId.compareTo(a.postId));
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void getTitlePost() async {
    postModels = await CategoriesFunction.getPostsByTitle(
            title: widget.category.trim()) ??
        [];

    postModels.sort((a, b) => widget.category.trim().compareTo(a.title));
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    getAllPost();
  }

  @override
  void didUpdateWidget(covariant AllPosts oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.category.isNotEmpty || widget.category != "") {
      getTitlePost();
    } else {
      getAllPost();
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const LoadingScreen()
        : postModels.isEmpty
            ? const Center(
                child: Text("No Posts"),
              )
            : ListView.builder(
                itemCount: postModels.length,
                itemBuilder: (context, index) {
                  PostModel post = postModels[index];
                  return Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 0.w, vertical: 5.h),
                    child: Column(
                      children: [
                        SinglePost(
                          post: post,
                          isAdmin: widget.isAdmin,
                          deviceScreenType: widget.deviceScreenType,
                        ),
                      ],
                    ),
                  );
                },
              );
  }
}

class SinglePost extends StatefulWidget {
  const SinglePost({
    super.key,
    required this.post,
    required this.isAdmin,
    required this.deviceScreenType,
  });
  final DeviceScreenType deviceScreenType;
  final PostModel post;
  final bool isAdmin;

  @override
  State<SinglePost> createState() => _SinglePostState();
}

class _SinglePostState extends State<SinglePost> {
  bool isAlreadyViewed = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void checkIfAlreadyViewed() async {
    isAlreadyViewed = await PostInteractorsFunctions.isAlreadyViewed(
        postId: widget.post.postId);
    setState(() {});
  }

  void onOpenPost() async {
    if (!isAlreadyViewed && _auth.currentUser != null) {
      setState(() {
        isAlreadyViewed = true;
        widget.post.noOfViews += 1;
      });
      await PostInteractorsFunctions.onViewPost(widget.post.postId, true);
    }
  }

  @override
  void initState() {
    super.initState();
    checkIfAlreadyViewed();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () {
          onOpenPost();
          widget.deviceScreenType != DeviceScreenType.mobile
              ? showDialog(
                  context: context,
                  builder: (BuildContext context) => Dialog(
                      child: PostModal(
                    postModel: widget.post,
                    deviceScreenType: widget.deviceScreenType,
                  )),
                )
              : showModalBottomSheet(
                  useSafeArea: true,
                  useRootNavigator: true,
                  isScrollControlled: true,
                  context: context,
                  builder: (context) => PostModal(
                    postModel: widget.post,
                    deviceScreenType: widget.deviceScreenType,
                  ),
                );
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SmallProfilePic(profilePic: widget.post.profilePicture),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        AuthorNameText(authorName: widget.post.authorName),
                        PostTimeText(time: widget.post.timeStamp)
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              PostTitleText(title: widget.post.title),
              const SizedBox(
                height: 5,
              ),
              PostContentText(
                content: widget.post.content,
                maxLine: 1,
                textOverflow: TextOverflow.ellipsis,
              ),
              const SizedBox(
                height: 10,
              ),
              ActionBarPosts(
                post: widget.post,
                isAdmin: widget.isAdmin,
                onOpenPost: onOpenPost,
                deviceScreenType: widget.deviceScreenType,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ActionBarPosts extends StatefulWidget {
  const ActionBarPosts({
    super.key,
    required this.post,
    required this.isAdmin,
    required this.deviceScreenType,
    required this.onOpenPost,
  });

  final PostModel post;
  final bool isAdmin;
  final Function onOpenPost;
  final DeviceScreenType deviceScreenType;

  @override
  State<ActionBarPosts> createState() => _ActionBarPostsState();
}

class _ActionBarPostsState extends State<ActionBarPosts> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) => PostInteractors(
                postModel: widget.post,
                collection: "views",
              ),
            );
          },
          icon: const Icon(Icons.remove_red_eye_outlined),
        ),
        Text('${widget.post.noOfViews}'),
        const SizedBox(
          width: 20,
        ),
        AbsorbPointer(
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.mode_comment_outlined),
          ),
        ),
        Text('${widget.post.noOfComments}'),
        const SizedBox(
          width: 20,
        ),
        IconButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) => PostInteractors(
                postModel: widget.post,
                collection: "upvotes",
              ),
            );
          },
          icon: const Icon(Icons.arrow_upward),
        ),
        Text('${widget.post.noOfUpVotes}'),
        const SizedBox(
          width: 20,
        ),
      ],
    );
  }
}
