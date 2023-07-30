import 'dart:math';

import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/models/comment_model.dart';
import 'package:neighboard/models/post_model.dart';
import 'package:english_words/english_words.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:neighboard/models/reply_model.dart';

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

List<PostModel> posts = [
  PostModel(
      postId: randomId,
      authorId: randomId,
      authorName: randomName,
      profilePicture: homeImage,
      timeStamp: formattedDate,
      title: randomName,
      content: randomName,
      noOfViews: 100,
      comments: [comments],
      noOfUpVotes: 100,
      isUpVoted: true,
      tags: [
        randomName,
        randomName,
        randomName,
      ])
];

CommentModel comments = CommentModel(
    commentId: randomId,
    senderId: randomId,
    senderName: randomName,
    timeStamp: formattedDate,
    commentMessage: randomName,
    noOfLikes: 100,
    isLiked: true,
    noOfDislikes: 0,
    isDisliked: false,
    replies: [replies]);

ReplyModel replies = ReplyModel(
  replyId: randomId,
  senderId: randomName,
  senderName: randomName,
  recipientId: randomId,
  recipientName: randomName,
  replyMessage: randomName,
);
