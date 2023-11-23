import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neighboard/main.dart';
import 'package:neighboard/models/post_model.dart';
import 'package:neighboard/src/loading_screen/loading_posts.dart';
import 'package:neighboard/src/user_side/forum_page/ui/anonymous_posts/anonymous_function.dart';
import 'package:neighboard/widgets/notification/mini_notif/elegant_notif.dart';
import 'package:neighboard/widgets/others/author_name_text.dart';
import 'package:neighboard/widgets/others/post_content_text.dart';
import 'package:neighboard/widgets/others/post_time_text.dart';
import 'package:neighboard/widgets/others/post_title_text.dart';
import 'package:neighboard/widgets/others/small_profile_pic.dart';
import 'package:neighboard/widgets/page_messages/page_messages.dart';
import 'package:neighboard/widgets/post/post_interactors.dart';
import 'package:neighboard/widgets/post/post_interactors_function.dart';
import 'package:neighboard/widgets/post/post_modal.dart';
import 'package:responsive_builder/responsive_builder.dart';

class AnonymousPosts extends StatefulWidget {
  const AnonymousPosts({
    super.key,
    required this.isAdmin,
    required this.deviceScreenType,
    required this.searchedText,
  });

  final String searchedText;
  final bool isAdmin;
  final DeviceScreenType deviceScreenType;

  @override
  State<AnonymousPosts> createState() => _AnonymousPostsState();
}

class _AnonymousPostsState extends State<AnonymousPosts> {
  List<PostModel> postModels = [];
  bool isLoading = false;

  getAllAnonymousPosts() async {
    setState(() {
      isLoading = true;
    });
    postModels = await AnonymousFunction.getAllAnonymousPosts() ?? [];
    postModels.sort((a, b) => b.postId.compareTo(a.postId));
    postModels.sort((a, b) => b.noOfUpVotes.compareTo(a.noOfUpVotes));
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  getSearchedPost() async {
    setState(() {
      isLoading = true;
    });
    postModels = await AnonymousFunction.getPostsBySearch(
            searchedWord: widget.searchedText.trim()) ??
        [];

    postModels.sort((a, b) => widget.searchedText.trim().compareTo(a.title));
    postModels.sort((a, b) => b.noOfUpVotes.compareTo(a.noOfUpVotes));
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
    getAllAnonymousPosts();
  }

  @override
  void didUpdateWidget(covariant AnonymousPosts oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (widget.searchedText.isNotEmpty || widget.searchedText != "") {
      getSearchedPost();
    } else {
      getAllAnonymousPosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const LoadingPosts()
        : postModels.isEmpty
            ? noPostMessage()
            : ListView.builder(
                shrinkWrap: true,
                itemCount: postModels.length,
                itemBuilder: (context, index) {
                  PostModel post = postModels[index];
                  return Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 0.w, vertical: 5.h),
                    child: SinglePost(
                      post: post,
                      isAdmin: widget.isAdmin,
                      deviceScreenType: widget.deviceScreenType,
                      stateSetter: getAllAnonymousPosts,
                    ),
                  );
                },
              );
  }
}

class SinglePost extends StatefulWidget {
  const SinglePost({
    super.key,
    required this.post,
    required this.isAdmin,
    required this.deviceScreenType,
    required this.stateSetter,
  });
  final DeviceScreenType deviceScreenType;
  final PostModel post;
  final bool isAdmin;
  final Function stateSetter;

  @override
  State<SinglePost> createState() => _SinglePostState();
}

class _SinglePostState extends State<SinglePost> {
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
        postTitle: profanityFilter.censor(_titleController.text),
        postContent: profanityFilter.censor(_contentController.text),
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
    widget.stateSetter();
  }

  //picture
  int noOfPics = 0;
  int extraPics = 0;

  @override
  void initState() {
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
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () {
          widget.deviceScreenType != DeviceScreenType.mobile
              ? showDialog(
                  context: context,
                  builder: (BuildContext context) => Dialog(
                      child: PostModal(
                    postModel: widget.post,
                    deviceScreenType: widget.deviceScreenType,
                    stateSetter: () {
                      setState(() {});
                    },
                  )),
                )
              : showModalBottomSheet(
                  useSafeArea: true,
                  useRootNavigator: true,
                  isScrollControlled: true,
                  context: context,
                  builder: (context) => PostModal(
                    postModel: widget.post,
                    deviceScreenType: widget.deviceScreenType,
                    stateSetter: () {
                      setState(() {});
                    },
                  ),
                );
        },
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
                                  : widget.post.authorName,
                            ),
                            PostTimeText(time: widget.post.timeStamp)
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
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          )
                        ],
                      )),
                    )
                  : PostTitleText(title: widget.post.title),
              const SizedBox(
                height: 5,
              ),
              isEditing
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
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          )
                        ],
                      )),
                    )
                  : PostContentText(
                      content: widget.post.content,
                      maxLine: 1,
                      textOverflow: TextOverflow.ellipsis,
                    ),
              const SizedBox(
                height: 10,
              ),
              //TODO: PIC
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
                          columnSpan:
                              i == noOfPics - 1 && noOfPics == 1 ? 2 : 1,
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
                                                size: 30,
                                                weight: 30,
                                                color: Colors.white,
                                              ),
                                              Text(
                                                extraPics.toString(),
                                                style: const TextStyle(
                                                    fontSize: 30,
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
              ActionBarPosts(
                post: widget.post,
                isAdmin: widget.isAdmin,
                deviceScreenType: widget.deviceScreenType,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ActionBarPosts extends StatefulWidget {
  const ActionBarPosts({
    super.key,
    required this.post,
    required this.isAdmin,
    required this.deviceScreenType,
  });

  final PostModel post;
  final bool isAdmin;
  final DeviceScreenType deviceScreenType;

  @override
  State<ActionBarPosts> createState() => _ActionBarPostsState();
}

class _ActionBarPostsState extends State<ActionBarPosts> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          onPressed: () {
            widget.deviceScreenType == DeviceScreenType.mobile
                ? showModalBottomSheet(
                    isScrollControlled: true,
                    useSafeArea: true,
                    context: context,
                    builder: (BuildContext context) => PostInteractors(
                      postModel: widget.post,
                      collection: "views",
                    ),
                  )
                : showDialog(
                    context: context,
                    builder: (BuildContext context) => Dialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                      elevation: 4,
                      child: PostInteractors(
                        postModel: widget.post,
                        collection: "views",
                      ),
                    ),
                  );
          },
          icon: const Icon(Icons.remove_red_eye_outlined),
        ),
        Text('${widget.post.noOfViews}'),
        const SizedBox(
          width: 20,
        ),
        AbsorbPointer(
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.mode_comment_outlined),
          ),
        ),
        Text('${widget.post.noOfComments}'),
        const SizedBox(
          width: 20,
        ),
        IconButton(
          onPressed: () {
            widget.deviceScreenType == DeviceScreenType.mobile
                ? showModalBottomSheet(
                    isScrollControlled: true,
                    useSafeArea: true,
                    context: context,
                    builder: (BuildContext context) => PostInteractors(
                      postModel: widget.post,
                      collection: "upvotes",
                    ),
                  )
                : showDialog(
                    context: context,
                    builder: (BuildContext context) => Dialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                      elevation: 4,
                      child: PostInteractors(
                        postModel: widget.post,
                        collection: "upvotes",
                      ),
                    ),
                  );
          },
          icon: const Icon(Icons.arrow_upward),
        ),
        Text('${widget.post.noOfUpVotes}'),
        const SizedBox(
          width: 20,
        ),
      ],
    );
  }
}
