import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/data/posts_data.dart';
import 'package:neighboard/main.dart';
import 'package:neighboard/models/comment_model.dart';
import 'package:neighboard/models/notification_model.dart';
import 'package:neighboard/models/post_model.dart';
import 'package:neighboard/models/reply_model.dart';
import 'package:neighboard/models/user_model.dart';
import 'package:neighboard/routes/routes.dart';
import 'package:neighboard/services/notification/notification.dart';
import 'package:neighboard/src/loading_screen/loading_screen.dart';
import 'package:neighboard/src/profile_screen/profile_screen_function.dart';
import 'package:neighboard/src/user_side/forum_page/ui/comments/comment_function.dart';
import 'package:neighboard/src/user_side/forum_page/ui/my_posts/my_post_function.dart';
import 'package:neighboard/widgets/notification/mini_notif/elegant_notif.dart';
import 'package:neighboard/widgets/notification/notification_function.dart';
import 'package:neighboard/widgets/post/post_interactors_function.dart';
import 'package:neighboard/widgets/post/post_modal_comment.dart';
import 'package:neighboard/widgets/post/post_page.dart';
import 'package:responsive_builder/responsive_builder.dart';

class PostModal extends StatefulWidget {
  const PostModal(
      {super.key,
      required this.postModel,
      required this.deviceScreenType,
      this.stateSetter});

  final PostModel postModel;
  final DeviceScreenType deviceScreenType;
  final Function? stateSetter;

  @override
  State<PostModal> createState() => _PostModalState();
}

class _PostModalState extends State<PostModal> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FocusNode focusComment = FocusNode();
  final TextEditingController _ctrlComment = TextEditingController();
  List<CommentModel> commentModels = [];
  UserModel? currentUser, otherUser;
  String isUpvoted = "";
  bool isLoading = true;
  bool isLoggedIn = false;
  String? respondType, cmntId, recipientId, recipientName;

  void getCurrentUser() async {
    currentUser = await ProfileFunction.getUserDetails(_auth.currentUser!.uid);
  }

  sendNotification(userId, title, body) async {
    title = profanityFilter.censor(title);
    body = profanityFilter.censor(body);
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

  final scrollController = ScrollController();

  void addComment() async {
    if (_ctrlComment.text.isNotEmpty) {
      //for reply in mobile layout
      _ctrlComment.text = profanityFilter.censor(_ctrlComment.text);
      if (respondType != null && respondType == "REPLY") {
        addReplyMobile();

        respondType = '';
        FocusManager.instance.primaryFocus?.unfocus();
        return;
      }

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
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      //send notification to the author of this post
      sendNotification(
        widget.postModel.authorId,
        '${currentUser!.username} commented on this post: ',
        widget.postModel.title,
      );
      widget.postModel.noOfComments += 1;
      widget.stateSetter!();
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

  void onUpVote(String? react) async {
    if (isUpvoted.isNotEmpty) {
      if (react == null) {
        setState(() {
          widget.postModel.noOfUpVotes -= 1;
          isUpvoted = "";
        });
        await MyPostFunction.onUpvoteAndUnUpvote(
            postId: widget.postModel.postId, isUpvoted: "", react: "");
      } else {
        setState(() {
          isUpvoted = react;
        });
        await MyPostFunction.onUpvoteAndUnUpvote(
          postId: widget.postModel.postId,
          isUpvoted: "re",
          react: react,
        );
      }
    } else {
      setState(() {
        widget.postModel.noOfUpVotes += 1;
        isUpvoted = react!;
      });
      await MyPostFunction.onUpvoteAndUnUpvote(
          postId: widget.postModel.postId,
          isUpvoted: "new",
          react: react ?? "");

      //send Notification to the author when upvoted
      sendNotification(
          widget.postModel.authorId,
          '${currentUser!.username} upvoted this post: ',
          widget.postModel.title);
    }
    widget.stateSetter!();
  }

  onTypeReply({
    required String recipientName,
    required String recipientId,
    required String response,
    required String commentId,
  }) {
    response = profanityFilter.censor(response);

    if (widget.deviceScreenType == DeviceScreenType.mobile) {
      _ctrlComment.text = widget.postModel.authorId == recipientId &&
              widget.postModel.asAnonymous
          ? 'Anonymous '
          : "$recipientName ";
      focusComment.requestFocus();
      respondType = response;
      cmntId = commentId;
      this.recipientId = recipientId;
      this.recipientName = recipientName;
    }
  }

  addReplyMobile() async {
    _ctrlComment.text = profanityFilter.censor(_ctrlComment.text);
    ReplyModel newReply = ReplyModel(
      replyId: DateTime.now().toIso8601String(),
      senderId: currentUser!.userId,
      senderName: widget.postModel.authorId == currentUser!.userId &&
              widget.postModel.asAnonymous
          ? 'Anonymous'
          : currentUser!.username,
      recipientId: recipientId!,
      recipientName: recipientName!,
      replyMessage: _ctrlComment.text,
    );
    //send notification to the recipient of this reply (from mobile)
    sendNotification(
      recipientId,
      widget.postModel.authorId == currentUser!.userId &&
              widget.postModel.asAnonymous
          ? 'Anonymous replied: '
          : '${currentUser!.username} replied: ',
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
        widget.stateSetter!();
        await PostInteractorsFunctions.onViewPost(
            widget.postModel.postId, true);
      }
    }
  }

  removePost() async {
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
    if (widget.stateSetter != null) {
      widget.stateSetter!();
    }
    successMessage(
        title: "Success!", desc: "Post was deleted!", context: context);
    await PostInteractorsFunctions.removePost(postModel: widget.postModel);
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool isEditing = false;
  updatePost() async {
    if (_contentController.text.isNotEmpty &&
        _titleController.text.isNotEmpty) {
      _contentController.text = profanityFilter.censor(_contentController.text);
      _titleController.text = profanityFilter.censor(_titleController.text);
      bool isSucceess = await PostInteractorsFunctions.updatePost(
        postId: widget.postModel.postId,
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
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
    if (widget.stateSetter != null) {
      widget.stateSetter!();
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
      _titleController.text = widget.postModel.title;
      _contentController.text = widget.postModel.content;
      setState(() {});
    } else {
      isLoggedIn = false;
      setState(() {});
    }
    timer();
    // getAllComments();
  }

  CarouselController carouselController = CarouselController();

  @override
  void dispose() {
    _ctrlComment.dispose();
    scrollController.dispose();
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
          "${widget.postModel.asAnonymous ? "Anonymous" : widget.postModel.authorName}'s Post",
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
          controller: scrollController,
          child: Stack(
            children: [
              SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    postDetails(context),
                    const SizedBox(
                      height: 10,
                    ),
                    isEditing
                        ? TextField(
                            controller: _titleController,
                            onSubmitted: (value) {
                              updatePost();
                            },
                            decoration: InputDecoration(
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _titleController.text =
                                            widget.postModel.title;
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
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        : Text(
                            widget.postModel.title,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                    isEditing
                        ? TextField(
                            controller: _contentController,
                            onSubmitted: (value) {
                              updatePost();
                            },
                            maxLines: 3,
                            decoration: InputDecoration(
                                suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _contentController.text =
                                          widget.postModel.content;
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
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                )
                              ],
                            )),
                          )
                        : Text(widget.postModel.content),
                    const SizedBox(
                      height: 10,
                    ),

                    //Image
                    if (widget.postModel.images.isNotEmpty)
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          CarouselSlider(
                            carouselController: carouselController,
                            options: CarouselOptions(
                              height: 400.0,
                              autoPlay: true,
                              enableInfiniteScroll: true,
                              viewportFraction: 1,
                            ),
                            items: widget.postModel.images.map((i) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return GestureDetector(
                                    onTap: () => Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (ctx) => PostPage(
                                        postModel: widget.postModel,
                                        deviceScreenType:
                                            widget.deviceScreenType,
                                      ),
                                    )),
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 5.0),
                                        child: Image.network(
                                          i,
                                          fit: BoxFit.cover,
                                        )),
                                  );
                                },
                              );
                            }).toList(),
                          ),
                          Positioned(
                            left: 5,
                            child: IconButton(
                              onPressed: () {
                                carouselController.previousPage();
                              },
                              constraints: const BoxConstraints(
                                minHeight: 400,
                              ),
                              style: IconButton.styleFrom(
                                  shape: const BeveledRectangleBorder()),
                              icon: const Icon(Icons.keyboard_arrow_left),
                            ),
                          ),
                          Positioned(
                            right: 5,
                            child: IconButton(
                              onPressed: () {
                                carouselController.nextPage();
                              },
                              style: IconButton.styleFrom(
                                  shape: const BeveledRectangleBorder()),
                              constraints: const BoxConstraints(
                                minHeight: 400,
                              ),
                              icon: const Icon(Icons.keyboard_arrow_right),
                            ),
                          ),
                        ],
                      ),

                    const Divider(),
                    isLoggedIn
                        ? postActions()
                        : Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Routes().navigate("Login", context);
                                  },
                                  child: const Text(
                                    "Login",
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ),
                                const Text(" First"),
                              ],
                            ),
                          ),
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
                              commentModels.sort(
                                  (a, b) => b.commentId.compareTo(a.commentId));
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
              if (currentUser != null &&
                  currentUser!.userId == widget.postModel.authorId)
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
        ),
      ),
    );
  }

  Row postActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ReactionButton<String>(
          isChecked: isUpvoted.isNotEmpty,
          selectedReaction: isUpvoted.isNotEmpty
              ? selectedReaction(context, isUpvoted)
              : null,
          toggle: true,
          onReactionChanged: (Reaction<String>? reaction) {
            onUpVote(reaction?.value);
          },
          reactions: <Reaction<String>>[
            Reaction(
              value: "Like",
              icon: Icon(
                Icons.thumb_up,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text("Like"),
            ),
            const Reaction(
              value: "Love",
              icon: Icon(
                Icons.favorite,
                color: Colors.red,
              ),
              title: Text("Love"),
            ),
            const Reaction(
              value: "Star",
              icon: Icon(
                Icons.star,
                color: Colors.amber,
              ),
              title: Text("Star"),
            ),
          ],
          placeholder: Reaction<String>(
            value: null,
            icon: Icon(
              Icons.arrow_upward,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          boxColor: Theme.of(context).colorScheme.onPrimary,
          boxRadius: 10,
          itemsSpacing: 20,
          itemSize: const Size(40, 60),
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
          backgroundImage: widget.postModel.profilePicture != "" &&
                  !widget.postModel.asAnonymous
              ? NetworkImage(widget.postModel.profilePicture)
              : const AssetImage(guestIcon) as ImageProvider,
        ),
        const SizedBox(
          width: 10,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.postModel.asAnonymous
                  ? "Anonymous"
                  : widget.postModel.authorName,
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
            : const AssetImage(guestIcon) as ImageProvider,
      ),
      title: Card(
        child: TextField(
          onChanged: (a) {
            setState(() {});
          },
          onSubmitted: (value) {
            if (widget.ctrlComment.text.isNotEmpty) {
              widget.addComment();
              widget.ctrlComment.clear();
            }
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
