import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:neighboard/models/post_model.dart';
import 'package:universal_io/io.dart';

class NewPostFunction {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static Future<bool> createNewPost(PostModel postModel) async {
    try {
      //saves the post
      await _firestore
          .collection("pending_posts")
          .doc(postModel.postId)
          .set(postModel.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<List<String>?> uploadMultipleImage(List<File> images) async {
    try {
      if (images.isEmpty) return null;

      List<String> downloadUrls = [];

      await Future.forEach(images, (element) async {
        final reference =
            _storage.ref().child("images/${DateTime.now().toIso8601String()}");

        final UploadTask uploadTask = reference.putFile(element);
        final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
        final url = await taskSnapshot.ref.getDownloadURL();
        downloadUrls.add(url);
      });

      return downloadUrls;
    } catch (e) {
      return null;
    }
  }

  static Future<List<String>?> uploadMultipleImageWeb(
      List<PlatformFile> images) async {
    try {
      List<String> downloadUrls = [];

      await Future.forEach(images, (element) async {
        final reference = _storage.ref().child(
            'images/${element.name}-${DateTime.now().toIso8601String()}');

        final UploadTask uploadTask = reference.putData(
            element.bytes!,
            SettableMetadata(
                contentType: 'image/${element.extension!}'.toLowerCase()));
        final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});

        final url = await taskSnapshot.ref.getDownloadURL();
        downloadUrls.add(url);
      });
      return downloadUrls;
    } catch (e) {
      return null;
    }
  }
}
