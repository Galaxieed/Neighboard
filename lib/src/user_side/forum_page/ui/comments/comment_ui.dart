import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:neighboard/models/comment_model.dart';
import 'package:neighboard/models/post_model.dart';
import 'package:neighboard/models/reply_model.dart';
import 'package:neighboard/models/user_model.dart';
import 'package:neighboard/src/loading_screen/reply_shimmer.dart';
import 'package:neighboard/src/user_side/forum_page/ui/comments/comment_function.dart';
import 'package:neighboard/src/profile_screen/profile_screen_function.dart';
import 'package:neighboard/widgets/notification/mini_notif/elegant_notif.dart';
import 'package:neighboard/widgets/others/author_name_text.dart';
import 'package:neighboard/widgets/others/post_content_text.dart';
import 'package:neighboard/widgets/others/post_time_text.dart';
import 'package:neighboard/widgets/others/small_profile_pic.dart';

class CommentUI extends StatefulWidget {
  const CommentUI(
      {Key? key, required this.post, required this.comment, this.currentUser})
      : super(key: key);

  final PostModel post;
  final CommentModel comment;
  final UserModel? currentUser;

  @override
  State<CommentUI> createState() => _CommentUIState();
}

class _CommentUIState extends State<CommentUI> {
  bool isRepliesVisible = false;
  bool isReplyBoxVisible = false;
  bool isLiked = false;
  bool isDisliked = false;

  setRepliesVisible(bool condition) {
    setState(() {
      isRepliesVisible = condition;
    });
  }

  setReplyBoxVisible(bool condition) {
    setState(() {
      isReplyBoxVisible = condition;
    });
  }

  void checkIfLikedOrDisliked() async {
    isLiked = await CommentFunction.isAlreadyLiked(
        postId: widget.post.postId, commentId: widget.comment.commentId);
    isDisliked = await CommentFunction.isAlreadyDisliked(
        postId: widget.post.postId, commentId: widget.comment.commentId);
    if (mounted) {
      setState(() {});
    }
  }

  likeDislikeAction({required String type}) async {
    if (type == 'like') {
      if (isDisliked) {
        widget.comment.noOfDislikes -= 1;
        isDisliked = false;
        await CommentFunction.onDislikeAndUnDislike(
            postId: widget.post.postId,
            commentId: widget.comment.commentId,
            isDisliked: false);
      }
      if (isLiked) {
        setState(() {
          widget.comment.noOfLikes -= 1;
          isLiked = false;
        });
        await CommentFunction.onLikeAndUnlike(
            postId: widget.post.postId,
            commentId: widget.comment.commentId,
            isLiked: false);
      } else {
        setState(() {
          widget.comment.noOfLikes += 1;
          isLiked = true;
        });
        await CommentFunction.onLikeAndUnlike(
            postId: widget.post.postId,
            commentId: widget.comment.commentId,
            isLiked: true);
      }
    }
    if (type == 'dislike') {
      if (isLiked) {
        widget.comment.noOfLikes -= 1;
        isLiked = false;
        await CommentFunction.onLikeAndUnlike(
            postId: widget.post.postId,
            commentId: widget.comment.commentId,
            isLiked: false);
      }
      if (isDisliked) {
        setState(() {
          widget.comment.noOfDislikes -= 1;
          isDisliked = false;
        });
        await CommentFunction.onDislikeAndUnDislike(
            postId: widget.post.postId,
            commentId: widget.comment.commentId,
            isDisliked: false);
      } else {
        setState(() {
          widget.comment.noOfDislikes += 1;
          isDisliked = true;
        });
        await CommentFunction.onDislikeAndUnDislike(
            postId: widget.post.postId,
            commentId: widget.comment.commentId,
            isDisliked: true);
      }
    }
  }

  final TextEditingController _controller = TextEditingController();
  removeComment() async {
    await CommentFunction.removeComment(
        postId: widget.post.postId, commentId: widget.comment.commentId);
  }

  bool isEditing = false;
  updateComment() async {
    if (_controller.text.isNotEmpty) {
      bool success = await CommentFunction.updateComment(
        postId: widget.post.postId,
        commentId: widget.comment.commentId,
        commentMessage: _controller.text,
      );
      if (success) {
        // ignore: use_build_context_synchronously
        successMessage(
            title: "Success!", desc: "Comment was edited", context: context);
      } else {
        // ignore: use_build_context_synchronously
        errorMessage(
            title: "Something went wrong!",
            desc: "Comment was not edited",
            context: context);
      }
    }
    setState(() {
      isEditing = false;
    });
  }

  @override
  void initState() {
    super.initState();
    checkIfLikedOrDisliked();
    _controller.text = widget.comment.commentMessage;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(
          color: Theme.of(context).primaryColor,
        ),
        Card(
          elevation: 2,
          child: Container(
            decoration: const BoxDecoration(
              border: Border(left: BorderSide(color: Colors.amber, width: 5)),
            ),
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
                              profilePic: widget.comment.senderProfilePicture),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                AuthorNameText(
                                    authorName: widget.comment.senderName),
                                PostTimeText(time: widget.comment.timeStamp),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (widget.currentUser != null &&
                          widget.currentUser!.userId == widget.comment.senderId)
                        Positioned(
                          top: 1,
                          right: 1,
                          child: PopupMenuButton(
                            onSelected: (value) {
                              if (value == "Edit") {
                                setState(() {
                                  isEditing = !isEditing;
                                });
                              } else if (value == "Delete") {
                                removeComment();
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
                          controller: _controller,
                          decoration: InputDecoration(
                              suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _controller.text =
                                        widget.comment.commentMessage;
                                    isEditing = false;
                                  });
                                },
                                icon: const Icon(
                                  Icons.cancel_outlined,
                                  color: Colors.red,
                                ),
                              ),
                              IconButton(
                                onPressed: updateComment,
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
                          content:
                              '${widget.post.authorName}, ${widget.comment.commentMessage}',
                          textOverflow: TextOverflow.visible,
                        ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Divider(),
                  const SizedBox(
                    height: 10,
                  ),
                  ActionBarComment(
                    postId: widget.post.postId,
                    comment: widget.comment,
                    isRepliesVisible: isRepliesVisible,
                    setRepliesVisible: setRepliesVisible,
                    setReplyBoxVisible: setReplyBoxVisible,
                    likeDislikeAction: likeDislikeAction,
                    isAlreadyLiked: isLiked,
                    isAlreadyDisliked: isDisliked,
                  ),
                ],
              ),
            ),
          ),
        ),
        RepliesContainer(
          userModel: widget.currentUser,
          post: widget.post,
          comment: widget.comment,
          setRepliesVisible: setRepliesVisible,
          isRepliesVisible: isRepliesVisible,
          isReplyBoxVisible: isReplyBoxVisible,
          setReplyBoxVisible: setReplyBoxVisible, //Yung addReply ayusin
        ),
        const SizedBox(
          height: 5,
        ),
      ],
    );
  }
}

// ignore: must_be_immutable
class RepliesContainer extends StatefulWidget {
  const RepliesContainer({
    super.key,
    required this.post,
    required this.comment,
    required this.setRepliesVisible,
    required this.setReplyBoxVisible,
    required this.isReplyBoxVisible,
    required this.isRepliesVisible,
    this.userModel,
  });

  final bool isRepliesVisible, isReplyBoxVisible;
  final Function setRepliesVisible, setReplyBoxVisible;
  final CommentModel comment;
  final PostModel post;
  final UserModel? userModel;

  @override
  State<RepliesContainer> createState() => _RepliesContainerState();
}

class _RepliesContainerState extends State<RepliesContainer> {
  List<ReplyModel> replyModel = [];

  addReplyCallback({required ReplyModel reply}) async {
    await CommentFunction.postReply(
      postId: widget.post.postId,
      commentId: widget.comment.commentId,
      replyModel: reply,
    );
    replyModel.add(reply);
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.isRepliesVisible,
      child: Column(
        children: [
          ReplyTextField(
            visibility: widget.isReplyBoxVisible,
            addReply: addReplyCallback,
            setVisibility: widget.setReplyBoxVisible,
            recipientId: widget.comment.senderId,
            recipientName: widget.comment.senderName,
          ),
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("posts")
                .doc(widget.post.postId)
                .collection("comments")
                .doc(widget.comment.commentId)
                .collection("replies")
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const ReplyShimmer(isLoggedIn: true);
              } else {
                return ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final result = snapshot.data!;
                    replyModel = result.docs
                        .map((e) => ReplyModel.fromJson(e.data()))
                        .toList();
                    replyModel.sort((a, b) => b.replyId.compareTo(a.replyId));
                    ReplyModel reply = replyModel[index];
                    return SingleReplyUI(
                      replyModel: reply,
                      postModel: widget.post,
                      commentModel: widget.comment,
                      userModel: widget.userModel,
                      addReply: addReplyCallback,
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class SingleReplyUI extends StatefulWidget {
  const SingleReplyUI({
    super.key,
    required this.replyModel,
    required this.addReply,
    required this.postModel,
    required this.commentModel,
    this.userModel,
  });

  final Function addReply;
  final PostModel postModel;
  final CommentModel commentModel;
  final ReplyModel replyModel;
  final UserModel? userModel;

  @override
  State<SingleReplyUI> createState() => _SingleReplyUIState();
}

class _SingleReplyUIState extends State<SingleReplyUI> {
  bool replyBoxVisibility = false;

  setReplyBoxVisible(bool condition) {
    setState(() {
      replyBoxVisibility = condition;
    });
  }

  final TextEditingController _controller = TextEditingController();
  bool isEditing = false;

  removeReply() async {
    await CommentFunction.removeReply(
        postId: widget.postModel.postId,
        commentId: widget.commentModel.commentId,
        replyId: widget.replyModel.replyId);
  }

  updateReply() async {
    if (_controller.text.isNotEmpty) {
      bool isSuccess = await CommentFunction.updateReply(
        postId: widget.postModel.postId,
        commentId: widget.commentModel.commentId,
        replyId: widget.replyModel.replyId,
        replyMessage: _controller.text,
      );
      if (isSuccess) {
        // ignore: use_build_context_synchronously
        successMessage(
            title: "Success!", desc: "Reply was edited!", context: context);
      } else {
        // ignore: use_build_context_synchronously
        errorMessage(
            title: "Something went wrong!",
            desc: "Reply was not edited!",
            context: context);
      }
    }
    setState(() {
      isEditing = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller.text = widget.replyModel.replyMessage;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          elevation: 2,
          child: Container(
            decoration: const BoxDecoration(
              border:
                  Border(left: BorderSide(color: Colors.blueAccent, width: 5)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      isEditing
                          ? TextField(
                              controller: _controller,
                              decoration: InputDecoration(
                                  suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _controller.text =
                                            widget.replyModel.replyMessage;
                                        isEditing = false;
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.cancel_outlined,
                                      color: Colors.red,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: updateReply,
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
                              content:
                                  '${widget.replyModel.recipientName}, ${widget.replyModel.replyMessage}',
                              textOverflow: TextOverflow.visible,
                            ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'by @${widget.replyModel.senderName}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                            ),
                          ),
                          const Expanded(
                              child: SizedBox(
                            width: 10,
                          )),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                replyBoxVisibility = true;
                                setReplyBoxVisible(replyBoxVisibility);
                              });
                            },
                            icon: const Icon(Icons.reply_outlined),
                            label: const Text('Reply'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (widget.userModel != null &&
                      widget.userModel!.userId == widget.replyModel.senderId &&
                      !isEditing)
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
                            removeReply();
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
            ),
          ),
        ),
        ReplyTextField(
          visibility: replyBoxVisibility,
          addReply: widget.addReply,
          setVisibility: setReplyBoxVisible,
          recipientId: widget.replyModel.senderId,
          recipientName: widget.replyModel.senderName,
        ),
      ],
    );
  }
}

// ignore: must_be_immutable
class ReplyTextField extends StatefulWidget {
  ReplyTextField({
    super.key,
    required this.visibility,
    required this.addReply,
    this.setVisibility,
    required this.recipientId,
    required this.recipientName,
  });

  final Function addReply;
  final Function? setVisibility;
  bool visibility;
  final String recipientId;
  final String recipientName;

  @override
  State<ReplyTextField> createState() => _ReplyTextFieldState();
}

class _ReplyTextFieldState extends State<ReplyTextField> {
  TextEditingController replyController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  UserModel? userModel;

  void getUserDetails() async {
    userModel = await ProfileFunction.getUserDetails(_auth.currentUser!.uid);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.visibility,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: replyController,
                autofocus: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  labelText: 'Enter Reply..',
                  alignLabelWithHint: true,
                ),
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            IconButton(
              onPressed: () {
                final ReplyModel thisReply = ReplyModel(
                  replyId: DateTime.now().toIso8601String(),
                  senderId: _auth.currentUser!.uid,
                  senderName: userModel!.username,
                  recipientId: widget.recipientId,
                  recipientName: widget.recipientName,
                  replyMessage: replyController.text,
                );
                widget.addReply(reply: thisReply);
                replyController.clear();
                widget.setVisibility!(false);
              },
              icon: const Icon(Icons.send),
            )
          ],
        ),
      ),
    );
  }
}

class ActionBarComment extends StatelessWidget {
  const ActionBarComment({
    super.key,
    required this.postId,
    required this.comment,
    required this.setRepliesVisible,
    required this.setReplyBoxVisible,
    required this.likeDislikeAction,
    required this.isRepliesVisible,
    required this.isAlreadyLiked,
    required this.isAlreadyDisliked,
  });
  final bool isRepliesVisible, isAlreadyLiked, isAlreadyDisliked;
  final String postId;
  final CommentModel comment;
  final Function setRepliesVisible, setReplyBoxVisible, likeDislikeAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        LikeButton(
          isLiked: isAlreadyLiked,
          onTap: (bool isLiked) {
            likeDislikeAction(type: 'like');
            return Future.value(!isLiked);
          },
          likeBuilder: (isLiked) => isLiked
              ? const Icon(Icons.thumb_up)
              : const Icon(Icons.thumb_up_outlined),
          likeCount: comment.noOfLikes,
        ),
        const SizedBox(
          width: 20,
        ),
        LikeButton(
          isLiked: isAlreadyDisliked,
          onTap: (bool isLiked) {
            likeDislikeAction(type: 'dislike');
            return Future.value(!isLiked);
          },
          likeBuilder: (isLiked) => isLiked
              ? const Icon(Icons.thumb_down)
              : const Icon(Icons.thumb_down_outlined),
          likeCount: comment.noOfDislikes,
        ),
        const Expanded(
            child: SizedBox(
          width: 10,
        )),
        TextButton.icon(
          onPressed: () {
            if (isRepliesVisible) {
              setReplyBoxVisible(false);
              setRepliesVisible(false);
            } else {
              setRepliesVisible(true);
              setReplyBoxVisible(true);
            }
          },
          icon: const Icon(Icons.reply_outlined),
          label: Text(
              !isRepliesVisible ? 'Reply' : 'Reply (${comment.noOfReplies})'),
        ),
      ],
    );
  }
}
