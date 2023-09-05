import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:neighboard/models/comment_model.dart';
import 'package:neighboard/models/post_model.dart';
import 'package:neighboard/models/reply_model.dart';
import 'package:neighboard/models/user_model.dart';
import 'package:neighboard/src/user_side/forum_page/ui/comments/comment_function.dart';
import 'package:neighboard/src/profile_screen/profile_screen_function.dart';
import 'package:neighboard/widgets/others/author_name_text.dart';
import 'package:neighboard/widgets/others/post_content_text.dart';
import 'package:neighboard/widgets/others/post_time_text.dart';
import 'package:neighboard/widgets/others/small_profile_pic.dart';

class CommentUI extends StatefulWidget {
  const CommentUI({Key? key, required this.post, required this.comment})
      : super(key: key);

  final PostModel post;
  final CommentModel comment;

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

  @override
  void initState() {
    super.initState();
    checkIfLikedOrDisliked();
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
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.more_vert),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  PostContentText(
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
  });

  final bool isRepliesVisible, isReplyBoxVisible;
  final Function setRepliesVisible, setReplyBoxVisible;
  final CommentModel comment;
  final PostModel post;

  @override
  State<RepliesContainer> createState() => _RepliesContainerState();
}

class _RepliesContainerState extends State<RepliesContainer> {
  List<ReplyModel> replyModel = [];
  bool isLoading = true;

  void getAllReplies() async {
    replyModel = await CommentFunction.getAllReplies(
            postId: widget.post.postId, commentId: widget.comment.commentId) ??
        [];
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  addReplyCallback({required ReplyModel reply}) async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    await CommentFunction.postReply(
      postId: widget.post.postId,
      commentId: widget.comment.commentId,
      replyModel: reply,
    );
    replyModel.add(reply);
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getAllReplies();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Visibility(
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
                for (ReplyModel singleReply in replyModel)
                  SingleReplyUI(
                    replyModel: singleReply,
                    addReply: addReplyCallback,
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
  });

  final Function addReply;
  final ReplyModel replyModel;

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PostContentText(
                    content:
                        '${widget.replyModel.recipientName}, ${widget.replyModel.replyMessage}',
                    textOverflow: TextOverflow.visible,
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
