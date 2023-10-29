import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/data/posts_data.dart';
import 'package:neighboard/models/post_model.dart';
import 'package:neighboard/models/user_model.dart';
import 'package:neighboard/src/loading_screen/loading_screen.dart';
import 'package:neighboard/src/user_side/forum_page/ui/forum_page/forum_page.dart';
import 'package:neighboard/src/user_side/forum_page/ui/new_post/new_post_function.dart';
import 'package:neighboard/src/user_side/login_register_page/login_page/login_page_ui.dart';
import 'package:neighboard/src/profile_screen/profile_screen_function.dart';
import 'package:neighboard/widgets/notification/mini_notif/elegant_notif.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:universal_io/io.dart';

class NewPost extends StatefulWidget {
  const NewPost({Key? key, required this.deviceScreenType}) : super(key: key);
  final DeviceScreenType deviceScreenType;

  @override
  State<NewPost> createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  final _formKey = GlobalKey<FormState>();
  String? _category;
  String _postTitle = '';
  String _postContent = '';

  final TextEditingController _cTitlePost = TextEditingController();
  final TextEditingController _cContentPost = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = false;
  bool isLoggedIn = false;

  List<File> images = [];
  List<PlatformFile> imageBytes = [];
  List<String> imageUrls = [];

  UserModel? userModel;
  @override
  void initState() {
    super.initState();
    if (_auth.currentUser != null) {
      isLoggedIn = true;
      getCurrentUserDetails();
    }
  }

  void getCurrentUserDetails() async {
    try {
      userModel = await ProfileFunction.getUserDetails(_auth.currentUser!.uid);
    } catch (e) {
      return;
    }
    setState(() {});
  }

  void _publishPost() async {
    if (_formKey.currentState!.validate() && userModel != null) {
      setState(() {
        isLoading = true;
      });
      _formKey.currentState!.save();
      await onSavingPic();
      PostModel postModel = PostModel(
        postId: DateTime.now().toIso8601String(),
        authorId: userModel!.userId,
        authorName: userModel!.username,
        profilePicture: userModel!.profilePicture,
        timeStamp: formattedDate(),
        title: _postTitle,
        content: _postContent,
        noOfComments: 0,
        noOfViews: 0,
        noOfUpVotes: 0,
        tags: [
          _category!,
        ],
        images: imageUrls,
      );
      bool isPostPublished = await NewPostFunction.createNewPost(postModel);

      if (isPostPublished) {
        // ignore: use_build_context_synchronously
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const ForumPage(),
            ),
            (route) => false);

        _discardPost();
        // ignore: use_build_context_synchronously
        successMessage(
            title: "Success!",
            desc:
                'Post have been published!\nJust wait for the admin to approve your post.',
            context: context);
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  void _discardPost() {
    setState(() {
      _cTitlePost.clear();
      _cContentPost.clear();
      _category = null;
      imageBytes.clear();
      imageUrls.clear();
      images.clear();
    });
  }

  Future _getImage() async {
    if (kIsWeb) {
      final pickedImages = await FilePicker.platform
          .pickFiles(allowMultiple: true, type: FileType.image);

      if (pickedImages != null) {
        imageBytes = pickedImages.files;
      }
    } else {
      final pickedImages = await ImagePicker().pickMultiImage();

      if (pickedImages.isNotEmpty) {
        images = pickedImages.map((e) => File(e.path)).toList();
      }
    }

    setState(() {});
  }

  onSavingPic() async {
    if (images.isNotEmpty || imageBytes.isNotEmpty) {
      imageUrls = kIsWeb
          ? await NewPostFunction.uploadMultipleImageWeb(imageBytes) ?? []
          : await NewPostFunction.uploadMultipleImage(images) ?? [];
    }
  }

  bool isMobilePlatform() {
    return widget.deviceScreenType == DeviceScreenType.mobile;
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const LoadingScreen()
        : !isLoggedIn
            ? Center(
                child: Column(
                  children: [
                    Image.asset(
                      loginFirstImg,
                      height: 300,
                      width: 300,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginPage()));
                          },
                          child: const Text(
                            "Login ",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                        const Text("First"),
                      ],
                    ),
                  ],
                ),
              )
            : Center(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    child: Card(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 15.h),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              DropdownButtonFormField(
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder()),
                                value: _category,
                                hint: const Text('Choose categories *'),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _category = newValue;
                                  });
                                },
                                items: [
                                  'General Discussion',
                                  'Garbage Collection',
                                  'Parking Space',
                                  'Water Billing',
                                  'Electric Billing',
                                  'Power Interruption',
                                  'Clubhouse Fees and Rental',
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select a category';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(
                                height: 5.h,
                              ),
                              TextFormField(
                                controller: _cTitlePost,
                                onSaved: (value) => _postTitle = value!,
                                decoration: const InputDecoration(
                                  labelText: "Enter Post Title",
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value?.trim() == '') {
                                    return 'Please enter title';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(
                                height: 5.h,
                              ),
                              TextFormField(
                                controller: _cContentPost,
                                onSaved: (value) => _postContent = value!,
                                decoration: const InputDecoration(
                                  labelText: "Enter Post Content",
                                  border: OutlineInputBorder(),
                                  alignLabelWithHint: true,
                                ),
                                keyboardType: TextInputType.multiline,
                                expands: false,
                                maxLines: 10,
                                textAlignVertical: TextAlignVertical.top,
                                validator: (value) {
                                  if (value?.trim() == '') {
                                    return 'Please enter content';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(
                                height: 5.h,
                              ),
                              isMobilePlatform()
                                  ? Row(
                                      children: [
                                        IconButton(
                                          onPressed: _getImage,
                                          icon: const Icon(Icons.image),
                                          tooltip: "Add Image",
                                        ),
                                        SizedBox(
                                          width: 2.w,
                                        ),
                                        IconButton(
                                          onPressed: _discardPost,
                                          icon:
                                              const Icon(Icons.delete_outline),
                                          tooltip: "Discard Post",
                                        ),
                                        const Spacer(),
                                        IconButton(
                                          onPressed: _publishPost,
                                          icon: const Icon(Icons.send),
                                          tooltip: "Publish",
                                        ),
                                      ],
                                    )
                                  : Row(
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: _getImage,
                                          style: ElevatedButton.styleFrom(
                                            shape:
                                                const BeveledRectangleBorder(),
                                            backgroundColor: Colors.indigo[800],
                                            foregroundColor: Colors.white,
                                          ),
                                          icon: const Icon(Icons.image),
                                          label: const Text('Add Image'),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Text(
                                            images.isNotEmpty ||
                                                    imageBytes.isNotEmpty
                                                ? kIsWeb
                                                    ? "${imageBytes.map((e) => e.name)}"
                                                    : "${images.map((e) => e.path)}"
                                                : "",
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        ElevatedButton.icon(
                                          onPressed: _discardPost,
                                          style: ElevatedButton.styleFrom(
                                            shape:
                                                const BeveledRectangleBorder(),
                                            backgroundColor: Colors.red[900],
                                            foregroundColor: Colors.white,
                                          ),
                                          icon:
                                              const Icon(Icons.delete_outline),
                                          label: const Text('Discard'),
                                        ),
                                        SizedBox(
                                          width: 2.w,
                                        ),
                                        ElevatedButton.icon(
                                          onPressed: _publishPost,
                                          style: ElevatedButton.styleFrom(
                                            shape:
                                                const BeveledRectangleBorder(),
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            foregroundColor: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                          ),
                                          icon: const Icon(Icons.send),
                                          label: const Text('Publish'),
                                        ),
                                      ],
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
  }
}
