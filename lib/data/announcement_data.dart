import 'package:english_words/english_words.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/data/posts_data.dart';
import 'package:neighboard/models/announcement_model.dart';

List<AnnouncementModel> announcements = [
  AnnouncementModel(
    announcementId: generateRandomId(8),
    title: WordPair.random().asPascalCase,
    details: 'Announcement Main',
    timeStamp: formattedDate,
    image: guestIcon,
    isMainAnnouncement: false,
  ),
  AnnouncementModel(
    announcementId: generateRandomId(8),
    title: WordPair.random().asPascalCase,
    details: 'Announcement 1',
    timeStamp: formattedDate,
    image: homeImage,
    isMainAnnouncement: true,
  ),
  AnnouncementModel(
    announcementId: generateRandomId(8),
    title: WordPair.random().asPascalCase,
    details: 'Announcement 2',
    timeStamp: formattedDate,
    image: homepageImage,
    isMainAnnouncement: false,
  ),
  AnnouncementModel(
    announcementId: generateRandomId(8),
    title: WordPair.random().asPascalCase,
    details: 'Announcement 2',
    timeStamp: formattedDate,
    image: bigScoopImage,
    isMainAnnouncement: false,
  ),
  AnnouncementModel(
    announcementId: generateRandomId(8),
    title: WordPair.random().asPascalCase,
    details: 'Announcement 2',
    timeStamp: formattedDate,
    image: bigScoopImage,
    isMainAnnouncement: false,
  ),
];
