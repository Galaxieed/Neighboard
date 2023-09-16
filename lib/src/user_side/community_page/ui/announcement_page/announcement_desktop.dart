import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neighboard/constants/constants.dart';

import 'package:neighboard/models/announcement_model.dart';
import 'package:neighboard/src/admin_side/announcements/announcement_function.dart';
import 'package:neighboard/widgets/chat/chat.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_bar.dart';

class AnnouncementDesktop extends StatefulWidget {
  const AnnouncementDesktop({super.key});

  @override
  State<AnnouncementDesktop> createState() => _AnnouncementDesktopState();
}

class _AnnouncementDesktopState extends State<AnnouncementDesktop> {
  bool isLoading = true;
  List<AnnouncementModel> announcementModels = [];

  void getAllAnnouncements() async {
    announcementModels = await AnnouncementFunction.getAllAnnouncements() ?? [];
    announcementModels.sort((a, b) => b.datePosted.compareTo(a.datePosted));
    if (mounted) {
      setState(() {
        isLoading = false;
      });
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
  @override
  void initState() {
    super.initState();
    getAllAnnouncements();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openNotification() {
    _scaffoldKey.currentState!.openEndDrawer();
  }

  void _openChat() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return const MyChat();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: NavBar(
        openNotification: _openNotification,
        openChat: _openChat,
      ),
      endDrawer: const Drawer(
        child: Column(
          children: [Text("Notifications")],
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
        child: announcementModels == []
            ? const Center(
                child: Text("No Announcements"),
              )
            : Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    'Announcements',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      PopupMenuButton(
                        position: PopupMenuPosition.under,
                        tooltip: "Filter announcements",
                        icon: const Icon(Icons.filter_alt_outlined),
                        onSelected: (value) {
                          sortAnnouncement(value);
                        },
                        itemBuilder: (BuildContext context) => _popUpMenuItem,
                      ),
                    ],
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: () {
                            Widget widget = Container();
                            for (AnnouncementModel announcementModel
                                in announcementModels) {
                              if (announcementModels[0] == announcementModel) {
                                widget = MainAnnouncement(
                                  announcementModel: announcementModel,
                                );
                                break;
                              } else {
                                widget = Container();
                              }
                            }
                            return widget;
                          }(),
                        ),
                        SizedBox(
                          width: 5.w,
                        ),
                        Expanded(
                          flex: 3,
                          child: ListView.builder(
                            itemCount: announcementModels.length,
                            itemBuilder: (context, index) {
                              var model = announcementModels[index];
                              if (model != announcementModels[0]) {
                                return OtherAnnouncement(
                                    announcementModel: model);
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
          child: announcementModel.image == ""
              ? Container(
                  color: Colors.grey[350],
                  child: const Center(
                    child: Text("No Image"),
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(announcementModel.image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                announcementModel.title,
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Text(
                                "${announcementModel.datePosted}\n${announcementModel.details}",
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 32,
                        ),
                        Flexible(
                          flex: 3,
                          child: Container(
                            width: 600,
                            height: 600,
                            decoration: announcementModel.image == ""
                                ? BoxDecoration(
                                    image: const DecorationImage(
                                      image: AssetImage(noImage),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(5))
                                : BoxDecoration(
                                    image: DecorationImage(
                                      image:
                                          NetworkImage(announcementModel.image),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(5)),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: ccMainAnnouncementBannerColor(context),
            ),
            child: Padding(
              padding: EdgeInsets.all(3.7.sp),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        announcementModel.title.toUpperCase(),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        announcementModel.timeStamp,
                        style: Theme.of(context).textTheme.titleMedium,
                      )
                    ],
                  ),
                  Text(
                    'View Details..',
                    style: Theme.of(context).textTheme.titleMedium,
                  )
                ],
              ),
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
                height: 100.h,
              ),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      announcementModel.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium,
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      "${announcementModel.datePosted}\n${announcementModel.details}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 32,
                              ),
                              Flexible(
                                flex: 3,
                                child: Container(
                                  width: 600,
                                  height: 600,
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
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: ccOtherAnnouncementBannerColor(context),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: EdgeInsets.all(3.5.sp),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            announcementModel.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            announcementModel.timeStamp,
                            style: Theme.of(context).textTheme.titleMedium,
                          )
                        ],
                      ),
                      Text(
                        'View Details..',
                        style: Theme.of(context).textTheme.titleMedium,
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
