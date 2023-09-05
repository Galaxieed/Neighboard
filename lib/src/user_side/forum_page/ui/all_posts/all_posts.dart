import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neighboard/models/post_model.dart';
import 'package:neighboard/src/loading_screen/loading_screen.dart';
import 'package:neighboard/src/user_side/forum_page/ui/all_posts/all_posts_function.dart';
import 'package:neighboard/src/user_side/forum_page/ui/categories/categories_function.dart';
import 'package:neighboard/widgets/others/author_name_text.dart';
import 'package:neighboard/widgets/others/post_content_text.dart';
import 'package:neighboard/widgets/others/post_time_text.dart';
import 'package:neighboard/widgets/others/post_title_text.dart';
import 'package:neighboard/widgets/others/small_profile_pic.dart';

class AllPosts extends StatefulWidget {
  const AllPosts({
    super.key,
    required this.isAdmin,
    required this.category,
  });

  final bool isAdmin;
  final String category;

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
    // TODO: implement didUpdateWidget
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
                        SinglePost(post: post, isAdmin: widget.isAdmin),
                      ],
                    ),
                  );
                },
              );
  }
}

class SinglePost extends StatelessWidget {
  const SinglePost({
    super.key,
    required this.post,
    required this.isAdmin,
  });

  final PostModel post;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SmallProfilePic(profilePic: post.profilePicture),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      AuthorNameText(authorName: post.authorName),
                      PostTimeText(time: post.timeStamp)
                    ],
                  )),
                  IconButton(
                      onPressed: () {}, icon: const Icon(Icons.more_vert)),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              PostTitleText(title: post.title),
              const SizedBox(
                height: 5,
              ),
              PostContentText(
                content: post.content,
                maxLine: 1,
                textOverflow: TextOverflow.ellipsis,
              ),
              const SizedBox(
                height: 10,
              ),
              ActionBarPosts(post: post, isAdmin: isAdmin)
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
  });

  final PostModel post;
  final bool isAdmin;

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
          onPressed: () {},
          icon: const Icon(Icons.remove_red_eye_outlined),
        ),
        Text('${widget.post.noOfViews}'),
        const SizedBox(
          width: 20,
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.mode_comment_outlined),
        ),
        Text('${widget.post.noOfComments}'),
        const SizedBox(
          width: 20,
        ),
        IconButton(
          onPressed: () {},
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
