import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/main.dart';

import 'package:neighboard/models/announcement_model.dart';
import 'package:neighboard/src/admin_side/announcements/announcement_function.dart';
import 'package:neighboard/widgets/chat/chat.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_bar.dart';
import 'package:neighboard/widgets/notification/mini_notif/elegant_notif.dart';
import 'package:neighboard/widgets/notification/notification_drawer.dart';
import 'package:responsive_builder/responsive_builder.dart';

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
    //check announcment schedule
    announcementModels = announcementModels
        .where((element) =>
            DateTime.parse(element.timeStamp).isBefore(DateTime.now()))
        .toList();
    announcementModels
        .sort((a, b) => b.announcementId.compareTo(a.announcementId));
    allAnnouncementModels = announcementModels;
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
        announcementModels
            .sort((a, b) => b.announcementId.compareTo(a.announcementId));
        isDateAsc = !isDateAsc;
      } else if (type == "date" && !isDateAsc) {
        announcementModels
            .sort((a, b) => a.announcementId.compareTo(b.announcementId));
        isDateAsc = !isDateAsc;
      }
    });
  }

  final List<PopupMenuItem> _popUpMenuItem = [
    const PopupMenuItem(
      value: "title",
      child: ListTile(
        leading: Icon(Icons.sort_by_alpha),
        title: Text("View by Title"),
      ),
    ),
    const PopupMenuItem(
      value: "date",
      child: ListTile(
        leading: Icon(Icons.date_range),
        title: Text("View by Date"),
      ),
    ),
  ];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openNotification() {
    _scaffoldKey.currentState!.openEndDrawer();
  }

  void _openChat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return const MyChat();
      },
    );
  }

  String searchedText = "";
  List<AnnouncementModel> allAnnouncementModels = [];
  void searchAnnouncement(String text) {
    text = text.toLowerCase();
    announcementModels = allAnnouncementModels;
    if (text.isNotEmpty) {
      announcementModels = announcementModels
          .where((announcement) =>
              announcement.title.toLowerCase().contains(text) ||
              announcement.datePosted.toLowerCase().contains(text) ||
              announcement.details.toLowerCase().contains(text))
          .toList();
    }
  }

  @override
  void initState() {
    super.initState();
    getAllAnnouncements();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: NavBar(
        openNotification: _openNotification,
        openChat: _openChat,
        currentPage: "Community",
      ),
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
            const SizedBox(
              height: 15,
            ),
            Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Announcements',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                        fontFamily: "Montserrat", fontWeight: FontWeight.bold),
                  ),
                ),
                Positioned(
                  right: 0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 300,
                        child: SearchBar(
                          leading: const Icon(Icons.search),
                          hintText: 'Search...',
                          constraints: const BoxConstraints(
                            minWidth: double.infinity,
                            minHeight: 40,
                          ),
                          onChanged: (String searchText) {
                            setState(() {
                              searchAnnouncement(searchText);
                            });
                          },
                        ),
                      ),
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
                ),
              ],
            ),
            const SizedBox(
              height: 35,
            ),
            Expanded(
              child: announcementModels.isEmpty
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
                  : Row(
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
                                  stateSetter: getAllAnnouncements,
                                  isAdmin: false,
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
                                  announcementModel: model,
                                  stateSetter: getAllAnnouncements,
                                  isAdmin: false,
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

// ignore: must_be_immutable
class MainAnnouncement extends StatelessWidget {
  MainAnnouncement(
      {super.key,
      required this.announcementModel,
      required this.stateSetter,
      required this.isAdmin});
  final AnnouncementModel announcementModel;
  final Function stateSetter;
  final bool isAdmin;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  bool isEditing = false;

  removeAnnouncement(BuildContext context) async {
    bool isSuccess =
        await AnnouncementFunction.removeAnnouncement(announcementModel);
    if (isSuccess) {
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      // ignore: use_build_context_synchronously
      successMessage(
          title: "Success!", desc: "Refresh to see changes!", context: context);
      stateSetter();
    } else {
      // ignore: use_build_context_synchronously
      errorMessage(
          title: "Something went wrong!",
          desc: "This announcement isn't archived!",
          context: context);
    }
  }

  updateAnnouncement(BuildContext context) async {
    if (_titleController.text.isNotEmpty &&
        _detailsController.text.isNotEmpty) {
      bool status = await AnnouncementFunction.updateAnnouncement(
          announcementModel.announcementId,
          profanityFilter.censor(_titleController.text),
          profanityFilter.censor(_detailsController.text));

      if (status) {
        // ignore: use_build_context_synchronously
        successMessage(
            title: "Success!",
            desc: "Refresh to see changes!",
            context: context);
        stateSetter();
      } else {
        // ignore: use_build_context_synchronously
        errorMessage(
            title: "Something went wrong!",
            desc: "This announcement isn't updated!",
            context: context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _titleController.text = announcementModel.title;
    _detailsController.text = announcementModel.details;
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
            padding: EdgeInsets.all(3.7.sp),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        announcementModel.title.toUpperCase(),
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        announcementModel.datePosted,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return StatefulBuilder(builder: (context, setState) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: Stack(
                              children: [
                                SizedBox(
                                  width: 550,
                                  height: 650,
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (isAdmin)
                                          Container(
                                            height: 75,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .inversePrimary,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                ElevatedButton(
                                                    onPressed: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            title: const Text(
                                                                "Confirm?"),
                                                            content: const Text(
                                                                "Would you like to continue removing this announcement?"),
                                                            actions: [
                                                              ElevatedButton(
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child:
                                                                    const Text(
                                                                        "NO"),
                                                              ),
                                                              ElevatedButton(
                                                                onPressed: () {
                                                                  removeAnnouncement(
                                                                      context);
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child:
                                                                    const Text(
                                                                        "YES"),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      foregroundColor:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .onBackground,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                      ),
                                                    ),
                                                    child:
                                                        const Text("Archive")),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                ElevatedButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        isEditing = !isEditing;
                                                      });
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .primary,
                                                      foregroundColor:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .onPrimary,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                      ),
                                                    ),
                                                    child: Text(isEditing
                                                        ? "Cancel"
                                                        : "Edit")),
                                              ],
                                            ),
                                          ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Container(
                                          width: double.infinity,
                                          height: 400,
                                          decoration: announcementModel.image ==
                                                  ""
                                              ? BoxDecoration(
                                                  image: const DecorationImage(
                                                    image: AssetImage(noImage),
                                                    fit: BoxFit.cover,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(30))
                                              : BoxDecoration(
                                                  image: DecorationImage(
                                                    image: NetworkImage(
                                                        announcementModel
                                                            .image),
                                                    fit: BoxFit.cover,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12)),
                                        ),
                                        const SizedBox(
                                          height: 16,
                                        ),
                                        isEditing
                                            ? TextField(
                                                controller: _titleController,
                                                decoration: InputDecoration(
                                                    suffixIcon: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    IconButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          _titleController
                                                                  .text =
                                                              announcementModel
                                                                  .title;
                                                          isEditing = false;
                                                        });
                                                      },
                                                      icon: const Icon(
                                                        Icons.cancel_outlined,
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                    IconButton(
                                                      onPressed: () {
                                                        updateAnnouncement(
                                                            context);
                                                        Navigator.pop(context);
                                                      },
                                                      icon: Icon(
                                                        Icons.save,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary,
                                                      ),
                                                    )
                                                  ],
                                                )),
                                              )
                                            : Text(
                                                announcementModel.title,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleLarge!
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        isEditing
                                            ? TextField(
                                                controller: _detailsController,
                                                maxLines: 10,
                                                decoration: InputDecoration(
                                                    suffixIcon: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    IconButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          _detailsController
                                                                  .text =
                                                              announcementModel
                                                                  .details;
                                                          isEditing = false;
                                                        });
                                                      },
                                                      icon: const Icon(
                                                        Icons.cancel_outlined,
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                    IconButton(
                                                      onPressed: () {
                                                        updateAnnouncement(
                                                            context);
                                                        Navigator.pop(context);
                                                      },
                                                      icon: Icon(
                                                        Icons.save,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary,
                                                      ),
                                                    )
                                                  ],
                                                )),
                                              )
                                            : Text(
                                                "${announcementModel.datePosted}\n${announcementModel.details}",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge,
                                              ),
                                        const SizedBox(
                                          height: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    icon: const Icon(Icons.close),
                                  ),
                                ),
                              ],
                            ),
                          );
                        });
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                  ),
                  child: Text(
                    'View Details',
                    style: Theme.of(context).textTheme.titleMedium,
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

// ignore: must_be_immutable
class OtherAnnouncement extends StatelessWidget {
  OtherAnnouncement(
      {super.key,
      required this.announcementModel,
      required this.stateSetter,
      required this.isAdmin});
  final AnnouncementModel announcementModel;
  final bool isAdmin;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  bool isEditing = false;
  final Function stateSetter;

  removeAnnouncement(BuildContext context) async {
    bool isSuccess =
        await AnnouncementFunction.removeAnnouncement(announcementModel);
    if (isSuccess) {
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      // ignore: use_build_context_synchronously
      successMessage(
          title: "Success!", desc: "Refresh to see changes!", context: context);
      stateSetter();
    } else {
      // ignore: use_build_context_synchronously
      errorMessage(
          title: "Something went wrong!",
          desc: "This announcement isn't archived!",
          context: context);
    }
  }

  updateAnnouncement(BuildContext context) async {
    if (_titleController.text.isNotEmpty &&
        _detailsController.text.isNotEmpty) {
      bool status = await AnnouncementFunction.updateAnnouncement(
          announcementModel.announcementId,
          profanityFilter.censor(_titleController.text),
          profanityFilter.censor(_detailsController.text));

      if (status) {
        // ignore: use_build_context_synchronously
        successMessage(
            title: "Success!",
            desc: "Refresh to see changes!",
            context: context);
        stateSetter();
      } else {
        // ignore: use_build_context_synchronously
        errorMessage(
            title: "Something went wrong!",
            desc: "This announcement isn't updated!",
            context: context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _titleController.text = announcementModel.title;
    _detailsController.text = announcementModel.details;
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
              Container(
                decoration: BoxDecoration(
                  color: ccOtherAnnouncementBannerColor(context),
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: EdgeInsets.all(3.5.sp),
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
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            announcementModel.datePosted,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                            overflow: TextOverflow.ellipsis,
                          )
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                                builder: (context, setState) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                child: Stack(
                                  children: [
                                    SizedBox(
                                      width: 550,
                                      height: 650,
                                      child: SingleChildScrollView(
                                        padding: const EdgeInsets.all(32.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (isAdmin)
                                              Container(
                                                height: 75,
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .inversePrimary,
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    ElevatedButton(
                                                        onPressed: () {
                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return AlertDialog(
                                                                title: const Text(
                                                                    "Confirm?"),
                                                                content: const Text(
                                                                    "Would you like to continue removing this announcement?"),
                                                                actions: [
                                                                  ElevatedButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                    child:
                                                                        const Text(
                                                                            "NO"),
                                                                  ),
                                                                  ElevatedButton(
                                                                    onPressed:
                                                                        () {
                                                                      removeAnnouncement(
                                                                          context);
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                    child: const Text(
                                                                        "YES"),
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          );
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          foregroundColor:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onBackground,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4),
                                                          ),
                                                        ),
                                                        child: const Text(
                                                            "Archive")),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    ElevatedButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            isEditing =
                                                                !isEditing;
                                                          });
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                          foregroundColor:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onPrimary,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4),
                                                          ),
                                                        ),
                                                        child: Text(isEditing
                                                            ? "Cancel"
                                                            : "Edit")),
                                                  ],
                                                ),
                                              ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            Container(
                                              width: double.infinity,
                                              height: 400,
                                              decoration: announcementModel
                                                          .image ==
                                                      ""
                                                  ? BoxDecoration(
                                                      image:
                                                          const DecorationImage(
                                                        image:
                                                            AssetImage(noImage),
                                                        fit: BoxFit.cover,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    )
                                                  : BoxDecoration(
                                                      image: DecorationImage(
                                                        image: NetworkImage(
                                                            announcementModel
                                                                .image),
                                                        fit: BoxFit.cover,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                            ),
                                            const SizedBox(height: 16),
                                            isEditing
                                                ? TextField(
                                                    controller:
                                                        _titleController,
                                                    decoration: InputDecoration(
                                                      suffixIcon: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          IconButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                _titleController
                                                                        .text =
                                                                    announcementModel
                                                                        .title;
                                                                isEditing =
                                                                    false;
                                                              });
                                                            },
                                                            icon: const Icon(
                                                              Icons
                                                                  .cancel_outlined,
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                          IconButton(
                                                            onPressed: () {
                                                              updateAnnouncement(
                                                                  context);
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            icon: Icon(
                                                              Icons.save,
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .primary,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                : Text(
                                                    announcementModel.title,
                                                    textAlign: TextAlign.start,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleLarge!
                                                        .copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                  ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            isEditing
                                                ? TextField(
                                                    controller:
                                                        _detailsController,
                                                    maxLines: 10,
                                                    decoration: InputDecoration(
                                                      suffixIcon: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          IconButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                _detailsController
                                                                        .text =
                                                                    announcementModel
                                                                        .details;
                                                                isEditing =
                                                                    false;
                                                              });
                                                            },
                                                            icon: const Icon(
                                                              Icons
                                                                  .cancel_outlined,
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                          IconButton(
                                                            onPressed: () {
                                                              updateAnnouncement(
                                                                  context);
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            icon: Icon(
                                                              Icons.save,
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .primary,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                : Text(
                                                    "${announcementModel.datePosted}\n${announcementModel.details}",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge,
                                                  ),
                                            const SizedBox(height: 16),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: IconButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        icon: const Icon(Icons.close),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            });
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                      ),
                      child: Text(
                        'View Details',
                        style: Theme.of(context).textTheme.titleMedium,
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
