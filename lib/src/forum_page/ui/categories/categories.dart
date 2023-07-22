import 'package:flutter/material.dart';
import 'package:neighboard/data/posts_data.dart';
import 'package:neighboard/models/post_model.dart';
import 'package:neighboard/widgets/others/author_name_text.dart';
import 'package:neighboard/widgets/others/post_content_text.dart';
import 'package:neighboard/widgets/others/post_time_text.dart';
import 'package:neighboard/widgets/others/post_title_text.dart';
import 'package:neighboard/widgets/others/small_profile_pic.dart';

class Categories extends StatefulWidget {
  const Categories({Key? key}) : super(key: key);

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          PostModel post = posts[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
            child: SinglePost(post: post),
          );
        });
  }
}

class SinglePost extends StatelessWidget {
  const SinglePost({
    super.key,
    required this.post,
  });

  final PostModel post;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
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
              ActionBarPosts(post: post)
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
  });

  final PostModel post;

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
        Text('${widget.post.comments.length}'),
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
