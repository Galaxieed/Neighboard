import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:neighboard/data/posts_data.dart';
import 'package:neighboard/models/comment_model.dart';
import 'package:neighboard/models/notification_model.dart';
import 'package:neighboard/models/post_model.dart';
import 'package:neighboard/models/reply_model.dart';
import 'package:neighboard/models/user_model.dart';
import 'package:neighboard/services/notification/notification.dart';
import 'package:neighboard/src/loading_screen/loading_screen.dart';
import 'package:neighboard/src/profile_screen/profile_screen_function.dart';
import 'package:neighboard/src/user_side/forum_page/ui/comments/comment_function.dart';
import 'package:neighboard/src/user_side/forum_page/ui/my_posts/my_post_function.dart';
import 'package:neighboard/widgets/notification/notification_function.dart';
import 'package:neighboard/widgets/post/post_interactors_function.dart';
import 'package:neighboard/widgets/post/post_modal_comment.dart';
import 'package:responsive_builder/responsive_builder.dart';

class PostModal extends StatefulWidget {
  const PostModal(
      {super.key, required this.postModel, required this.deviceScreenType});

  final PostModel postModel;
  final DeviceScreenType deviceScreenType;

  @override
  State<PostModal> createState() => _PostModalState();
}

class _PostModalState extends State<PostModal> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FocusNode focusComment = FocusNode();
  final TextEditingController _ctrlComment = TextEditingController();
  List<CommentModel> commentModels = [];
  UserModel? currentUser, otherUser;
  bool isUpvoted = false;
  bool isLoading = true;
  bool isLoggedIn = false;
  String? respondType, cmntId, recipientId, recipientName;

  void getCurrentUser() async {
    currentUser = await ProfileFunction.getUserDetails(_auth.currentUser!.uid);
  }

  sendNotification(userId, title, body) async {
    otherUser = await ProfileFunction.getUserDetails(userId);
    await MyNotification().sendPushMessage(
      otherUser!.deviceToken,
      title,
      body,
    );

    //ADD sa notification TAB

    if (otherUser!.userId != currentUser!.userId) {
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

  void addComment() async {
    if (_ctrlComment.text.isNotEmpty) {
      //for reply in mobile layout
      if (respondType != null && respondType == "REPLY") {
        addReplyMobile();

        respondType = '';
        FocusManager.instance.primaryFocus?.unfocus();
        return;
      }
      setState(() {
        isLoading = true;
      });
      CommentModel commentModel = CommentModel(
        commentId: DateTime.now().toIso8601String(),
        senderId: currentUser!.userId,
        senderProfilePicture: currentUser!.profilePicture,
        senderName: currentUser!.username,
        timeStamp: formattedDate(),
        commentMessage: _ctrlComment.text,
        noOfLikes: 0,
        noOfDislikes: 0,
        noOfReplies: 0,
      );
      await CommentFunction.postComment(
        postId: widget.postModel.postId,
        commentModel: commentModel,
      );
      commentModels.sort((a, b) => b.commentId.compareTo(a.commentId));
      _ctrlComment.clear();
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }

      //send notification to the author of this post
      sendNotification(
        widget.postModel.authorId,
        '${currentUser!.username} commented on this post: ',
        widget.postModel.title,
      );
    } else {
      return;
    }
  }

  Future<void> timer() async {
    await Future.delayed(const Duration(milliseconds: 750), () {
      if (commentModels != []) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  void checkIfUpVoted() async {
    isUpvoted =
        await MyPostFunction.isAlreadyUpvoted(postId: widget.postModel.postId);
    if (mounted) {
      setState(() {});
    }
  }

  void onUpVote() async {
    if (isUpvoted) {
      setState(() {
        widget.postModel.noOfUpVotes -= 1;
        isUpvoted = false;
      });
      await MyPostFunction.onUpvoteAndUnUpvote(
          postId: widget.postModel.postId, isUpvoted: false);
    } else {
      setState(() {
        widget.postModel.noOfUpVotes += 1;
        isUpvoted = true;
      });
      await MyPostFunction.onUpvoteAndUnUpvote(
          postId: widget.postModel.postId, isUpvoted: true);

      //send Notification to the author when upvoted
      sendNotification(
          widget.postModel.authorId,
          '${currentUser!.username} upvoted this post: ',
          widget.postModel.title);
    }
  }

  onTypeReply({
    required String recipientName,
    required String recipientId,
    required String response,
    required String commentId,
  }) {
    if (widget.deviceScreenType == DeviceScreenType.mobile) {
      _ctrlComment.text = "$recipientName ";
      focusComment.requestFocus();
      respondType = response;
      cmntId = commentId;
      this.recipientId = recipientId;
      this.recipientName = recipientName;
    }
  }

  addReplyMobile() async {
    ReplyModel newReply = ReplyModel(
      replyId: DateTime.now().toIso8601String(),
      senderId: currentUser!.userId,
      senderName: currentUser!.username,
      recipientId: recipientId!,
      recipientName: recipientName!,
      replyMessage: _ctrlComment.text,
    );
    //send notification to the recipient of this reply (from mobile)
    sendNotification(
      recipientId,
      '${currentUser!.username} replied: ',
      _ctrlComment.text,
    );
    await CommentFunction.postReply(
      postId: widget.postModel.postId,
      commentId: cmntId!,
      replyModel: newReply,
    ).then((value) => _ctrlComment.clear());
  }

  addReplyCallback(
      {required ReplyModel reply, required String commentId}) async {
    await CommentFunction.postReply(
      postId: widget.postModel.postId,
      commentId: commentId,
      replyModel: reply,
    );
  }

  bool isAlreadyViewed = false;

  void checkIfAlreadyViewed() async {
    isAlreadyViewed = await PostInteractorsFunctions.isAlreadyViewed(
        postId: widget.postModel.postId);

    onOpenPost();
    setState(() {});
  }

  void onOpenPost() async {
    if (!isAlreadyViewed) {
      if (isLoggedIn && currentUser!.userId != widget.postModel.authorId) {
        setState(() {
          isAlreadyViewed = true;
          widget.postModel.noOfViews += 1;
        });
        await PostInteractorsFunctions.onViewPost(
            widget.postModel.postId, true);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (_auth.currentUser != null) {
      getCurrentUser();
      isLoggedIn = true;
      checkIfUpVoted();
      checkIfAlreadyViewed();
      setState(() {});
    } else {
      isLoggedIn = false;
      setState(() {});
    }
    timer();
    // getAllComments();
  }

  @override
  void dispose() {
    _ctrlComment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return kIsWeb
        ? SizedBox(
            width: 720,
            child: isLoading ? const LoadingScreen() : thisPost(context),
          )
        : Container(
            width: 720,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: isLoading ? const LoadingScreen() : thisPost(context),
          );
  }

  Widget thisPost(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          "${widget.postModel.authorName}'s Post",
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: isLoggedIn
          ? ReplyCommentBox(
              currentUser: currentUser,
              focusComment: focusComment,
              ctrlComment: _ctrlComment,
              addComment: addComment)
          : null,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              postDetails(context),
              const SizedBox(
                height: 10,
              ),
              Text(
                widget.postModel.title,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              Text(widget.postModel.content),
              const SizedBox(
                width: 10,
              ),
              const Divider(),
              isLoggedIn
                  ? postActions()
                  : const Center(child: Text("Login First")),
              const Divider(),
              //postComments(),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("posts")
                    .doc(widget.postModel.postId)
                    .collection("comments")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
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

                        return PostModalComment(
                          currentUser: currentUser,
                          postModel: widget.postModel,
                          commentModel: comment,
                          isLoggedIn: isLoggedIn,
                          addReplyFunc: addReplyCallback,
                          onTypeReply: onTypeReply,
                          deviceScreenType: widget.deviceScreenType,
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ListView postComments(List<CommentModel> commentModels) {
  //   return ListView.builder(
  //     shrinkWrap: true,
  //     itemCount: commentModels.length,
  //     itemBuilder: (context, index) {
  //       CommentModel comment = commentModels[index];
  //       return PostModalComment(
  //         currentUser: currentUser,
  //         postModel: widget.postModel,
  //         commentModel: comment,
  //         isLoggedIn: isLoggedIn,
  //       );
  //     },
  //   );
  // }

  Row postActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        LikeButton(
          isLiked: isUpvoted,
          onTap: (bool isLiked) {
            onUpVote();
            return Future.value(!isLiked);
          },
          likeBuilder: (isLiked) => isLiked
              ? const Icon(Icons.arrow_downward)
              : const Icon(Icons.arrow_upward),
          likeCount: widget.postModel.noOfUpVotes,
        ),
        TextButton.icon(
          onPressed: () {
            focusComment.requestFocus();
          },
          icon: const Icon(Icons.comment_bank_outlined),
          label: const Text("Comment"),
        ),
      ],
    );
  }

  Row postDetails(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: widget.postModel.profilePicture != ""
              ? NetworkImage(widget.postModel.profilePicture)
              : null,
        ),
        const SizedBox(
          width: 10,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.postModel.authorName,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              widget.postModel.timeStamp,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_horiz),
        ),
      ],
    );
  }
}

class ReplyCommentBox extends StatefulWidget {
  const ReplyCommentBox(
      {super.key,
      this.currentUser,
      required this.focusComment,
      required this.ctrlComment,
      required this.addComment});

  final UserModel? currentUser;
  final FocusNode focusComment;
  final TextEditingController ctrlComment;
  final void Function() addComment;

  @override
  State<ReplyCommentBox> createState() => _ReplyCommentBoxState();
}

class _ReplyCommentBoxState extends State<ReplyCommentBox> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: widget.currentUser!.profilePicture != ""
            ? NetworkImage(widget.currentUser!.profilePicture)
            : null,
      ),
      title: Card(
        child: TextField(
          onChanged: (a) {
            setState(() {});
          },
          controller: widget.ctrlComment,
          focusNode: widget.focusComment,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: "Write a public comment...",
          ),
        ),
      ),
      trailing: IconButton(
        mouseCursor: widget.ctrlComment.text.isNotEmpty
            ? null
            : SystemMouseCursors.forbidden,
        onPressed: widget.ctrlComment.text.isNotEmpty
            ? () {
                widget.addComment();
                widget.ctrlComment.clear();
              }
            : null,
        icon: const Icon(Icons.send_outlined),
      ),
    );
  }
}
