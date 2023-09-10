import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:neighboard/models/comment_model.dart';
import 'package:neighboard/models/post_model.dart';
import 'package:neighboard/models/reply_model.dart';
import 'package:neighboard/models/user_model.dart';
import 'package:neighboard/src/user_side/forum_page/ui/comments/comment_function.dart';
import 'package:neighboard/widgets/others/post_content_text.dart';

class PostModalComment extends StatefulWidget {
  const PostModalComment({
    super.key,
    this.currentUser,
    required this.commentModel,
    required this.postModel,
    required this.isLoggedIn,
  });

  final UserModel? currentUser;
  final PostModel postModel;
  final CommentModel commentModel;
  final bool isLoggedIn;

  @override
  State<PostModalComment> createState() => _PostModalCommentState();
}

class _PostModalCommentState extends State<PostModalComment> {
  List<ReplyModel> replyModels = [];
  bool isLoading = true;
  bool isRepliesShown = false;
  bool isLiked = false;
  bool isDisliked = false;

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
            isLiked: true);
      }
    }
    if (type == 'dislike') {
      if (isLiked) {
        widget.commentModel.noOfLikes -= 1;
        isLiked = false;
        await CommentFunction.onLikeAndUnlike(
            postId: widget.postModel.postId,
            commentId: widget.commentModel.commentId,
            isLiked: false);
      }
      if (isDisliked) {
        setState(() {
          widget.commentModel.noOfDislikes -= 1;
          isDisliked = false;
        });
        await CommentFunction.onDislikeAndUnDislike(
            postId: widget.postModel.postId,
            commentId: widget.commentModel.commentId,
            isDisliked: false);
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
      }
    }
  }

  void showAllReplies() {
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
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    await CommentFunction.postReply(
      postId: widget.postModel.postId,
      commentId: widget.commentModel.commentId,
      replyModel: reply,
    );
    replyModels.add(reply);
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllReplies(widget.commentModel);
    checkIfLikedOrDisliked();
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
              backgroundImage: NetworkImage(
                widget.commentModel.senderProfilePicture,
              ),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.commentModel.senderName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.commentModel.timeStamp,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
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
                                      : const Icon(Icons.thumb_up_outlined),
                                  likeCount: widget.commentModel.noOfLikes,
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
                                      : const Icon(Icons.thumb_down_outlined),
                                  likeCount: widget.commentModel.noOfDislikes,
                                ),
                                const Spacer(),
                                TextButton.icon(
                                  onPressed: () {
                                    //TODO: open close all replies,

                                    showAllReplies();
                                  },
                                  icon: const Icon(Icons.reply),
                                  label: const Text("Reply"),
                                )
                              ],
                            ),
                    ],
                  ),
                ),
              ),
              isRepliesShown
                  ? Column(
                      children: [
                        ReplyTextBox(
                          currentUser: widget.currentUser!,
                          recipientName: widget.commentModel.senderName,
                          recipientId: widget.commentModel.senderId,
                          addReply: addReplyCallback,
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

  ListView commentReplies() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: replyModels.length,
      itemBuilder: (context, index) {
        ReplyModel reply = replyModels[index];
        return ReplyItself(
          replyModel: reply,
          currentUser: widget.currentUser!,
          isLoggedIn: widget.isLoggedIn,
          addReply: addReplyCallback,
        );
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
  });

  final ReplyModel replyModel;
  final UserModel currentUser;
  final bool isLoggedIn;
  final Function({required ReplyModel reply}) addReply;

  @override
  State<ReplyItself> createState() => _ReplyItselfState();
}

class _ReplyItselfState extends State<ReplyItself> {
  bool isReplyBoxShown = false;

  void showReplyBox() {
    setState(() {
      isReplyBoxShown = !isReplyBoxShown;
    });
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PostContentText(
                  content: widget.replyModel.replyMessage,
                  textOverflow: TextOverflow.visible,
                ),
                const Divider(),
                !widget.isLoggedIn
                    ? Container()
                    : Row(
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
                              showReplyBox();
                            },
                            icon: const Icon(Icons.reply_outlined),
                            label: const Text('Reply'),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
        widget.isLoggedIn
            ? isReplyBoxShown
                ? ReplyTextBox(
                    currentUser: widget.currentUser,
                    recipientName: widget.replyModel.senderName,
                    recipientId: widget.replyModel.senderId,
                    addReply: widget.addReply,
                  )
                : Container()
            : Container(),
      ],
    );
  }
}

class ReplyTextBox extends StatelessWidget {
  const ReplyTextBox({
    super.key,
    required this.currentUser,
    required this.recipientName,
    required this.recipientId,
    required this.addReply,
  });
  final String recipientName, recipientId;
  final UserModel currentUser;
  final Function({required ReplyModel reply}) addReply;

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    controller.text = "$recipientName ";
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(
            currentUser.profilePicture,
          ),
        ),
        Expanded(
          child: Card(
            child: TextField(
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
          onPressed: () {
            ReplyModel newReply = ReplyModel(
              replyId: DateTime.now().toIso8601String(),
              senderId: currentUser.userId,
              senderName: currentUser.username,
              recipientId: recipientId,
              recipientName: recipientName,
              replyMessage: controller.text,
            );
            addReply(reply: newReply);
            controller.clear();
          },
          icon: const Icon(Icons.send),
        ),
      ],
    );
  }
}
