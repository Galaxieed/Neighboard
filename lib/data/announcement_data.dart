import 'package:english_words/english_words.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/data/posts_data.dart';
import 'package:neighboard/models/announcement_model.dart';

List<AnnouncementModel> announcementss = [
  AnnouncementModel(
    announcementId: generateRandomId(8),
    title: WordPair.random().asPascalCase,
    details: 'Announcement Main',
    timeStamp: formattedDate(),
    datePosted: formattedDate(),
    image: guestIcon,
  ),
  AnnouncementModel(
    announcementId: generateRandomId(8),
    title: WordPair.random().asPascalCase,
    details: 'Announcement 1',
    timeStamp: formattedDate(),
    datePosted: formattedDate(),
    image: homeImage,
  ),
  AnnouncementModel(
    announcementId: generateRandomId(8),
    title: WordPair.random().asPascalCase,
    details: 'Announcement 2',
    timeStamp: formattedDate(),
    datePosted: formattedDate(),
    image: homepageImage,
  ),
  AnnouncementModel(
    announcementId: generateRandomId(8),
    title: WordPair.random().asPascalCase,
    details: 'Announcement 2',
    timeStamp: formattedDate(),
    datePosted: formattedDate(),
    image: bigScoopImage,
  ),
  AnnouncementModel(
    announcementId: generateRandomId(8),
    title: WordPair.random().asPascalCase,
    details: 'Announcement 2',
    timeStamp: formattedDate(),
    datePosted: formattedDate(),
    image: bigScoopImage,
  ),
];
