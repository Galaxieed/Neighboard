import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/data/posts_data.dart';
import 'package:neighboard/models/announcement_model.dart';
import 'package:neighboard/models/notification_model.dart';
import 'package:neighboard/models/user_model.dart';
import 'package:neighboard/services/notification/notification.dart';
import 'package:neighboard/src/admin_side/announcements/announcement_function.dart';
import 'package:neighboard/src/admin_side/hoa_voting/voters/voters_function.dart';
import 'package:neighboard/src/loading_screen/loading_screen.dart';
import 'package:neighboard/src/profile_screen/profile_screen_function.dart';
import 'package:neighboard/src/user_side/community_page/ui/announcement_page/announcement_mobile.dart';
import 'package:neighboard/widgets/notification/mini_notif/elegant_notif.dart';
import 'package:neighboard/widgets/notification/notification_function.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:universal_io/io.dart';

class AdminAnnouncemetMobile extends StatefulWidget {
  const AdminAnnouncemetMobile({super.key, required this.deviceScreenType});

  final DeviceScreenType deviceScreenType;

  @override
  State<AdminAnnouncemetMobile> createState() => _AdminAnnouncemetMobileState();
}

class _AdminAnnouncemetMobileState extends State<AdminAnnouncemetMobile> {
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

  void getAllAnnouncements() async {
    announcementModels = await AnnouncementFunction.getAllAnnouncements() ?? [];
    announcementModels
        .sort((a, b) => b.announcementId.compareTo(a.announcementId));
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
      title: _postTitle,
      details: _postContent,
      timeStamp: formattedDate(),
      datePosted: formattedDate(),
      image: profileImageUrl,
    );

    bool isSuccessful =
        await AnnouncementFunction.addAnnouncement(announcementModel);

    if (isSuccessful) {
      announcementModels.add(announcementModel);
      announcementModels
          .sort((a, b) => b.announcementId.compareTo(a.announcementId));
      await sendNotifToAll();
      // ignore: use_build_context_synchronously
      successMessage(
          title: "Success!",
          desc: "Announcement successfully posted",
          context: context);
    }
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
      "New Announcement: ",
      _ctrlTitle.text,
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
        : Container(
            padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          useSafeArea: true,
                          isScrollControlled: true,
                          showDragHandle: true,
                          context: context,
                          builder: (BuildContext context) {
                            return Padding(
                              padding: MediaQuery.of(context).viewInsets,
                              child: StatefulBuilder(
                                builder: (BuildContext context,
                                    StateSetter stateSetter) {
                                  return Container(
                                    padding: const EdgeInsets.all(8),
                                    child: SingleChildScrollView(
                                      child: Form(
                                        key: _formKey,
                                        child: SizedBox(
                                          width: 720,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                "New Announcement",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleLarge,
                                                textAlign: TextAlign.center,
                                              ),
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
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText: "Type Text Here",
                                                    alignLabelWithHint: true,
                                                    border:
                                                        OutlineInputBorder(),
                                                  ),
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Please enter some text';
                                                    }
                                                    return null;
                                                  },
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
                                                                          10)),
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
                                                  profileImage != null ||
                                                          profileImageByte !=
                                                              null
                                                      ? kIsWeb
                                                          ? Text(
                                                              profileImageByte!
                                                                  .name)
                                                          : Text(profileImage!
                                                              .path)
                                                      : Container(),
                                                ],
                                              ),
                                              Align(
                                                alignment:
                                                    Alignment.bottomRight,
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                    backgroundColor:
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .inversePrimary,
                                                    foregroundColor:
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .onBackground,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 50,
                                                            vertical: 2.h),
                                                  ),
                                                  onPressed: () {
                                                    if (_formKey.currentState!
                                                        .validate()) {
                                                      _formKey.currentState!
                                                          .save();
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
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text("New Announcement"),
                    ),
                    SizedBox(width: 2.w),
                    PopupMenuButton(
                      position: PopupMenuPosition.under,
                      tooltip: "Filter announcements",
                      child: AbsorbPointer(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.sort),
                          label: const Text("Filter"),
                        ),
                      ),
                      onSelected: (value) {
                        sortAnnouncement(value);
                      },
                      itemBuilder: (BuildContext context) => _popUpMenuItem,
                    ),
                  ],
                ),
                SizedBox(
                  height: 15.h,
                ),
                if (announcementModels.isNotEmpty)
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 500,
                              child: MainAnnouncement(
                                announcementModel: announcementModels[0],
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
                              itemCount: announcementModels.length,
                              itemBuilder: (context, index) {
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
                              },
                            ),
                          ],
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
    bool isSuccess = await AnnouncementFunction.removeAnnouncement(
        announcementModel.announcementId);
    if (isSuccess) {
      // ignore: use_build_context_synchronously
      successMessage(
          title: "Success!", desc: "Refresh to see changes!", context: context);
      stateSetter();
    } else {
      // ignore: use_build_context_synchronously
      errorMessage(
          title: "Something went wrong!",
          desc: "This announcement isn't deleted!",
          context: context);
    }
  }

  updateAnnouncement(BuildContext context) async {
    if (_titleController.text.isNotEmpty &&
        _detailsController.text.isNotEmpty) {
      bool status = await AnnouncementFunction.updateAnnouncement(
          announcementModel.announcementId,
          _titleController.text,
          _detailsController.text);

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
            showModalBottomSheet(
              useSafeArea: true,
              showDragHandle: true,
              isScrollControlled: true,
              context: context,
              builder: (BuildContext context) {
                return StatefulBuilder(builder: (context, setState) {
                  return Container(
                    padding: const EdgeInsets.all(8),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Container(
                              width: 350,
                              height: 200,
                              decoration: announcementModel.image == ""
                                  ? BoxDecoration(
                                      image: const DecorationImage(
                                        image: AssetImage(noImage),
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.circular(5))
                                  : BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(
                                            announcementModel.image),
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.circular(5)),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Flexible(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                isEditing
                                    ? TextField(
                                        controller: _titleController,
                                        decoration: InputDecoration(
                                            suffixIcon: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  _titleController.text =
                                                      announcementModel.title;
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
                                                updateAnnouncement(context);
                                                Navigator.pop(context);
                                              },
                                              icon: Icon(
                                                Icons.save,
                                                color: Theme.of(context)
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
                                            .titleLarge,
                                        textAlign: TextAlign.center,
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
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  _detailsController.text =
                                                      announcementModel.details;
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
                                                updateAnnouncement(context);
                                                Navigator.pop(context);
                                              },
                                              icon: Icon(
                                                Icons.save,
                                                color: Theme.of(context)
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
                                      borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(30),
                                          topRight: Radius.circular(30)),
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
                                              removeAnnouncement(context);
                                              Navigator.pop(context);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              foregroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .onBackground,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ),
                                            child: const Text("Remove")),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                isEditing = !isEditing;
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              foregroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .background,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ),
                                            child: const Text("Edit")),
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
          child: Container(
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
                              .copyWith(fontWeight: FontWeight.bold),
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
                  AbsorbPointer(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4))),
                      child: Text(
                        'View Details',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
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
