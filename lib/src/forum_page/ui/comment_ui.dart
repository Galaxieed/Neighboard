import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/data/posts_data.dart';
import 'package:neighboard/models/comment_model.dart';
import 'package:neighboard/models/post_model.dart';
import 'package:neighboard/models/reply_model.dart';
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

  addReplyCallback({required ReplyModel reply}) {
    setState(() {
      addReplyData(widget.post, widget.comment.commentId, reply);
    });
  }

  likeDislikeAction({required String type}) {
    setState(() {
      if (type == 'like') {
        triggerLikeComment(widget.post, widget.comment.commentId);
      }
      if (type == 'dislike') {
        triggerDislikeComment(widget.post, widget.comment.commentId);
      }
    });
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
                      SmallProfilePic(profilePic: homeImage),
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
                    noOfLikes: widget.comment.noOfLikes,
                    isLiked: widget.comment.isLiked,
                    noOfDislikes: widget.comment.noOfDislikes,
                    isDisliked: widget.comment.isDisliked,
                    replies: widget.comment.replies,
                    setRepliesVisible: setRepliesVisible,
                    setReplyBoxVisible: setReplyBoxVisible,
                    isRepliesVisible: isRepliesVisible,
                    isReplyBoxVisible: isReplyBoxVisible,
                    likeDislikeAction: likeDislikeAction,
                  ),
                ],
              ),
            ),
          ),
        ),
        RepliesContainer(
          // recipientId: widget.comment.recipientId,
          comment: widget.comment,
          setRepliesVisible: setRepliesVisible,
          isRepliesVisible: isRepliesVisible,
          isReplyBoxVisible: isReplyBoxVisible,
          setReplyBoxVisible: setReplyBoxVisible,
          addReply: addReplyCallback, //Yung addReply ayusin
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
  RepliesContainer({
    super.key,
    required this.comment,
    required this.setRepliesVisible,
    required this.setReplyBoxVisible,
    required this.isReplyBoxVisible,
    required this.isRepliesVisible,
    required this.addReply,
    // required this.recipientId,
  });

  bool isRepliesVisible, isReplyBoxVisible;
  final Function setRepliesVisible, setReplyBoxVisible, addReply;
  final CommentModel comment;
  // final int recipientId;

  @override
  State<RepliesContainer> createState() => _RepliesContainerState();
}

class _RepliesContainerState extends State<RepliesContainer> {
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.isRepliesVisible,
      child: Column(
        children: [
          ReplyTextField(
            visibility: widget.isReplyBoxVisible,
            addReply: widget.addReply,
            setVisibility: widget.setReplyBoxVisible,
            recipientId: widget.comment.senderId,
            recipientName: widget.comment.senderName,
          ),
          for (ReplyModel singleReply in widget.comment.replies)
            SingleReplyUI(
              replyModel: singleReply,
              addReply: widget.addReply,
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
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.visibility,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: replyController,
              autofocus: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter Reply..',
                alignLabelWithHint: true,
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          IconButton(
            onPressed: () {
              final ReplyModel thisReply = ReplyModel(
                  replyId: generateRandomId(8),
                  senderId: generateRandomId(8),
                  senderName: WordPair.random().asPascalCase,
                  recipientId: widget.recipientId,
                  recipientName: widget.recipientName,
                  replyMessage: replyController.text,
                  replies: []);
              widget.addReply(reply: thisReply);
              replyController.clear();
              widget.setVisibility!(false);
            },
            icon: const Icon(Icons.send),
          )
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class ActionBarComment extends StatelessWidget {
  ActionBarComment({
    super.key,
    required this.noOfLikes,
    required this.noOfDislikes,
    this.replies,
    required this.isLiked,
    required this.isDisliked,
    required this.setRepliesVisible,
    required this.isReplyBoxVisible,
    required this.isRepliesVisible,
    required this.setReplyBoxVisible,
    required this.likeDislikeAction,
  });

  bool isRepliesVisible, isReplyBoxVisible;
  final Function setRepliesVisible, setReplyBoxVisible, likeDislikeAction;
  bool isLiked;
  bool isDisliked;
  int noOfLikes;
  int noOfDislikes;
  List? replies = [];

  @override
  Widget build(BuildContext context) {
    return Row(
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
          likeCount: noOfLikes,
        ),
        const SizedBox(
          width: 20,
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
          likeCount: noOfDislikes,
        ),
        const Expanded(
            child: SizedBox(
          width: 10,
        )),
        isRepliesVisible
            ? TextButton.icon(
                onPressed: () {
                  setReplyBoxVisible(false);
                  setRepliesVisible(false);
                },
                icon: const Icon(Icons.expand_less_rounded),
                label: Text('Hide All Replies (${replies!.length})'),
              )
            : Container(),
        const SizedBox(
          width: 20,
        ),
        TextButton.icon(
          onPressed: () {
            setRepliesVisible(true);
            setReplyBoxVisible(true);
          },
          icon: const Icon(Icons.reply_outlined),
          label: const Text('Reply'),
        ),
      ],
    );
  }
}
