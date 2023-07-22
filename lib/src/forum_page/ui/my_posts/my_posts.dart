import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:neighboard/data/posts_data.dart';
import 'package:neighboard/models/comment_model.dart';
import 'package:neighboard/models/post_model.dart';
import 'package:neighboard/src/forum_page/ui/comment_ui.dart';
import 'package:neighboard/widgets/others/author_name_text.dart';
import 'package:neighboard/widgets/others/post_content_text.dart';
import 'package:neighboard/widgets/others/post_tag_chip.dart';
import 'package:neighboard/widgets/others/post_time_text.dart';
import 'package:neighboard/widgets/others/post_title_text.dart';
import 'package:neighboard/widgets/others/small_profile_pic.dart';

class MyPosts extends StatelessWidget {
  const MyPosts({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          PostModel post = posts[index];
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
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

  clearComment() {
    setState(() {
      _comment.clear();
    });
  }

  addCommentFunc({required CommentModel commentModel}) {
    setState(() {
      addCommentData(widget.post, commentModel);
      _comment.clear();
    });
  }

  upVoteFunc({required PostModel post, required String postId}){
    setState(() {
      triggerUpVote(post, postId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList(
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
            return SingleMyPost(post: widget.post, upVote: upVoteFunc,);
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
                  addComment: addCommentFunc,
                  clearComment: clearComment),
              const SizedBox(
                height: 10,
              ),
              for (CommentModel comment in widget.post.comments)
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
                    final CommentModel thisComment = CommentModel(
                        commentId: generateRandomId(8),
                        senderId: generateRandomId(8),
                        senderName: WordPair.random().asPascalCase,
                        timeStamp: formattedDate,
                        commentMessage: _comment.text,
                        noOfLikes: 0,
                        isLiked: false,
                        noOfDislikes: 0,
                        isDisliked: false,
                        replies: []);
                    addComment(commentModel: thisComment);
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
  });

  final Function upVote;
  final PostModel post;

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
            ActionBarMyPost(post: post, upVote: upVote,),
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
  });

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
          onPressed: (){
            upVote(post: post, postId: post.postId);
          },
          icon: const Icon(Icons.arrow_upward_rounded),
          label: Text(post.isUpVoted ? 'Voted' : 'Vote'),
          style: ElevatedButton.styleFrom(
            backgroundColor: post.isUpVoted ? Theme.of(context).disabledColor : Theme.of(context).primaryColor,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
        )
      ],
    );
  }
}
