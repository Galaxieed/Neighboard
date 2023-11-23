import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/data/posts_data.dart';
import 'package:neighboard/main.dart';
import 'package:neighboard/models/announcement_model.dart';
import 'package:neighboard/models/notification_model.dart';
import 'package:neighboard/models/user_model.dart';
import 'package:neighboard/services/notification/notification.dart';
import 'package:neighboard/src/admin_side/announcements/announcement_function.dart';
import 'package:neighboard/src/admin_side/hoa_voting/voters/voters_function.dart';
import 'package:neighboard/src/loading_screen/loading_screen.dart';
import 'package:neighboard/src/profile_screen/profile_screen_function.dart';
import 'package:neighboard/src/user_side/community_page/ui/announcement_page/announcement_desktop.dart';
import 'package:neighboard/widgets/notification/mini_notif/elegant_notif.dart';
import 'package:neighboard/widgets/notification/notification_function.dart';
import 'package:neighboard/widgets/others/tab_header.dart';
import 'package:universal_io/io.dart';

class AdminAnnouncementDesktop extends StatefulWidget {
  const AdminAnnouncementDesktop({super.key, required this.drawer});

  final Function drawer;

  @override
  State<AdminAnnouncementDesktop> createState() =>
      _AdminAnnouncementDesktopState();
}

class _AdminAnnouncementDesktopState extends State<AdminAnnouncementDesktop> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _ctrlTitle = TextEditingController();
  final TextEditingController _ctrlContent = TextEditingController();
  String _postTitle = '';
  String _postContent = '';

  File? profileImage;
  PlatformFile? profileImageByte;
  String profileImageUrl = "";

  bool isLoading = true;

  List<AnnouncementModel> announcementModels = [];
  List<AnnouncementModel> pendingAnnouncements = [];
  bool isOnPending = false;
  void getAllAnnouncements() async {
    setState(() {
      isLoading = true;
    });
    announcementModels = await AnnouncementFunction.getAllAnnouncements() ?? [];
    //get pending announcment
    pendingAnnouncements = announcementModels
        .where((element) =>
            DateTime.parse(element.timeStamp).isAfter(DateTime.now()))
        .toList();
    //check announcment schedule
    announcementModels = announcementModels
        .where((element) =>
            DateTime.parse(element.timeStamp).isBefore(DateTime.now()) ||
            DateTime.parse(element.timeStamp).isAtSameMomentAs(DateTime.now()))
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

  void _postAnnouncement() async {
    setState(() {
      isLoading = true;
    });
    if (profileImage != null || profileImageByte != null) {
      profileImageUrl = kIsWeb
          ? await ProfileFunction.uploadImageWeb(profileImageByte!.bytes!,
                  profileImageByte!.name, profileImageByte!.extension!) ??
              ""
          : await ProfileFunction.uploadImage(profileImage!) ?? "";
    }
    AnnouncementModel announcementModel = AnnouncementModel(
      announcementId: DateTime.now().toIso8601String(),
      title: profanityFilter.censor(_postTitle),
      details: profanityFilter.censor(_postContent),
      timeStamp:
          dateSet == null ? DateTime.now().toString() : dateSet.toString(),
      datePosted: formattedDate(dateSet),
      image: profileImageUrl,
    );

    bool isSuccessful =
        await AnnouncementFunction.addAnnouncement(announcementModel);

    if (isSuccessful) {
      announcementModels =
          await AnnouncementFunction.getAllAnnouncements() ?? [];
      //get pending announcment
      pendingAnnouncements = announcementModels
          .where((element) =>
              DateTime.parse(element.timeStamp).isAfter(DateTime.now()))
          .toList();
      //check announcment schedule
      announcementModels = announcementModels
          .where((element) =>
              DateTime.parse(element.timeStamp).isBefore(DateTime.now()) ||
              DateTime.parse(element.timeStamp)
                  .isAtSameMomentAs(DateTime.now()))
          .toList();
      announcementModels
          .sort((a, b) => b.announcementId.compareTo(a.announcementId));
      allAnnouncementModels = announcementModels;

      // ignore: use_build_context_synchronously
      successMessage(
          title: "Success!",
          desc: "Announcement successfully posted",
          context: context);
      setState(() {
        _ctrlTitle.clear();
        _ctrlContent.clear();
        _postTitle = '';
        _postContent = '';
        profileImage = null;
        profileImageByte = null;
        profileImageUrl = "";
        isLoading = false;
      });

      await sendNotifToAll();
    } else {
      setState(() {
        _ctrlTitle.clear();
        _ctrlContent.clear();
        _postTitle = '';
        _postContent = '';
        profileImage = null;
        profileImageByte = null;
        profileImageUrl = "";
        isLoading = false;
      });
    }
  }

  void pickImage(StateSetter modalStateSetter) async {
    if (kIsWeb) {
      FilePickerResult? result = await FilePicker.platform
          .pickFiles(allowMultiple: false, type: FileType.image);
      if (result != null) {
        profileImageByte = result.files.single;
        modalStateSetter(() {});
      }
    } else if (!kIsWeb) {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        profileImage = File(pickedImage.path);
        modalStateSetter(() {});
      }
    }
  }

  bool isTitleAsc = true, isDateAsc = false;
  void sortAnnouncement(String type) {
    setState(() {
      if (type == "title" && isTitleAsc) {
        announcementModels.sort(
            (a, b) => a.title.toUpperCase().compareTo(b.title.toUpperCase()));
        pendingAnnouncements.sort(
            (a, b) => a.title.toUpperCase().compareTo(b.title.toUpperCase()));
        isTitleAsc = !isTitleAsc;
      } else if (type == "title" && !isTitleAsc) {
        announcementModels.sort(
            (a, b) => b.title.toUpperCase().compareTo(a.title.toUpperCase()));
        pendingAnnouncements.sort(
            (a, b) => b.title.toUpperCase().compareTo(a.title.toUpperCase()));
        isTitleAsc = !isTitleAsc;
      } else if (type == "date" && isDateAsc) {
        announcementModels
            .sort((a, b) => b.announcementId.compareTo(a.announcementId));
        pendingAnnouncements
            .sort((a, b) => b.announcementId.compareTo(a.announcementId));
        isDateAsc = !isDateAsc;
      } else if (type == "date" && !isDateAsc) {
        announcementModels
            .sort((a, b) => a.announcementId.compareTo(b.announcementId));
        pendingAnnouncements
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

  List<UserModel> allUsers = [];
  getAllUsers() async {
    allUsers = await VotersFunction.getAllUsers() ?? [];
    //remove the admin from the list of users
    allUsers = allUsers.where((element) => element.role != "ADMIN").toList();
  }

  //send notif to one
  Future<void> sendNotificaton(UserModel user) async {
    await MyNotification().sendPushMessage(
      user.deviceToken,
      "New Announcement",
      'to this date: ${formattedDate(dateSet)}',
    );

    //ADD sa notification TAB
    NotificationModel notificationModel = NotificationModel(
      notifId: DateTime.now().toIso8601String(),
      notifTitle: "New Announcement: ",
      notifBody: _ctrlTitle.text,
      notifTime: formattedDate(),
      notifLocation: "ANNOUNCEMENT",
      isRead: false,
      isArchived: false,
    );

    await NotificationFunction.addNotification(notificationModel, user.userId);
  }

  //send notif to all at once
  sendNotifToAll() async {
    await Future.forEach(allUsers, sendNotificaton);
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

  DateTime? dateSet;
  int nextYear = DateTime.parse(DateTime.now().toString()).year + 1;
  int thisMonth = DateTime.parse(DateTime.now().toString()).month;
  int thisDay = DateTime.parse(DateTime.now().toString()).day;

  setDate(date) {
    setState(() {
      dateSet = date;
    });
  }

  @override
  void initState() {
    super.initState();
    getAllUsers();
    getAllAnnouncements();
  }

  @override
  void dispose() {
    _ctrlContent.dispose();
    _ctrlTitle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const LoadingScreen()
        : Scaffold(
            body: Container(
              padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 15.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  TabHeader(
                    title: "Announcements",
                    callback: () {
                      widget.drawer();
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SearchBar(
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
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            isOnPending = !isOnPending;
                          });
                        },
                        style: isOnPending
                            ? ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                foregroundColor:
                                    Theme.of(context).colorScheme.onPrimary,
                              )
                            : null,
                        icon: const Icon(Icons.timer_outlined),
                        label: const Text("Pending"),
                      ),
                      SizedBox(width: 2.w),
                      PopupMenuButton(
                        position: PopupMenuPosition.under,
                        tooltip: "Filter announcements",
                        child: AbsorbPointer(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(elevation: 5),
                            icon: const Icon(Icons.sort),
                            label: const Text("Filter"),
                          ),
                        ),
                        onSelected: (value) {
                          sortAnnouncement(value);
                        },
                        itemBuilder: (BuildContext context) => _popUpMenuItem,
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return StatefulBuilder(
                                builder: (BuildContext context,
                                    StateSetter stateSetter) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    title: Text(
                                      "New Announcement",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                    content: SingleChildScrollView(
                                      child: Form(
                                        key: _formKey,
                                        child: SizedBox(
                                          width: 720,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: TextFormField(
                                                  controller: _ctrlTitle,
                                                  onSaved: (newValue) =>
                                                      _postTitle = newValue!,
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Please enter some text';
                                                    }
                                                    return null;
                                                  },
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText:
                                                        "Enter Announcement Title",
                                                    border:
                                                        OutlineInputBorder(),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: TextFormField(
                                                  controller: _ctrlContent,
                                                  onSaved: (newValue) =>
                                                      _postContent = newValue!,
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Please enter some text';
                                                    }
                                                    return null;
                                                  },
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText: "Type Text Here",
                                                    alignLabelWithHint: true,
                                                    border:
                                                        OutlineInputBorder(),
                                                  ),
                                                  keyboardType:
                                                      TextInputType.multiline,
                                                  expands: false,
                                                  maxLines: 15,
                                                  textAlignVertical:
                                                      TextAlignVertical.top,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  ElevatedButton.icon(
                                                    icon:
                                                        const Icon(Icons.image),
                                                    label:
                                                        const Text('Add Image'),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4)),
                                                      backgroundColor:
                                                          Colors.indigo[900],
                                                      foregroundColor:
                                                          Colors.white,
                                                    ),
                                                    onPressed: () {
                                                      pickImage(stateSetter);
                                                    },
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  //this is not profileImage, this is announcementImage
                                                  profileImage != null ||
                                                          profileImageByte !=
                                                              null
                                                      ? kIsWeb
                                                          ? Expanded(
                                                              child: Text(
                                                                profileImageByte!
                                                                    .name,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            )
                                                          : Expanded(
                                                              child: Text(
                                                                profileImage!
                                                                    .path,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            )
                                                      : Container(),
                                                  ElevatedButton.icon(
                                                    onPressed: () {
                                                      showDatePicker(
                                                        context: context,
                                                        initialDate:
                                                            DateTime.now(),
                                                        firstDate:
                                                            DateTime.now(),
                                                        lastDate: DateTime(
                                                            nextYear,
                                                            thisMonth,
                                                            thisDay),
                                                      ).then((value) {
                                                        if (value != null) {
                                                          stateSetter(() {
                                                            setDate(value);
                                                          });
                                                        }
                                                      });
                                                    },
                                                    icon: const Icon(Icons
                                                        .date_range_outlined),
                                                    style: ElevatedButton.styleFrom(
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4))),
                                                    label:
                                                        const Text("Set Date"),
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  if (dateSet != null)
                                                    Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                        formattedDate(dateSet),
                                                      ),
                                                    ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    actions: <Widget>[
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4)),
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          foregroundColor: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 50, vertical: 2.h),
                                        ),
                                        onPressed: () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            _formKey.currentState!.save();
                                            _postAnnouncement();
                                            Navigator.pop(context);
                                          }
                                        },
                                        child: Text(
                                          'Post',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary,
                                              ),
                                        ),
                                      )
                                    ],
                                  );
                                },
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(elevation: 5),
                        icon: const Icon(Icons.add),
                        label: const Text("New Announcement"),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  if (isOnPending
                      ? pendingAnnouncements.isNotEmpty
                      : announcementModels.isNotEmpty)
                    Expanded(
                      child: Center(
                        child: SizedBox(
                          width: 150.w,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                SizedBox(
                                  height: MediaQuery.of(context).size.height -
                                      200.h,
                                  child: MainAnnouncement(
                                    announcementModel: isOnPending
                                        ? pendingAnnouncements[0]
                                        : announcementModels[0],
                                    stateSetter: getAllAnnouncements,
                                    isAdmin: true,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Divider(),
                                const SizedBox(
                                  height: 10,
                                ),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: isOnPending
                                      ? pendingAnnouncements.length
                                      : announcementModels.length,
                                  itemBuilder: (context, index) {
                                    if (isOnPending) {
                                      var model = pendingAnnouncements[index];
                                      if (model != pendingAnnouncements[0]) {
                                        return OtherAnnouncement(
                                          announcementModel: model,
                                          stateSetter: getAllAnnouncements,
                                          isAdmin: true,
                                        );
                                      } else {
                                        return Container();
                                      }
                                    } else {
                                      var model = announcementModels[index];
                                      if (model != announcementModels[0]) {
                                        return OtherAnnouncement(
                                          announcementModel: model,
                                          stateSetter: getAllAnnouncements,
                                          isAdmin: true,
                                        );
                                      } else {
                                        return Container();
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: Center(
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
                      ),
                    ),
                ],
              ),
            ),
          );
  }
}
