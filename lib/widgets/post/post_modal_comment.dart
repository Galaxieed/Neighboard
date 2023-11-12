import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/data/posts_data.dart';
import 'package:neighboard/models/comment_model.dart';
import 'package:neighboard/models/notification_model.dart';
import 'package:neighboard/models/post_model.dart';
import 'package:neighboard/models/reply_model.dart';
import 'package:neighboard/models/user_model.dart';
import 'package:neighboard/services/notification/notification.dart';
import 'package:neighboard/src/loading_screen/reply_shimmer.dart';
import 'package:neighboard/src/profile_screen/profile_screen_function.dart';
import 'package:neighboard/src/user_side/forum_page/ui/comments/comment_function.dart';
import 'package:neighboard/widgets/notification/mini_notif/elegant_notif.dart';
import 'package:neighboard/widgets/notification/notification_function.dart';
import 'package:neighboard/widgets/others/post_content_text.dart';
import 'package:responsive_builder/responsive_builder.dart';

class PostModalComment extends StatefulWidget {
  const PostModalComment({
    super.key,
    this.currentUser,
    required this.commentModel,
    required this.postModel,
    required this.isLoggedIn,
    required this.addReplyFunc,
    required this.onTypeReply,
    required this.deviceScreenType,
  });

  final UserModel? currentUser;
  final PostModel postModel;
  final CommentModel commentModel;
  final bool isLoggedIn;
  final DeviceScreenType deviceScreenType;
  final Function(
      {required String recipientId,
      required String recipientName,
      required String response,
      required String commentId}) onTypeReply;
  final Function({required String commentId, required ReplyModel reply})
      addReplyFunc;

  @override
  State<PostModalComment> createState() => _PostModalCommentState();
}

class _PostModalCommentState extends State<PostModalComment> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _controller = TextEditingController();
  List<ReplyModel> replyModels = [];
  bool isLoading = true;
  bool isRepliesShown = false;
  bool isLiked = false;
  bool isDisliked = false;
  UserModel? otherUser;

  sendNotification(userId, title, body) async {
    otherUser = await ProfileFunction.getUserDetails(userId);
    await MyNotification().sendPushMessage(
      otherUser!.deviceToken,
      title,
      body,
    );

    //Send and add notification sa receiver
    if (otherUser!.userId != widget.currentUser!.userId) {
      NotificationModel notificationModel = NotificationModel(
        notifId: DateTime.now().toIso8601String(),
        notifTitle: title,
        notifBody: body,
        notifTime: formattedDate(),
        notifLocation: "FORUM|${widget.postModel.postId}",
        isRead: false,
        isArchived: false,
      );

      await NotificationFunction.addNotification(
          notificationModel, otherUser!.userId);
    }
  }

  void checkIfLikedOrDisliked() async {
    isLiked = await CommentFunction.isAlreadyLiked(
        postId: widget.postModel.postId,
        commentId: widget.commentModel.commentId);
    isDisliked = await CommentFunction.isAlreadyDisliked(
        postId: widget.postModel.postId,
        commentId: widget.commentModel.commentId);
    if (mounted) {
      setState(() {});
    }
  }

  likeDislikeAction({required String type}) async {
    if (type == 'like') {
      if (isDisliked) {
        widget.commentModel.noOfDislikes -= 1;
        isDisliked = false;
        await CommentFunction.onDislikeAndUnDislike(
            postId: widget.postModel.postId,
            commentId: widget.commentModel.commentId,
            isDisliked: false);
      }
      if (isLiked) {
        setState(() {
          widget.commentModel.noOfLikes -= 1;
          isLiked = false;
        });
        await CommentFunction.onLikeAndUnlike(
            postId: widget.postModel.postId,
            commentId: widget.commentModel.commentId,
            isLiked: false);
      } else {
        setState(() {
          widget.commentModel.noOfLikes += 1;
          isLiked = true;
        });
        await CommentFunction.onLikeAndUnlike(
          postId: widget.postModel.postId,
          commentId: widget.commentModel.commentId,
          isLiked: true,
        );
        //send notification to the author of this comment
        sendNotification(
          widget.commentModel.senderId,
          widget.postModel.authorId == widget.currentUser!.userId
              ? 'Anonymous liked on this comment:'
              : '${widget.currentUser!.username} liked on this comment:',
          widget.commentModel.commentMessage,
        );
      }
    }
    if (type == 'dislike') {
      if (isLiked) {
        widget.commentModel.noOfLikes -= 1;
        isLiked = false;
        await CommentFunction.onLikeAndUnlike(
          postId: widget.postModel.postId,
          commentId: widget.commentModel.commentId,
          isLiked: false,
        );
      }
      if (isDisliked) {
        setState(() {
          widget.commentModel.noOfDislikes -= 1;
          isDisliked = false;
        });
        await CommentFunction.onDislikeAndUnDislike(
          postId: widget.postModel.postId,
          commentId: widget.commentModel.commentId,
          isDisliked: false,
        );
      } else {
        setState(() {
          widget.commentModel.noOfDislikes += 1;
          isDisliked = true;
        });
        await CommentFunction.onDislikeAndUnDislike(
          postId: widget.postModel.postId,
          commentId: widget.commentModel.commentId,
          isDisliked: true,
        );
        //send notification to the author of this comment
        sendNotification(
          widget.commentModel.senderId,
          widget.postModel.authorId == widget.currentUser!.userId
              ? 'Anonymous disliked on this comment:'
              : '${widget.currentUser!.username} disliked on this comment:',
          widget.commentModel.commentMessage,
        );
      }
    }
  }

  void showAllReplies(recipientId, recipientName) {
    if (widget.deviceScreenType == DeviceScreenType.mobile) {
      widget.onTypeReply(
          recipientId: recipientId,
          recipientName: recipientName,
          response: "REPLY",
          commentId: widget.commentModel.commentId);
    }
    setState(() {
      isRepliesShown = !isRepliesShown;
    });
  }

  void getAllReplies(CommentModel commentModel) async {
    replyModels = await CommentFunction.getAllReplies(
            postId: widget.postModel.postId,
            commentId: commentModel.commentId) ??
        [];
  }

  addReplyCallback({required ReplyModel reply}) async {
    widget.addReplyFunc(reply: reply, commentId: widget.commentModel.commentId);
  }

  onTypeReply(
      {required String recipientId,
      required String recipientName,
      required String response}) async {
    widget.onTypeReply(
        recipientId: recipientId,
        recipientName: recipientName,
        response: response,
        commentId: widget.commentModel.commentId);
  }

  removeComment() async {
    await CommentFunction.removeComment(
        postId: widget.postModel.postId,
        commentId: widget.commentModel.commentId);
  }

  bool isEditing = false;
  updateComment() async {
    if (_controller.text.isNotEmpty) {
      bool success = await CommentFunction.updateComment(
        postId: widget.postModel.postId,
        commentId: widget.commentModel.commentId,
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
    getAllReplies(widget.commentModel);
    checkIfLikedOrDisliked();
    _controller.text = widget.commentModel.commentMessage;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            CircleAvatar(
              backgroundImage: widget.commentModel.senderProfilePicture != ""
                  ? widget.postModel.authorId == widget.commentModel.senderId &&
                          widget.postModel.asAnonymous
                      ? const AssetImage(guestIcon) as ImageProvider
                      : NetworkImage(
                          widget.commentModel.senderProfilePicture,
                        )
                  : const AssetImage(guestIcon),
            ),
          ],
        ),
        const SizedBox(
          width: 5,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Container(
                  decoration: const BoxDecoration(
                    border:
                        Border(left: BorderSide(color: Colors.amber, width: 5)),
                  ),
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                    bottom: 10,
                    top: 10,
                  ),
                  child: Stack(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.postModel.authorId ==
                                          widget.commentModel.senderId &&
                                      widget.postModel.asAnonymous
                                  ? "Anonymous"
                                  : widget.commentModel.senderName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              widget.commentModel.timeStamp,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            isEditing
                                ? TextField(
                                    controller: _controller,
                                    onSubmitted: (value) {
                                      updateComment();
                                    },
                                    maxLines: 3,
                                    decoration: InputDecoration(
                                        suffixIcon: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _controller.text = widget
                                                  .commentModel.commentMessage;
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
                                                .primary,
                                          ),
                                        )
                                      ],
                                    )),
                                  )
                                : Text(
                                    widget.commentModel.commentMessage,
                                  ),
                            !widget.isLoggedIn ? Container() : const Divider(),
                            !widget.isLoggedIn
                                ? Container()
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      LikeButton(
                                        isLiked: isLiked,
                                        onTap: (bool isLiked) {
                                          likeDislikeAction(type: 'like');
                                          return Future.value(!isLiked);
                                        },
                                        likeBuilder: (isLiked) => isLiked
                                            ? const Icon(Icons.thumb_up)
                                            : const Icon(
                                                Icons.thumb_up_outlined),
                                        likeCount:
                                            widget.commentModel.noOfLikes,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      LikeButton(
                                        isLiked: isDisliked,
                                        onTap: (bool isLiked) {
                                          likeDislikeAction(type: 'dislike');
                                          return Future.value(!isLiked);
                                        },
                                        likeBuilder: (isLiked) => isLiked
                                            ? const Icon(Icons.thumb_down)
                                            : const Icon(
                                                Icons.thumb_down_outlined),
                                        likeCount:
                                            widget.commentModel.noOfDislikes,
                                      ),
                                      const Spacer(),
                                      TextButton.icon(
                                        onPressed: () {
                                          showAllReplies(
                                              widget.commentModel.senderId,
                                              widget.commentModel.senderName);
                                        },
                                        icon: const Icon(Icons.reply),
                                        label: Text(
                                            "Reply (${replyModels.length})"),
                                      )
                                    ],
                                  ),
                          ],
                        ),
                      ),
                      if (widget.currentUser != null &&
                          widget.currentUser!.userId ==
                              widget.commentModel.senderId)
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
                ),
              ),
              isRepliesShown
                  ? Column(
                      children: [
                        if (widget.deviceScreenType != DeviceScreenType.mobile)
                          ReplyTextBox(
                            currentUser: widget.currentUser!,
                            recipientName: widget.commentModel.senderName,
                            recipientId: widget.commentModel.senderId,
                            addReply: addReplyCallback,
                            postModel: widget.postModel,
                          ),
                        commentReplies(),
                      ],
                    )
                  : Container(),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget commentReplies() {
    return StreamBuilder(
      stream: _firestore
          .collection("posts")
          .doc(widget.postModel.postId)
          .collection("comments")
          .doc(widget.commentModel.commentId)
          .collection("replies")
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return ReplyShimmer(isLoggedIn: widget.isLoggedIn);
        } else {
          return ListView.builder(
            reverse: true,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final result = snapshot.data!;
              replyModels = result.docs
                  .map((e) => ReplyModel.fromJson(e.data()))
                  .toList();
              replyModels.sort((a, b) => a.replyId.compareTo(b.replyId));
              ReplyModel reply = replyModels[index];

              return ReplyItself(
                replyModel: reply,
                currentUser: widget.currentUser!,
                isLoggedIn: widget.isLoggedIn,
                addReply: addReplyCallback,
                onTypeReply: onTypeReply,
                deviceScreenType: widget.deviceScreenType,
                postModel: widget.postModel,
                commentModel: widget.commentModel,
              );
            },
          );
        }
      },
    );
  }
}

class ReplyItself extends StatefulWidget {
  const ReplyItself({
    super.key,
    required this.replyModel,
    required this.currentUser,
    required this.isLoggedIn,
    required this.addReply,
    required this.onTypeReply,
    required this.deviceScreenType,
    required this.postModel,
    required this.commentModel,
  });
  final PostModel postModel;
  final CommentModel commentModel;
  final DeviceScreenType deviceScreenType;
  final ReplyModel replyModel;
  final UserModel currentUser;
  final bool isLoggedIn;
  final Function(
      {required String recipientId,
      required String recipientName,
      required String response}) onTypeReply;
  final Function({required ReplyModel reply}) addReply;

  @override
  State<ReplyItself> createState() => _ReplyItselfState();
}

class _ReplyItselfState extends State<ReplyItself> {
  final TextEditingController _controller = TextEditingController();
  bool isReplyBoxShown = false;
  bool isEditing = false;

  void showReplyBox(recipientId, recipientName) {
    widget.onTypeReply(
        recipientId: recipientId,
        recipientName: recipientName,
        response: "REPLY");
    setState(() {
      isReplyBoxShown = !isReplyBoxShown;
    });
  }

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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
            decoration: const BoxDecoration(
              border:
                  Border(left: BorderSide(color: Colors.blueAccent, width: 5)),
            ),
            padding: const EdgeInsets.only(
              left: 10,
              right: 10,
              bottom: 10,
              top: 10,
            ),
            child: Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //TODO:
                      if (!isEditing)
                        const SizedBox(
                          height: 10,
                        ),
                      isEditing
                          ? TextField(
                              controller: _controller,
                              onSubmitted: (value) {
                                updateReply();
                              },
                              maxLines: 3,
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
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  )
                                ],
                              )),
                            )
                          : PostContentText(
                              content: widget.replyModel.replyMessage,
                              textOverflow: TextOverflow.visible,
                            ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Divider(),
                      !widget.isLoggedIn
                          ? Container()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  widget.postModel.authorId ==
                                              widget.replyModel.senderId &&
                                          widget.postModel.asAnonymous
                                      ? 'by @Anonymous'
                                      : 'by @${widget.replyModel.senderName}',
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
                                    showReplyBox(widget.replyModel.senderId,
                                        widget.replyModel.senderName);
                                  },
                                  icon: const Icon(Icons.reply_outlined),
                                  label: const Text('Reply'),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
                if (widget.currentUser.userId == widget.replyModel.senderId &&
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
        if (widget.deviceScreenType != DeviceScreenType.mobile)
          widget.isLoggedIn
              ? isReplyBoxShown
                  ? ReplyTextBox(
                      currentUser: widget.currentUser,
                      recipientName: widget.replyModel.senderName,
                      recipientId: widget.replyModel.senderId,
                      addReply: widget.addReply,
                      postModel: widget.postModel,
                    )
                  : Container()
              : Container(),
      ],
    );
  }
}

class ReplyTextBox extends StatefulWidget {
  const ReplyTextBox({
    super.key,
    required this.currentUser,
    required this.recipientName,
    required this.recipientId,
    required this.addReply,
    required this.postModel,
  });
  final PostModel postModel;
  final String recipientName, recipientId;
  final UserModel currentUser;
  final Function({required ReplyModel reply}) addReply;

  @override
  State<ReplyTextBox> createState() => _ReplyTextBoxState();
}

class _ReplyTextBoxState extends State<ReplyTextBox> {
  final TextEditingController controller = TextEditingController();
  UserModel? otherUser;

  sendNotification(userId) async {
    otherUser = await ProfileFunction.getUserDetails(userId);
    await MyNotification().sendPushMessage(
      otherUser!.deviceToken,
      widget.postModel.authorId == widget.currentUser.userId &&
              widget.postModel.asAnonymous
          ? 'Anonymous replied: '
          : '${widget.currentUser.username} replied: ',
      controller.text,
    );

    if (otherUser!.userId != widget.currentUser.userId) {
      NotificationModel notificationModel = NotificationModel(
        notifId: DateTime.now().toIso8601String(),
        notifTitle: widget.postModel.authorId == widget.currentUser.userId &&
                widget.postModel.asAnonymous
            ? 'Anonymous replied: '
            : '${widget.currentUser.username} replied: ',
        notifBody: controller.text,
        notifTime: formattedDate(),
        notifLocation: "FORUM|${widget.postModel.postId}",
        isRead: false,
        isArchived: false,
      );

      await NotificationFunction.addNotification(
          notificationModel, otherUser!.userId);
    }
  }

  @override
  void initState() {
    super.initState();
    controller.text = widget.postModel.authorId == widget.recipientId &&
            widget.postModel.asAnonymous
        ? 'Anonymous '
        : "${widget.recipientName} ";
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: widget.currentUser.profilePicture != ''
              ? NetworkImage(
                  widget.currentUser.profilePicture,
                )
              : const AssetImage(guestIcon) as ImageProvider,
        ),
        Expanded(
          child: Card(
            child: TextField(
              onChanged: (value) {
                setState(() {});
              },
              onSubmitted: (value) {
                if (controller.text.isNotEmpty) {
                  ReplyModel newReply = ReplyModel(
                    replyId: DateTime.now().toIso8601String(),
                    senderId: widget.currentUser.userId,
                    senderName: widget.currentUser.username,
                    recipientId: widget.recipientId,
                    recipientName: widget.recipientName,
                    replyMessage: controller.text,
                  );
                  widget.addReply(reply: newReply);
                  //send notification to the recipient of this reply (from desktop)
                  sendNotification(widget.recipientId);
                  setState(() {
                    controller.clear();
                  });
                }
              },
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        IconButton(
          mouseCursor:
              controller.text.isEmpty ? SystemMouseCursors.forbidden : null,
          onPressed: controller.text.isEmpty
              ? null
              : () {
                  ReplyModel newReply = ReplyModel(
                    replyId: DateTime.now().toIso8601String(),
                    senderId: widget.currentUser.userId,
                    senderName: widget.currentUser.username,
                    recipientId: widget.recipientId,
                    recipientName: widget.recipientName,
                    replyMessage: controller.text,
                  );
                  widget.addReply(reply: newReply);
                  //send notification to the recipient of this reply (from desktop)
                  sendNotification(widget.recipientId);
                  setState(() {
                    controller.clear();
                  });
                },
          icon: const Icon(Icons.send),
        ),
      ],
    );
  }
}
