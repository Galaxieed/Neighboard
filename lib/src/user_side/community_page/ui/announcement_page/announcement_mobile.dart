import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/models/announcement_model.dart';
import 'package:neighboard/routes/routes.dart';
import 'package:neighboard/screen_direct.dart';
import 'package:neighboard/src/admin_side/announcements/announcement_function.dart';
import 'package:neighboard/src/user_side/login_register_page/login_page/login_page_ui.dart';
import 'package:neighboard/src/user_side/login_register_page/register_page/register_page_ui.dart';
import 'package:neighboard/widgets/chat/chat.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_bar.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_drawer.dart';
import 'package:neighboard/widgets/notification/notification_drawer.dart';
import 'package:responsive_builder/responsive_builder.dart';

class AnnouncementMobile extends StatefulWidget {
  const AnnouncementMobile({super.key, required this.deviceScreenType});

  final DeviceScreenType deviceScreenType;

  @override
  State<AnnouncementMobile> createState() => _AnnouncementMobileState();
}

class _AnnouncementMobileState extends State<AnnouncementMobile> {
  bool isLoading = true;

  List<AnnouncementModel> announcementModels = [];

  void getAllAnnouncements() async {
    announcementModels = await AnnouncementFunction.getAllAnnouncements() ?? [];
    announcementModels.sort((a, b) => b.datePosted.compareTo(a.datePosted));
    _mainAnnouncementWidget();
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget mainAnnouncementWidget = Container();
  _mainAnnouncementWidget() {
    for (AnnouncementModel announcementModel in announcementModels) {
      if (announcementModel == announcementModels[0]) {
        mainAnnouncementWidget = MainAnnouncement(
          announcementModel: announcementModel,
        );
        break;
      }
    }
  }

  bool isTitleAsc = true, isDateAsc = false;
  void sortAnnouncement(String type) {
    setState(() {
      if (type == "title" && isTitleAsc) {
        announcementModels.sort(
            (a, b) => a.title.toUpperCase().compareTo(b.title.toUpperCase()));
        isTitleAsc = !isTitleAsc;
      } else if (type == "title" && !isTitleAsc) {
        announcementModels.sort(
            (a, b) => b.title.toUpperCase().compareTo(a.title.toUpperCase()));
        isTitleAsc = !isTitleAsc;
      } else if (type == "date" && isDateAsc) {
        announcementModels.sort((a, b) => b.datePosted.compareTo(a.datePosted));
        isDateAsc = !isDateAsc;
      } else if (type == "date" && !isDateAsc) {
        announcementModels.sort((a, b) => a.datePosted.compareTo(b.datePosted));
        isDateAsc = !isDateAsc;
      }
      _mainAnnouncementWidget();
    });
  }

  final List<PopupMenuItem> _popUpMenuItem = [
    const PopupMenuItem(
      value: "title",
      child: ListTile(
        leading: Icon(Icons.sort_by_alpha),
        title: Text("Sort by Title"),
      ),
    ),
    const PopupMenuItem(
      value: "date",
      child: ListTile(
        leading: Icon(Icons.date_range),
        title: Text("Sort by Date"),
      ),
    ),
  ];
  void _openChat() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      context: context,
      builder: (context) {
        return const MyChat();
      },
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  void _openNotification() {
    _scaffoldKey.currentState!.openEndDrawer();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoggedIn = false;
  checkIfLoggedIn() {
    if (_auth.currentUser != null) {
      isLoggedIn = true;
    }
  }

  @override
  void initState() {
    super.initState();
    checkIfLoggedIn();
    getAllAnnouncements();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        actions: [
          //TODO: Chat count
          if (isLoggedIn)
            NavBarBadges(
              count: null,
              icon: const Icon(Icons.chat_outlined),
              callback: _openChat,
            ),
          if (isLoggedIn)
            const SizedBox(
              width: 10,
            ),
          if (isLoggedIn)
            NavBarBadges(
              count: notificationModels
                  .where((element) => !element.isRead)
                  .toList()
                  .length
                  .toString(),
              icon: const Icon(Icons.notifications_outlined),
              callback: _openNotification,
            )
          else
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const LoginPage()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Theme.of(context).colorScheme.onBackground,
                elevation: 0,
              ),
              child: const Text(
                "Login",
                style: TextStyle(
                  letterSpacing: 1,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          const SizedBox(
            width: 10,
          ),
          if (isLoggedIn)
            NavBarCircularImageDropDownButton(
              callback: Routes().navigate,
              isAdmin: false,
            )
          else
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const RegisterPage()));
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                foregroundColor: Theme.of(context).colorScheme.onBackground,
              ),
              child: const Text(
                "Register",
                style: TextStyle(
                  letterSpacing: 1,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          const SizedBox(
            width: 10,
          ),
        ],
      ),
      drawer: widget.deviceScreenType == DeviceScreenType.mobile
          ? const NavDrawer()
          : null,
      endDrawer: NotificationDrawer(
        deviceScreenType: DeviceScreenType.desktop,
        stateSetter: setState,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.centerRight,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    'ANNOUNCEMENTS',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Positioned(
                  right: 1,
                  child: PopupMenuButton(
                    position: PopupMenuPosition.under,
                    tooltip: "Filter announcements",
                    icon: const Icon(Icons.filter_alt_outlined),
                    onSelected: (value) {
                      sortAnnouncement(value);
                    },
                    itemBuilder: (BuildContext context) => _popUpMenuItem,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            announcementModels.isEmpty
                ? Center(
                    child: Column(
                      children: [
                        Image.asset(
                          announcement,
                          height: 300,
                          width: 300,
                        ),
                        const Text("No Announcements"),
                      ],
                    ),
                  )
                : Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: announcementModels.length,
                            itemBuilder: (context, index) {
                              var model = announcementModels[index];
                              if (model == announcementModels[0]) {
                                return Column(
                                  children: [
                                    const Divider(),
                                    Text(
                                      "Main Announcement!",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    const Divider(),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              2.5,
                                      child: mainAnnouncementWidget,
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    const Divider(),
                                    Text(
                                      "Other Announcements!",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    const Divider(),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                  ],
                                );
                              }
                              if (model != announcementModels[0]) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 20.0),
                                  child: OtherAnnouncement(
                                      announcementModel: model),
                                );
                              } else {
                                return Container();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class MainAnnouncement extends StatelessWidget {
  const MainAnnouncement({super.key, required this.announcementModel});
  final AnnouncementModel announcementModel;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: announcementModel.image == ""
                    ? const AssetImage(noImage) as ImageProvider
                    : NetworkImage(announcementModel.image),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: ccMainAnnouncementBannerColor(context),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        announcementModel.title.toUpperCase(),
                        style:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        announcementModel.timeStamp,
                        style: Theme.of(context).textTheme.titleSmall,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      showDragHandle: true,
                      useSafeArea: true,
                      isScrollControlled: true,
                      context: context,
                      builder: (BuildContext context) {
                        return SingleChildScrollView(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: Container(
                                    width: 600,
                                    height: 300,
                                    decoration: announcementModel.image == ""
                                        ? BoxDecoration(
                                            image: const DecorationImage(
                                              image: AssetImage(noImage),
                                              fit: BoxFit.cover,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(5))
                                        : BoxDecoration(
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                  announcementModel.image),
                                              fit: BoxFit.cover,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Flexible(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        announcementModel.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge!
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        "${announcementModel.datePosted}\n${announcementModel.details}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                  ),
                  child: Text(
                    'View Details',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}

class OtherAnnouncement extends StatelessWidget {
  const OtherAnnouncement({super.key, required this.announcementModel});
  final AnnouncementModel announcementModel;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 5.h),
      child: Card(
        elevation: 4,
        child: Container(
          decoration: announcementModel.image == ""
              ? BoxDecoration(
                  color: Colors.grey[350],
                  borderRadius: BorderRadius.circular(5),
                )
              : BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(announcementModel.image),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * .20,
              ),
              Container(
                decoration: BoxDecoration(
                  color: ccOtherAnnouncementBannerColor(context),
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            announcementModel.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            announcementModel.timeStamp,
                            style: Theme.of(context).textTheme.titleSmall,
                            overflow: TextOverflow.ellipsis,
                          )
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        showModalBottomSheet(
                          showDragHandle: true,
                          useSafeArea: true,
                          isScrollControlled: true,
                          context: context,
                          builder: (BuildContext context) {
                            return SingleChildScrollView(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: Container(
                                        width: 600,
                                        height: 300,
                                        decoration: announcementModel.image ==
                                                ""
                                            ? BoxDecoration(
                                                image: const DecorationImage(
                                                  image: AssetImage(noImage),
                                                  fit: BoxFit.cover,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(5))
                                            : BoxDecoration(
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                      announcementModel.image),
                                                  fit: BoxFit.cover,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Flexible(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            announcementModel.title,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge!
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          Text(
                                            "${announcementModel.datePosted}\n${announcementModel.details}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                      ),
                      child: Text(
                        'View Details',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
