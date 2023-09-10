import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:neighboard/data/posts_data.dart';
import 'package:neighboard/models/comment_model.dart';
import 'package:neighboard/models/post_model.dart';
import 'package:neighboard/models/user_model.dart';
import 'package:neighboard/src/loading_screen/loading_screen.dart';
import 'package:neighboard/src/profile_screen/profile_screen_function.dart';
import 'package:neighboard/src/user_side/forum_page/ui/comments/comment_function.dart';
import 'package:neighboard/src/user_side/forum_page/ui/my_posts/my_post_function.dart';
import 'package:neighboard/widgets/post/post_modal_comment.dart';

class PostModal extends StatefulWidget {
  const PostModal({super.key, required this.postModel});

  final PostModel postModel;

  @override
  State<PostModal> createState() => _PostModalState();
}

class _PostModalState extends State<PostModal> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FocusNode focusComment = FocusNode();
  final TextEditingController _ctrlComment = TextEditingController();
  List<CommentModel> commentModels = [];
  UserModel? currentUser;
  bool isUpvoted = false;
  bool isLoading = true;
  bool isLoggedIn = false;

  void getCurrentUser() async {
    currentUser = await ProfileFunction.getUserDetails(_auth.currentUser!.uid);
  }

  void addComment() async {
    if (_ctrlComment.text.isNotEmpty) {
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
      commentModels.add(commentModel);
      commentModels.sort((a, b) => b.commentId.compareTo(a.commentId));
      _ctrlComment.clear();
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      return;
    }
  }

  Future<void> getAllComments() async {
    commentModels =
        await CommentFunction.getAllComments(postId: widget.postModel.postId) ??
            [];
    commentModels.sort((a, b) => b.commentId.compareTo(a.commentId));
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
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
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (_auth.currentUser != null) {
      getCurrentUser();
      isLoggedIn = true;
      checkIfUpVoted();
      setState(() {});
    } else {
      isLoggedIn = false;
      setState(() {});
    }
    getAllComments();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _ctrlComment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 4,
      child: SizedBox(
        width: 720,
        child: isLoading
            ? const LoadingScreen()
            : Scaffold(
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
                    ? ListTile(
                        leading: CircleAvatar(
                          backgroundImage: currentUser!.profilePicture != ""
                              ? NetworkImage(currentUser!.profilePicture)
                              : null,
                        ),
                        title: Card(
                          child: TextField(
                            controller: _ctrlComment,
                            focusNode: focusComment,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: "Write a public comment...",
                            ),
                          ),
                        ),
                        trailing: IconButton(
                          onPressed: () {
                            addComment();
                          },
                          icon: const Icon(Icons.send_outlined),
                        ),
                      )
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
                        postComments(),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  ListView postComments() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: commentModels.length,
      itemBuilder: (context, index) {
        CommentModel comment = commentModels[index];
        return PostModalComment(
          currentUser: currentUser,
          postModel: widget.postModel,
          commentModel: comment,
          isLoggedIn: isLoggedIn,
        );
      },
    );
  }

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
