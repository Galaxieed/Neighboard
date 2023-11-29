import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/main.dart';
import 'package:neighboard/models/announcement_model.dart';
import 'package:neighboard/routes/routes.dart';
import 'package:neighboard/screen_direct.dart';
import 'package:neighboard/src/admin_side/announcements/announcement_function.dart';
import 'package:neighboard/src/user_side/login_register_page/login_page/login_page_ui.dart';
import 'package:neighboard/src/user_side/login_register_page/register_page/register_page_ui.dart';
import 'package:neighboard/widgets/chat/chat.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_bar.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_drawer.dart';
import 'package:neighboard/widgets/notification/mini_notif/elegant_notif.dart';
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
    //check announcment schedule
    announcementModels = announcementModels
        .where((element) =>
            DateTime.parse(element.timeStamp).isBefore(DateTime.now()))
        .toList();
    announcementModels.sort((a, b) => b.datePosted.compareTo(a.datePosted));
    allAnnouncementModels = announcementModels;
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
          ? NavDrawer(
              isLoggedIn: isLoggedIn,
            )
          : null,
      endDrawer: NotificationDrawer(
        deviceScreenType: DeviceScreenType.mobile,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: SizedBox(
                width: double.infinity,
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
                  onTap: () {
                    // showSearch(
                    //     context: context, delegate: SearchScreenUI());
                  },
                ),
              ),
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
                                    announcementModel: model,
                                    stateSetter: getAllAnnouncements,
                                    isAdmin: false,
                                  ),
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
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        announcementModel.datePosted,
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
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

// ignore: must_be_immutable
class OtherAnnouncement extends StatelessWidget {
  OtherAnnouncement(
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
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            announcementModel.datePosted,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
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
                        showModalBottomSheet(
                          showDragHandle: true,
                          useSafeArea: true,
                          isScrollControlled: true,
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                                builder: (context, setState) {
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
                                                        announcementModel
                                                            .image),
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
                                                              isEditing = false;
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
                                                                .inversePrimary,
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
                                                    textAlign: TextAlign.center,
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
                                                              isEditing = false;
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
                                                                .inversePrimary,
                                                          ),
                                                        )
                                                      ],
                                                    )),
                                                  )
                                                : Text(
                                                    "${announcementModel.datePosted}\n${announcementModel.details}",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium,
                                                  ),
                                            if (isAdmin)
                                              Container(
                                                height: 100,
                                                width: 1000,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  30),
                                                          topRight:
                                                              Radius.circular(
                                                                  30)),
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
                                                        child:
                                                            const Text("Edit")),
                                                  ],
                                                ),
                                              )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
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
