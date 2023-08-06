import 'dart:math';
import 'package:english_words/english_words.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

String formattedDate =
    DateFormat('MMMM d, yyyy | hh:mm a').format(DateTime.now());

String randomName = WordPair.random().asPascalCase.toString();

final random = Random();
String generateRandomId(int length) {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final id = String.fromCharCodes(Iterable.generate(
      length, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  return id;
}

final randomId = generateRandomId(8);
//TODO: add post to database and display it in ui
// List<PostModel> posts = [
//   PostModel(
//     postId: postId,
//     authorId: authorId,
//     authorName: authorName,
//     profilePicture: profilePicture,
//     timeStamp: timeStamp,
//     title: title,
//     content: content,
//     noOfViews: noOfViews,
//     comments: comments,
//     noOfUpVotes: noOfUpVotes,
//     isUpvoted: isUpvoted,
//     tags: tags,
//   ),
// ];

// CommentModel comments = CommentModel(
//     commentId: randomId,
//     senderId: randomId,
//     senderName: randomName,
//     timeStamp: formattedDate,
//     commentMessage: randomName,
//     noOfLikes: 100,
//     isLiked: true,
//     noOfDislikes: 0,
//     isDisliked: false,
//     replies: [replies]);

// ReplyModel replies = ReplyModel(
//   replyId: randomId,
//   senderId: randomName,
//   senderName: randomName,
//   recipientId: randomId,
//   recipientName: randomName,
//   replyMessage: randomName,
// );
