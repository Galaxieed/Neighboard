import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neighboard/data/posts_data.dart';
import 'package:neighboard/models/announcement_model.dart';
import 'package:neighboard/src/admin_side/announcements/announcement_function.dart';
import 'package:neighboard/src/loading_screen/loading_screen.dart';
import 'package:neighboard/src/profile_screen/profile_screen_function.dart';
import 'package:neighboard/src/user_side/community_page/ui/announcement_page/announcement_desktop.dart';
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

  void getAllAnnouncements() async {
    announcementModels = await AnnouncementFunction.getAllAnnouncements() ?? [];
    announcementModels.sort((a, b) => b.datePosted.compareTo(a.datePosted));
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
      announcementModels.sort((a, b) => b.datePosted.compareTo(a.datePosted));
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Announcement successfully posted"),
        ),
      );
    }
    setState(() {
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
    // TODO: implement initState
    super.initState();
    getAllAnnouncements();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _ctrlContent.dispose();
    _ctrlTitle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const LoadingScreen()
        : Container(
            padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 15.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TabHeader(
                  title: "Announcements",
                  callback: () {
                    widget.drawer();
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                              builder: (BuildContext context,
                                  StateSetter stateSetter) {
                                return AlertDialog(
                                  title: Text(
                                    "New Announcement",
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
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
                                                decoration:
                                                    const InputDecoration(
                                                  labelText:
                                                      "Enter Announcement Title",
                                                  border: OutlineInputBorder(),
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
                                                  border: OutlineInputBorder(),
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
                                                  icon: const Icon(Icons.image),
                                                  label:
                                                      const Text('Add Image'),
                                                  style:
                                                      ElevatedButton.styleFrom(
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
                                                        profileImageByte != null
                                                    ? kIsWeb
                                                        ? Text(profileImageByte!
                                                            .name)
                                                        : Text(
                                                            profileImage!.path)
                                                    : Container(),
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
                                                BorderRadius.circular(10)),
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .inversePrimary,
                                        foregroundColor: Theme.of(context)
                                            .colorScheme
                                            .onBackground,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 50, vertical: 2.h),
                                      ),
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
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
                                                fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  ],
                                );
                              },
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
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 45.w,
                      right: 45.w,
                      top: 20.h,
                      bottom: 20.h,
                    ),
                    child: MainAnnouncement(
                        announcementModel: announcementModels[0]),
                  ),
                ),
              ],
            ),
          );
  }
}
