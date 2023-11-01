import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
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
import 'package:neighboard/widgets/notification/mini_notif/elegant_notif.dart';
import 'package:neighboard/widgets/others/author_name_text.dart';
import 'package:neighboard/widgets/others/post_content_text.dart';
import 'package:neighboard/widgets/others/post_tag_chip.dart';
import 'package:neighboard/widgets/others/post_time_text.dart';
import 'package:neighboard/widgets/others/post_title_text.dart';
import 'package:neighboard/widgets/others/small_profile_pic.dart';
import 'package:neighboard/widgets/page_messages/page_messages.dart';
import 'package:neighboard/widgets/post/post_interactors_function.dart';

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
    setState(() {
      isLoading = true;
    });
    try {
      postModels =
          await MyPostFunction.getMyPost(authorId: _auth.currentUser!.uid) ??
              [];
      postModels.sort((a, b) => b.postId.compareTo(a.postId));
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
    setState(() {
      isLoading = true;
    });
    try {
      postModels = await MyPostFunction.getMyPostByTitle(
              authorId: _auth.currentUser!.uid, searchedWord: widget.search) ??
          [];
      postModels.sort((a, b) => widget.search.trim().compareTo(a.title));
    } catch (e) {
      return;
    }
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (_auth.currentUser == null) {
      isLoggedIn = false;
      isLoading = false;
      setState(() {});
    } else {
      isLoggedIn = true;
      getMyPosts();
    }
  }

  @override
  void didUpdateWidget(covariant MyPosts oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (isLoggedIn) {
      if (widget.search.isNotEmpty || widget.search != "") {
        getMyPostsByTitle();
      } else {
        getMyPosts();
      }
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
                : SingleChildScrollView(
                    child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: postModels.length,
                        itemBuilder: (context, index) {
                          PostModel post = postModels[index];
                          return Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 0.w, vertical: 5.h),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: MyPostWithComments(
                                  post: post,
                                  stateSetter: () {
                                    getMyPosts();
                                  },
                                )),
                          );
                        }),
                  );
  }
}

class MyPostWithComments extends StatefulWidget {
  const MyPostWithComments({
    super.key,
    required this.post,
    required this.stateSetter,
  });

  final PostModel post;
  final Function stateSetter;

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
    getCurrentUser();
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
        ? const LoadingPosts(
            postType: "My Posts",
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
                    stateSetter: widget.stateSetter,
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
                          return const LoadingPosts(
                            postType: "My Posts",
                          );
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
                              commentModels.sort(
                                  (a, b) => b.commentId.compareTo(a.commentId));
                              CommentModel comment = commentModels[index];
                              return CommentUI(
                                  post: widget.post,
                                  comment: comment,
                                  currentUser: currentUser);
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

class SingleMyPost extends StatefulWidget {
  const SingleMyPost({
    super.key,
    required this.post,
    required this.upVote,
    required this.isUpvoted,
    required this.isCollapsed,
    required this.stateSetter,
  });

  final Function upVote, stateSetter;
  final PostModel post;
  final bool isUpvoted, isCollapsed;

  @override
  State<SingleMyPost> createState() => _SingleMyPostState();
}

class _SingleMyPostState extends State<SingleMyPost> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool isEditing = false;

  removePost() async {
    widget.stateSetter();
    successMessage(
        title: "Success!", desc: "Post was deleted!", context: context);
    await PostInteractorsFunctions.removePost(postModel: widget.post);
  }

  updatePost() async {
    if (_contentController.text.isNotEmpty &&
        _titleController.text.isNotEmpty) {
      bool isSucceess = await PostInteractorsFunctions.updatePost(
        postId: widget.post.postId,
        postTitle: _titleController.text,
        postContent: _contentController.text,
      );
      if (isSucceess) {
        // ignore: use_build_context_synchronously
        successMessage(
            title: "Success!",
            desc: "Post was edited!\nReopen this to see changes",
            context: context);
      } else {
        // ignore: use_build_context_synchronously
        errorMessage(
            title: "Something went wrong!",
            desc: "Post was not edited",
            context: context);
      }
    }
    isEditing = false;
    setState(() {});
    widget.stateSetter();
  }

  //picture
  int noOfPics = 0;
  int extraPics = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.post.images.length < 5) {
      noOfPics = widget.post.images.length;
    } else {
      noOfPics = 4;
      extraPics = widget.post.images.length - 4;
    }
    _titleController.text = widget.post.title;
    _contentController.text = widget.post.content;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Row(
                  children: [
                    SmallProfilePic(
                      profilePic: widget.post.asAnonymous
                          ? ""
                          : widget.post.profilePicture,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          AuthorNameText(
                              authorName: widget.post.asAnonymous
                                  ? "Anonymous"
                                  : widget.post.authorName),
                          PostTimeText(time: widget.post.timeStamp),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_auth.currentUser != null &&
                    _auth.currentUser!.uid == widget.post.authorId)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: PopupMenuButton(
                      onSelected: (value) {
                        if (value == "Edit") {
                          setState(() {
                            isEditing = !isEditing;
                          });
                        } else if (value == "Delete") {
                          removePost();
                        }
                      },
                      itemBuilder: (context) {
                        return [
                          const PopupMenuItem(
                            value: "Edit",
                            child: ListTile(
                              leading: Icon(Icons.edit),
                              title: Text("Edit"),
                            ),
                          ),
                          const PopupMenuItem(
                            value: "Delete",
                            child: ListTile(
                              leading: Icon(Icons.delete_outlined),
                              title: Text("Delete"),
                            ),
                          ),
                        ];
                      },
                    ),
                  )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            isEditing
                ? TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                        suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _titleController.text = widget.post.title;
                              isEditing = false;
                            });
                          },
                          icon: const Icon(
                            Icons.cancel_outlined,
                            color: Colors.red,
                          ),
                        ),
                        IconButton(
                          onPressed: updatePost,
                          icon: Icon(
                            Icons.save,
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        )
                      ],
                    )),
                  )
                : PostTitleText(title: widget.post.title),
            const SizedBox(
              height: 5,
            ),
            widget.isCollapsed
                ? isEditing
                    ? TextField(
                        controller: _contentController,
                        maxLines: 3,
                        decoration: InputDecoration(
                            suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _contentController.text = widget.post.content;
                                  isEditing = false;
                                });
                              },
                              icon: const Icon(
                                Icons.cancel_outlined,
                                color: Colors.red,
                              ),
                            ),
                            IconButton(
                              onPressed: updatePost,
                              icon: Icon(
                                Icons.save,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary,
                              ),
                            )
                          ],
                        )),
                      )
                    : PostContentText(
                        content: widget.post.content,
                        textOverflow: TextOverflow.visible,
                      )
                : isEditing
                    ? TextField(
                        controller: _contentController,
                        maxLines: 3,
                        decoration: InputDecoration(
                            suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _contentController.text = widget.post.content;
                                  isEditing = false;
                                });
                              },
                              icon: const Icon(
                                Icons.cancel_outlined,
                                color: Colors.red,
                              ),
                            ),
                            IconButton(
                              onPressed: updatePost,
                              icon: Icon(
                                Icons.save,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary,
                              ),
                            )
                          ],
                        )),
                      )
                    : PostContentText(
                        content: widget.post.content,
                        maxLine: 3,
                        textOverflow: TextOverflow.ellipsis,
                      ),
            const SizedBox(
              height: 10,
            ),
            if (widget.post.images.isNotEmpty)
              SizedBox(
                height: 400,
                width: double.infinity,
                child: LayoutGrid(
                  autoPlacement: AutoPlacement.columnSparse,
                  rowGap: 10,
                  columnGap: 10,
                  columnSizes: [1.fr, 1.fr],
                  rowSizes: [1.fr, 1.fr],
                  children: [
                    for (int i = 0; i < noOfPics; i++)
                      GridPlacement(
                        rowSpan: noOfPics <= 2
                            ? 2
                            : i == noOfPics - 1 && noOfPics % 2 != 0
                                ? 2
                                : 1,
                        columnSpan: i == noOfPics - 1 && noOfPics == 1 ? 2 : 1,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.network(
                                widget.post.images[i],
                                height: double.infinity,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              if (i == noOfPics - 1 && extraPics != 0)
                                Positioned(
                                  child: ClipRRect(
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                          sigmaX: 5, sigmaY: 5),
                                      child: SizedBox(
                                        height: double.infinity,
                                        width: double.infinity,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.add,
                                              size: 75,
                                              weight: 75,
                                              color: Colors.white,
                                            ),
                                            Text(
                                              extraPics.toString(),
                                              style: const TextStyle(
                                                  fontSize: 75,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(
              height: 10,
            ),
            ActionBarMyPost(
              post: widget.post,
              upVote: widget.upVote,
              isUpvoted: widget.isUpvoted,
              isEditing: isEditing,
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
    required this.isEditing,
  });

  final bool isUpvoted;
  final Function upVote;
  final PostModel post;
  final bool isEditing;

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
        if (!isEditing)
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
