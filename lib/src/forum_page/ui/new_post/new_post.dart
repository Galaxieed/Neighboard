import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:neighboard/data/posts_data.dart';
import 'package:neighboard/models/post_model.dart';
import 'package:neighboard/models/user_model.dart';
import 'package:neighboard/src/forum_page/ui/forum_page.dart';
import 'package:neighboard/src/forum_page/ui/new_post/new_post_function.dart';
import 'package:neighboard/src/login_register_page/login_page/login_page_ui.dart';
import 'package:neighboard/src/profile_screen/profile_screen_function.dart';
import 'package:neighboard/widgets/others/alert_dialog.dart';

class NewPost extends StatefulWidget {
  const NewPost({Key? key}) : super(key: key);

  @override
  State<NewPost> createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  final _formKey = GlobalKey<FormState>();
  //final _picker = ImagePicker();
  String? _category;
  String _postTitle = '';
  String _postContent = '';

  final TextEditingController _cTitlePost = TextEditingController();
  final TextEditingController _cContentPost = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = false;
  bool isLoggedIn = false;

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
      userModel = await ProfileFunction.getUserDetails();
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
      PostModel postModel = PostModel(
        postId: DateTime.now().toIso8601String(),
        authorId: userModel!.userId,
        authorName: userModel!.username,
        profilePicture: userModel!.profilePicture,
        timeStamp: formattedDate,
        title: _postTitle,
        content: _postContent,
        noOfComments: 0,
        noOfViews: 0,
        noOfUpVotes: 0,
        tags: [
          _category!,
        ],
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
      }
      setState(() {
        _cTitlePost.clear();
        _cContentPost.clear();
        _category = null;
        showAlertDialog(context, 'Success!', 'Post have been published!');
        isLoading = false;
      });
    }
  }

  void _draftPost() {}

  Future<void> _getImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null) {
      setState(() {});
    } else {
      //No image selected
    }
  }
  // if (_imageBytes != null) // Display the image if it has been uploaded
  // Image.memory(_imageBytes!), //Place it inside the widget tree

  @override
  Widget build(BuildContext context) {
    return !isLoggedIn
        ? Center(
            child: Row(
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
          )
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 0),
            child: SingleChildScrollView(
              child: Card(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
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
                            'Category1',
                            'Category2',
                            'Category3',
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
                        const SizedBox(
                          height: 10,
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
                        const SizedBox(
                          height: 10,
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
                          maxLines: 16,
                          textAlignVertical: TextAlignVertical.top,
                          validator: (value) {
                            if (value?.trim() == '') {
                              return 'Please enter content';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _getImage,
                              style: ElevatedButton.styleFrom(
                                shape: const BeveledRectangleBorder(),
                              ),
                              icon: const Icon(Icons.image),
                              label: const Text('Add Image'),
                            ),
                            const Spacer(),
                            ElevatedButton.icon(
                              onPressed: _draftPost,
                              style: ElevatedButton.styleFrom(
                                shape: const BeveledRectangleBorder(),
                              ),
                              icon: const Icon(Icons.drafts),
                              label: const Text('Save as Draft'),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            ElevatedButton.icon(
                              onPressed: _publishPost,
                              style: ElevatedButton.styleFrom(
                                shape: const BeveledRectangleBorder(),
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
          );
  }
}
