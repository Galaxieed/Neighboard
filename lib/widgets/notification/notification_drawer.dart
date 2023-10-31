import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/models/notification_model.dart';
import 'package:neighboard/models/post_model.dart';
import 'package:neighboard/screen_direct.dart';
import 'package:neighboard/src/landing_page/ui/landing_page.dart';
import 'package:neighboard/src/user_side/community_page/ui/announcement_page/announcement_page.dart';
import 'package:neighboard/src/user_side/community_page/ui/community_map_page/community_map.dart';
import 'package:neighboard/src/user_side/community_page/ui/hoa_voting_page/hoa_voting.dart';
import 'package:neighboard/src/user_side/community_page/ui/stores_page/stores.dart';
import 'package:neighboard/src/user_side/forum_page/ui/all_posts/all_posts_function.dart';
import 'package:neighboard/widgets/notification/mini_notif/elegant_notif.dart';
import 'package:neighboard/widgets/notification/notification_function.dart';
import 'package:neighboard/widgets/post/post_modal.dart';
import 'package:page_transition/page_transition.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:collection/collection.dart';

class NotificationDrawer extends StatefulWidget {
  const NotificationDrawer(
      {super.key, required this.deviceScreenType, required this.stateSetter});

  final DeviceScreenType deviceScreenType;
  final StateSetter stateSetter;

  @override
  State<NotificationDrawer> createState() => _NotificationDrawerState();
}

class _NotificationDrawerState extends State<NotificationDrawer> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<PopupMenuItem<String>> _popUpMenuItemsALL = [
    const PopupMenuItem(
      value: "Mark all as read",
      child: ListTile(
        leading: Icon(Icons.mark_email_read_outlined),
        title: Text("Mark all as read"),
      ),
    ),
    // const PopupMenuItem(
    //   value: "Archive all",
    //   child: ListTile(
    //     leading: Icon(Icons.archive_outlined),
    //     title: Text("Archive all"),
    //   ),
    // ),
  ];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoggedIn = false;
  void checkIfLoggedIn() {
    if (_auth.currentUser != null) {
      //getAllNotifications();
      getAllPost();
      setState(() {
        isLoggedIn = true;
      });
    }
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  String selectedVal = "All";
  bool isLoading = true;

  List<NotificationModel> unReadNotifications = [];
  void getAllUnreadNotifications() {
    unReadNotifications =
        notificationModels.where((element) => !element.isRead).toList();
    unReadNotifications.sort((a, b) => b.notifId.compareTo(a.notifId));
  }

  void readAllNotification() async {
    await NotificationFunction.readAllNotification();
    widget.stateSetter(() {});
  }

  void archiveAllNotification() async {
    await NotificationFunction.archiveAllNotification();
  }

  void readNotification(notificationId) async {
    await NotificationFunction.readNotification(notificationId);
    widget.stateSetter(() {});
  }

  void archiveNotification(notificationId) async {
    await NotificationFunction.archiveNotification(notificationId);
  }

  List<PostModel> postModels = [];
  void getAllPost() async {
    postModels = await AllPostsFunction.getAllPost() ?? [];
    postModels.sort((a, b) => b.postId.compareTo(a.postId));
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void openPostModal(PostModel post) {
    widget.deviceScreenType != DeviceScreenType.mobile
        ? showDialog(
            context: context,
            builder: (BuildContext context) => Dialog(
                child: PostModal(
              postModel: post,
              deviceScreenType: widget.deviceScreenType,
            )),
          )
        : showModalBottomSheet(
            useSafeArea: true,
            useRootNavigator: true,
            isScrollControlled: true,
            context: context,
            builder: (context) => PostModal(
              postModel: post,
              deviceScreenType: widget.deviceScreenType,
            ),
          );
  }

  @override
  void initState() {
    super.initState();
    checkIfLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : !isLoggedIn
              ? const Center(
                  child: Text("Login First"),
                )
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Text(
                                "Notifications",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            PopupMenuButton<String>(
                              position: PopupMenuPosition.under,
                              onSelected: (String value) {
                                if (value == "Mark all as read") {
                                  //all notification of this specific user go to read
                                  readAllNotification();
                                } else if (value == "Archive all") {
                                  //all notification of this specific user go to archive
                                  archiveAllNotification();
                                }
                              },
                              itemBuilder: (context) => _popUpMenuItemsALL,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  selectedVal = "All";
                                });
                              },
                              style: selectedVal != "All"
                                  ? null
                                  : ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .inversePrimary,
                                      foregroundColor: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                              child: const Text("All"),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  selectedVal = "Unread";
                                });
                              },
                              style: selectedVal != "Unread"
                                  ? null
                                  : ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .inversePrimary,
                                      foregroundColor: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                              child: const Text("Unread"),
                            ),
                          ],
                        ),
                        Expanded(
                          child: StreamBuilder(
                            stream: _firestore
                                .collection("notifications")
                                .doc(_auth.currentUser!.uid)
                                .collection("all")
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else {
                                //initialization ng notifications
                                notificationModels = snapshot.data!.docs
                                    .map((e) =>
                                        NotificationModel.fromJson(e.data()))
                                    .toList();
                                notificationModels.sort(
                                    (a, b) => b.notifId.compareTo(a.notifId));
                                getAllUnreadNotifications();
                                //TODO: add here
                                if (unReadNotifications.isEmpty &&
                                    selectedVal != "All") {
                                  return Center(
                                    child: Column(
                                      children: [
                                        Image.asset(
                                          announcement,
                                          width: 300,
                                          height: 300,
                                        ),
                                        const Text(
                                            "Nice work! You’re all caught up."),
                                      ],
                                    ),
                                  );
                                }
                                if (notificationModels.isEmpty &&
                                    selectedVal == "All") {
                                  return Center(
                                    child: Column(
                                      children: [
                                        Image.asset(
                                          notificationImg,
                                          width: 300,
                                          height: 300,
                                        ),
                                        const Text("You have 0 notification"),
                                      ],
                                    ),
                                  );
                                }
                                return ListView.separated(
                                  shrinkWrap: true,
                                  itemCount: selectedVal == "All"
                                      ? notificationModels.length
                                      : unReadNotifications.length,
                                  itemBuilder: (context, index) {
                                    NotificationModel notification;
                                    if (selectedVal == "All") {
                                      notification = notificationModels[index];
                                    } else {
                                      notification = unReadNotifications[index];
                                    }
                                    return ListTile(
                                      onTap: () {
                                        readNotification(notification.notifId);
                                        if (notification.notifLocation
                                                .split("|")[0] ==
                                            "FORUM") {
                                          Navigator.pop(context);
                                          if (postModels.isNotEmpty) {
                                            PostModel? post =
                                                postModels.firstWhereOrNull(
                                              (element) =>
                                                  element.postId ==
                                                  notification.notifLocation
                                                      .split("|")[1],
                                            );
                                            if (post == null) {
                                              infoMessage(
                                                  title: "Post not found!",
                                                  desc:
                                                      "This post may be removed by the author!",
                                                  context: context);
                                            } else {
                                              openPostModal(post);
                                            }
                                          }
                                        }
                                        if (notification.notifLocation ==
                                            "ANNOUNCEMENT") {
                                          Navigator.pop(context);
                                          Navigator.of(context).push(
                                              PageTransition(
                                                  duration:
                                                      const Duration(
                                                          milliseconds: 500),
                                                  child:
                                                      const AnnouncementPage(),
                                                  type:
                                                      PageTransitionType.fade));
                                        }
                                        if (notification.notifLocation ==
                                            "MAP") {
                                          Navigator.pop(context);
                                          Navigator.of(context).push(
                                              PageTransition(
                                                  duration: const Duration(
                                                      milliseconds: 500),
                                                  child: const CommunityMap(),
                                                  type:
                                                      PageTransitionType.fade));
                                        }
                                        if (notification.notifLocation ==
                                            "ELECTION") {
                                          Navigator.pop(context);
                                          Navigator.of(context).push(
                                              PageTransition(
                                                  duration: const Duration(
                                                      milliseconds: 500),
                                                  child: const HOAVoting(),
                                                  type:
                                                      PageTransitionType.fade));
                                        }
                                        if (notification.notifLocation ==
                                            "SITE") {
                                          Navigator.pop(context);
                                          Navigator.of(context)
                                              .pushAndRemoveUntil(
                                                  PageTransition(
                                                      duration: const Duration(
                                                          milliseconds: 500),
                                                      child:
                                                          const LandingPage(),
                                                      type: PageTransitionType
                                                          .fade),
                                                  (route) => false);
                                        }
                                        if (notification.notifLocation ==
                                            "STORE") {
                                          Navigator.pop(context);
                                          Navigator.of(context).push(
                                              PageTransition(
                                                  duration: const Duration(
                                                      milliseconds: 500),
                                                  child: const StoresPage(),
                                                  type:
                                                      PageTransitionType.fade));
                                        }
                                      },
                                      isThreeLine: true,
                                      leading: !notification.isRead
                                          ? const Icon(
                                              Icons.mark_email_unread_rounded)
                                          : const Icon(
                                              Icons.mark_email_read_outlined),
                                      title: Text(
                                          "${notification.notifTitle}${notification.notifBody}"),
                                      titleTextStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                              fontWeight: notification.isRead
                                                  ? null
                                                  : FontWeight.bold),
                                      subtitle: Text(
                                        notification.notifTime,
                                        style: notification.isRead
                                            ? null
                                            : const TextStyle(
                                                color: Colors.blue,
                                                fontWeight: FontWeight.bold),
                                      ),
                                      subtitleTextStyle: Theme.of(context)
                                          .textTheme
                                          .labelMedium!,
                                      trailing: notification.isRead
                                          ? null
                                          : const Icon(
                                              Icons.circle,
                                              color: Colors.blue,
                                              size: 15,
                                            ),
                                    );
                                  },
                                  separatorBuilder: (context, index) {
                                    return const Divider();
                                  },
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
