import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/data/posts_data.dart';
import 'package:neighboard/models/comment_model.dart';
import 'package:neighboard/models/post_model.dart';
import 'package:neighboard/models/user_model.dart';
import 'package:neighboard/src/loading_screen/loading_posts.dart';
import 'package:neighboard/src/user_side/forum_page/ui/comments/comment_function.dart';
import 'package:neighboard/src/user_side/forum_page/ui/comments/comment_ui.dart';
import 'package:neighboard/src/user_side/forum_page/ui/my_posts/my_post_function.dart';
import 'package:neighboard/src/user_side/login_register_page/login_page/login_page_ui.dart';
import 'package:neighboard/widgets/others/author_name_text.dart';
import 'package:neighboard/widgets/others/post_content_text.dart';
import 'package:neighboard/widgets/others/post_tag_chip.dart';
import 'package:neighboard/widgets/others/post_time_text.dart';
import 'package:neighboard/widgets/others/post_title_text.dart';
import 'package:neighboard/widgets/others/small_profile_pic.dart';
import 'package:neighboard/widgets/page_messages/page_messages.dart';

class MyPosts extends StatefulWidget {
  const MyPosts({Key? key, required this.search}) : super(key: key);

  final String search;

  @override
  State<MyPosts> createState() => _MyPostsState();
}

class _MyPostsState extends State<MyPosts> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<PostModel> postModels = [];
  bool isLoading = true;
  bool isLoggedIn = false;

  void getMyPosts() async {
    try {
      postModels =
          await MyPostFunction.getMyPost(authorId: _auth.currentUser!.uid) ??
              [];
    } catch (e) {
      return;
    }
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  void getMyPostsByTitle() async {
    try {
      postModels = await MyPostFunction.getMyPostByTitle(
              authorId: _auth.currentUser!.uid, title: widget.search) ??
          [];
      setState(() {});
    } catch (e) {
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    if (_auth.currentUser == null) {
      isLoggedIn = false;
      isLoading = false;
    } else {
      isLoggedIn = true;
      getMyPosts();
    }
  }

  @override
  void didUpdateWidget(covariant MyPosts oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.search.isNotEmpty || widget.search != "") {
      getMyPostsByTitle();
    } else if (isLoggedIn) {
      getMyPosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const LoadingPosts(
            postType: "My Posts",
          )
        : !isLoggedIn
            ? Center(
                child: Column(
                  children: [
                    Image.asset(
                      loginFirstImg,
                      height: 300,
                      width: 300,
                    ),
                    Row(
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
                  ],
                ),
              )
            : postModels.isEmpty
                ? noPostMessage()
                : ListView.builder(
                    itemCount: postModels.length,
                    itemBuilder: (context, index) {
                      PostModel post = postModels[index];
                      return Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 0.w, vertical: 5.h),
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

  List<CommentModel> commentModels = [];

  void getAllComments() async {
    commentModels =
        await CommentFunction.getAllComments(postId: widget.post.postId) ?? [];
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void onPostComment() async {
    if (_comment.text.isNotEmpty) {
      // setState(() {
      //   isLoading = true;
      // });
      await getCurrentUser();

      CommentModel comment = CommentModel(
        commentId: DateTime.now().toIso8601String(),
        senderId: currentUser!.userId,
        senderProfilePicture: currentUser!.profilePicture,
        senderName: currentUser!.username,
        timeStamp: formattedDate(),
        commentMessage: _comment.text,
        noOfLikes: 0,
        noOfDislikes: 0,
        noOfReplies: 0,
      );

      await CommentFunction.postComment(
          postId: widget.post.postId, commentModel: comment);
      //commentModel.add(comment);
      _comment.clear();
      // if (mounted) {
      //   setState(() {
      //     isLoading = false;
      //   });
      // }
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
      setState(() {
        isLoading = false;
      });
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
    super.initState();
    // getAllComments();
    checkIfUpVoted();
  }

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : ExpansionPanelList(
            expandedHeaderPadding: const EdgeInsets.all(0),
            animationDuration: const Duration(milliseconds: 500),
            elevation: 0,
            expansionCallback: (i, isOpen) {
              setState(() {
                if (index == i) {
                  index = -1;
                } else {
                  index = i;
                }
              });
            },
            children: [
              ExpansionPanel(
                //backgroundColor: ccExpansionPostColor(context),
                canTapOnHeader: true,
                isExpanded: index == 0,
                headerBuilder: (BuildContext context, bool isExpanded) {
                  return SingleMyPost(
                    post: widget.post,
                    upVote: upVoteFunc,
                    isUpvoted: isUpvoted,
                    isCollapsed: index == 0,
                  );
                },
                body: Column(
                  children: [
                    SizedBox(
                      height: 5.h,
                    ),
                    Text(
                      'Comments',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    CommentBox(
                        comment: _comment,
                        addComment: onPostComment,
                        clearComment: clearComment),
                    SizedBox(
                      height: 5.h,
                    ),
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("posts")
                          .doc(widget.post.postId)
                          .collection("comments")
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else {
                          return ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              final result = snapshot.data!;
                              commentModels = result.docs
                                  .map((e) => CommentModel.fromJson(e.data()))
                                  .toList();
                              CommentModel comment = commentModels[index];
                              return CommentUI(
                                  post: widget.post, comment: comment);
                            },
                          );
                        }
                      },
                    ),
                    // for (CommentModel comment in commentModel)
                    //   CommentUI(post: widget.post, comment: comment),
                  ],
                ),
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
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
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
            SizedBox(
              height: 10.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    clearComment();
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancel'),
                ),
                SizedBox(
                  width: 2.w,
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    addComment();
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  icon: const Icon(Icons.mode_comment_outlined),
                  label: const Text('Comment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ccMyPostCommentButtonBGColor(context),
                    foregroundColor: ccMyPostCommentButtonFGColor(context),
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
    required this.isCollapsed,
  });

  final Function upVote;
  final PostModel post;
  final bool isUpvoted, isCollapsed;

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
            isCollapsed
                ? PostContentText(
                    content: post.content,
                    textOverflow: TextOverflow.visible,
                  )
                : PostContentText(
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
        Expanded(
          child: Wrap(
            spacing: 16,
            children: [
              for (String tag in post.tags) PostTagChip(tag: tag),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            upVote(postId: post.postId);
          },
          icon: const Icon(Icons.arrow_upward_rounded),
          label: Text(isUpvoted ? 'Voted' : 'Vote'),
          style: ElevatedButton.styleFrom(
            backgroundColor: isUpvoted
                ? ccMyPostUpVotedBGColor(context)
                : ccMyPostUpVoteBGColor(context),
            foregroundColor: isUpvoted
                ? ccMyPostUpVotedFGColor(context)
                : ccMyPostUpVoteFGColor(context),
          ),
        )
      ],
    );
  }
}
