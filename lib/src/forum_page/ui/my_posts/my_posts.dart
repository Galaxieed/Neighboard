import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:neighboard/data/posts_data.dart';
import 'package:neighboard/models/comment_model.dart';
import 'package:neighboard/models/post_model.dart';
import 'package:neighboard/models/user_model.dart';
import 'package:neighboard/src/forum_page/ui/comments/comment_function.dart';
import 'package:neighboard/src/forum_page/ui/comments/comment_ui.dart';
import 'package:neighboard/src/forum_page/ui/my_posts/my_post_function.dart';
import 'package:neighboard/src/login_register_page/login_page/login_page_ui.dart';
import 'package:neighboard/widgets/others/author_name_text.dart';
import 'package:neighboard/widgets/others/post_content_text.dart';
import 'package:neighboard/widgets/others/post_tag_chip.dart';
import 'package:neighboard/widgets/others/post_time_text.dart';
import 'package:neighboard/widgets/others/post_title_text.dart';
import 'package:neighboard/widgets/others/small_profile_pic.dart';

class MyPosts extends StatefulWidget {
  const MyPosts({Key? key}) : super(key: key);

  @override
  State<MyPosts> createState() => _MyPostsState();
}

class _MyPostsState extends State<MyPosts> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<PostModel> postModels = [];
  bool isLoading = false;
  bool isLoggedIn = false;

  void getMyPosts() async {
    setState(() {
      isLoading = true;
    });
    try {
      postModels =
          await MyPostFunction.getMyPost(authorId: _auth.currentUser!.uid) ??
              [];
    } catch (e) {
      return;
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    if (_auth.currentUser == null) {
      isLoggedIn = false;
    } else {
      isLoggedIn = true;
      getMyPosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : !isLoggedIn
            ? Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()));
                      },
                      child: const Text(
                        "Login ",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                    const Text("First"),
                  ],
                ),
              )
            : postModels.isEmpty
                ? const Center(
                    child: Text("No posts"),
                  )
                : ListView.builder(
                    itemCount: postModels.length,
                    itemBuilder: (context, index) {
                      PostModel post = postModels[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 10),
                        child: Column(
                          children: [
                            ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: MyPostWithComments(post: post)),
                          ],
                        ),
                      );
                    });
  }
}

class MyPostWithComments extends StatefulWidget {
  const MyPostWithComments({
    super.key,
    required this.post,
  });

  final PostModel post;

  @override
  State<MyPostWithComments> createState() => _MyPostWithCommentsState();
}

class _MyPostWithCommentsState extends State<MyPostWithComments> {
  int index = -1;
  final TextEditingController _comment = TextEditingController();
  bool isLoading = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? currentUser;

  Future<void> getCurrentUser() async {
    try {
      final result = await _firestore
          .collection("users")
          .doc(_auth.currentUser!.uid)
          .get();
      currentUser = UserModel.fromJson(result.data()!);
    } catch (e) {
      return;
    }
  }

  List<CommentModel> commentModel = [];

  void getAllComments() async {
    commentModel =
        await CommentFunction.getAllComments(postId: widget.post.postId) ?? [];
    setState(() {
      isLoading = false;
    });
  }

  void onPostComment() async {
    if (_comment.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      await getCurrentUser();

      CommentModel comment = CommentModel(
        commentId: DateTime.now().toIso8601String(),
        senderId: currentUser!.userId,
        senderProfilePicture: currentUser!.profilePicture,
        senderName: currentUser!.username,
        timeStamp: formattedDate,
        commentMessage: _comment.text,
        noOfLikes: 0,
        noOfDislikes: 0,
        noOfReplies: 0,
      );

      await CommentFunction.postComment(
          postId: widget.post.postId, commentModel: comment);
      commentModel.add(comment);
      _comment.clear();
      setState(() {
        isLoading = false;
      });
    } else {
      return;
    }
  }

  clearComment() {
    setState(() {
      _comment.clear();
    });
  }

  bool isUpvoted = false;

  void checkIfUpVoted() async {
    isUpvoted =
        await MyPostFunction.isAlreadyUpvoted(postId: widget.post.postId);
    if (mounted) {
      setState(() {});
    }
  }

  upVoteFunc({required String postId}) async {
    if (isUpvoted) {
      setState(() {
        widget.post.noOfUpVotes -= 1;
        isUpvoted = false;
      });
      await MyPostFunction.onUpvoteAndUnUpvote(
          postId: postId, isUpvoted: false);
    } else {
      setState(() {
        widget.post.noOfUpVotes += 1;
        isUpvoted = true;
      });
      await MyPostFunction.onUpvoteAndUnUpvote(postId: postId, isUpvoted: true);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllComments();
    checkIfUpVoted();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : ExpansionPanelList(
            expandedHeaderPadding: const EdgeInsets.all(0),
            expansionCallback: (i, isOpen) {
              setState(() {
                if (index == i) {
                  index = -1;
                } else {
                  index = i;
                }
              });
            },
            animationDuration: const Duration(milliseconds: 500),
            elevation: 0,
            children: [
              ExpansionPanel(
                backgroundColor: Theme.of(context).primaryColorLight,
                headerBuilder: (BuildContext context, bool isExpanded) {
                  return SingleMyPost(
                    post: widget.post,
                    upVote: upVoteFunc,
                    isUpvoted: isUpvoted,
                  );
                },
                canTapOnHeader: true,
                body: Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Comments',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    CommentBox(
                        comment: _comment,
                        addComment: onPostComment,
                        clearComment: clearComment),
                    const SizedBox(
                      height: 10,
                    ),
                    for (CommentModel comment in commentModel)
                      CommentUI(post: widget.post, comment: comment),
                  ],
                ),
                isExpanded: index == 0,
              )
            ],
          );
  }
}

class CommentBox extends StatelessWidget {
  const CommentBox({
    super.key,
    required TextEditingController comment,
    required this.addComment,
    required this.clearComment,
  }) : _comment = comment;

  final Function addComment, clearComment;
  final TextEditingController _comment;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 40),
        child: Column(
          children: [
            TextField(
              controller: _comment,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Type here your wise suggestion..',
                alignLabelWithHint: true,
              ),
              maxLines: 2,
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    clearComment();
                  },
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancel'),
                ),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    addComment();
                  },
                  icon: const Icon(Icons.mode_comment_outlined),
                  label: const Text('Comment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SingleMyPost extends StatelessWidget {
  const SingleMyPost({
    super.key,
    required this.post,
    required this.upVote,
    required this.isUpvoted,
  });

  final Function upVote;
  final PostModel post;
  final bool isUpvoted;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
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
                      PostTimeText(time: post.timeStamp),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_vert),
                )
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
              maxLine: 3,
              textOverflow: TextOverflow.ellipsis,
            ),
            const SizedBox(
              height: 10,
            ),
            ActionBarMyPost(
              post: post,
              upVote: upVote,
              isUpvoted: isUpvoted,
            ),
          ],
        ),
      ),
    );
  }
}

class ActionBarMyPost extends StatelessWidget {
  const ActionBarMyPost({
    super.key,
    required this.post,
    required this.upVote,
    required this.isUpvoted,
  });

  final bool isUpvoted;
  final Function upVote;
  final PostModel post;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Wrap(
          spacing: 16,
          children: [
            for (String tag in post.tags) PostTagChip(tag: tag),
          ],
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: () {
            upVote(postId: post.postId);
          },
          icon: const Icon(Icons.arrow_upward_rounded),
          label: Text(isUpvoted ? 'Voted' : 'Vote'),
          style: ElevatedButton.styleFrom(
            backgroundColor: isUpvoted
                ? Theme.of(context).disabledColor
                : Theme.of(context).primaryColor,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
        )
      ],
    );
  }
}
