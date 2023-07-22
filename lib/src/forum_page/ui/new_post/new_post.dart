import 'dart:typed_data';

import 'package:english_words/english_words.dart';
import 'package:file_picker/file_picker.dart';
//import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/data/posts_data.dart';
import 'package:neighboard/models/post_model.dart';
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
  Uint8List? _imageBytes;

  final TextEditingController _cTitlePost = TextEditingController();
  final TextEditingController _cContentPost = TextEditingController();

  void _publishPost() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      addPostData(PostModel(
        postId: generateRandomId(8),
        authorId: generateRandomId(8),
        authorName: WordPair.random().asPascalCase,
        profilePicture: homeImage,
        timeStamp: formattedDate,
        title: _postTitle,
        content: _postContent,
        noOfViews: 0,
        comments: [],
        noOfUpVotes: 0,
        isUpVoted: false,
        tags: [
          _category!,
        ],
      ));
      setState(() {
        _cTitlePost.clear();
        _cContentPost.clear();
        _category = null;
        _imageBytes = null;
        showAlertDialog(context, 'Success!', 'Post have been published!');
      });
    }
  }

  void _draftPost() {}

  Future<void> _getImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null) {
      _imageBytes = result.files.first.bytes!;
      setState(() {});
    } else {
      //No image selected
    }
  }
  // if (_imageBytes != null) // Display the image if it has been uploaded
  // Image.memory(_imageBytes!), //Place it inside the widget tree

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                DropdownButtonFormField(
                  decoration:
                      const InputDecoration(border: OutlineInputBorder()),
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
                Expanded(
                  child: TextFormField(
                    controller: _cContentPost,
                    onSaved: (value) => _postContent = value!,
                    decoration: const InputDecoration(
                      labelText: "Enter Post Content",
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    validator: (value) {
                      if (value?.trim() == '') {
                        return 'Please enter content';
                      }
                      return null;
                    },
                  ),
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
    );
  }
}
