import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/data/posts_data.dart';
import 'package:neighboard/main.dart';
import 'package:neighboard/models/candidates_model.dart';
import 'package:neighboard/models/notification_model.dart';
import 'package:neighboard/models/site_model.dart';
import 'package:neighboard/models/user_model.dart';
import 'package:neighboard/services/notification/notification.dart';
import 'package:neighboard/src/admin_side/hoa_voting/voters/voters_function.dart';
import 'package:neighboard/src/admin_side/site_settings/site_settings_function.dart';
import 'package:neighboard/src/loading_screen/loading_screen.dart';
import 'package:neighboard/src/profile_screen/profile_screen_function.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_drawer.dart';
import 'package:neighboard/widgets/notification/mini_notif/elegant_notif.dart';
import 'package:neighboard/widgets/notification/notification_function.dart';
import 'package:neighboard/widgets/others/tab_header.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:universal_io/io.dart';

class SiteSettingsDesktop extends StatefulWidget {
  const SiteSettingsDesktop({
    super.key,
    required this.drawer,
    required this.deviceScreenType,
  });
  final DeviceScreenType deviceScreenType;
  final void Function() drawer;

  @override
  State<SiteSettingsDesktop> createState() => _SiteSettingsDesktopState();
}

class _SiteSettingsDesktopState extends State<SiteSettingsDesktop> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController tcHeader = TextEditingController();
  final TextEditingController tcSubdName = TextEditingController();
  final TextEditingController tcSubHeader = TextEditingController();
  final TextEditingController tcAbout = TextEditingController();

  SiteModel? siteModel;

  File? homeImg, aboutImg, logoImg, logoImgDark;
  PlatformFile? homeImgByte, aboutImgByte, logoImgByte, logoImgByteDark;
  String homeImgUrl = "",
      aboutImgUrl = "",
      logoImgUrl = "",
      logoImgUrlDark = "";

  bool isLoading = true;

  void pickImage(img) async {
    if (img == 'home') {
      if (kIsWeb) {
        FilePickerResult? result = await FilePicker.platform
            .pickFiles(allowMultiple: false, type: FileType.image);
        if (result != null) {
          homeImgByte = result.files.single;
        }
      } else if (!kIsWeb) {
        final pickedImage =
            await ImagePicker().pickImage(source: ImageSource.gallery);
        if (pickedImage != null) {
          homeImg = File(pickedImage.path);
        }
      }
    } else if (img == 'about') {
      if (kIsWeb) {
        FilePickerResult? result = await FilePicker.platform
            .pickFiles(allowMultiple: false, type: FileType.image);
        if (result != null) {
          aboutImgByte = result.files.single;
        }
      } else if (!kIsWeb) {
        final pickedImage =
            await ImagePicker().pickImage(source: ImageSource.gallery);
        if (pickedImage != null) {
          aboutImg = File(pickedImage.path);
        }
      }
    } else if (img == 'logo') {
      if (kIsWeb) {
        FilePickerResult? result = await FilePicker.platform
            .pickFiles(allowMultiple: false, type: FileType.image);
        if (result != null) {
          logoImgByte = result.files.single;
        }
      } else if (!kIsWeb) {
        final pickedImage =
            await ImagePicker().pickImage(source: ImageSource.gallery);
        if (pickedImage != null) {
          logoImg = File(pickedImage.path);
        }
      }
    } else if (img == 'logoDark') {
      if (kIsWeb) {
        FilePickerResult? result = await FilePicker.platform
            .pickFiles(allowMultiple: false, type: FileType.image);
        if (result != null) {
          logoImgByteDark = result.files.single;
        }
      } else if (!kIsWeb) {
        final pickedImage =
            await ImagePicker().pickImage(source: ImageSource.gallery);
        if (pickedImage != null) {
          logoImgDark = File(pickedImage.path);
        }
      }
    }
    setState(() {});
  }

  onSavingPic() async {
    if (homeImg != null || homeImgByte != null) {
      homeImgUrl = kIsWeb
          ? await SiteSettingsFunction.uploadImageWeb(homeImgByte!.bytes!,
                  homeImgByte!.name, homeImgByte!.extension!) ??
              ""
          : await SiteSettingsFunction.uploadImage(homeImg!) ?? "";
    }
    if (aboutImg != null || aboutImgByte != null) {
      aboutImgUrl = kIsWeb
          ? await SiteSettingsFunction.uploadImageWeb(aboutImgByte!.bytes!,
                  aboutImgByte!.name, aboutImgByte!.extension!) ??
              ""
          : await SiteSettingsFunction.uploadImage(aboutImg!) ?? "";
    }
    if (logoImg != null || logoImgByte != null) {
      logoImgUrl = kIsWeb
          ? await SiteSettingsFunction.uploadImageWeb(logoImgByte!.bytes!,
                  logoImgByte!.name, logoImgByte!.extension!) ??
              ""
          : await SiteSettingsFunction.uploadImage(logoImg!) ?? "";
    }
    if (logoImgDark != null || logoImgByteDark != null) {
      logoImgUrlDark = kIsWeb
          ? await SiteSettingsFunction.uploadImageWeb(logoImgByteDark!.bytes!,
                  logoImgByteDark!.name, logoImgByteDark!.extension!) ??
              ""
          : await SiteSettingsFunction.uploadImage(logoImgDark!) ?? "";
    }
  }

  void onSavingSettings(context) async {
    setState(() {
      isLoading = true;
    });
    if (siteModel == null) {
      await onSavingPic();
      SiteModel site = SiteModel(
        siteId: _auth.currentUser!.uid,
        siteSubdName: tcSubdName.text,
        siteLocation: '',
        siteHeader: tcHeader.text,
        siteSubheader: tcSubHeader.text,
        siteAbout: tcAbout.text,
        siteThemeColor: currentThemeColor.value,
        siteLogo: logoImgUrl,
        siteLogoDark: logoImgUrlDark,
        siteHomepageImage: homeImgUrl,
        siteAboutImage: aboutImgUrl,
      );

      bool isSuccessful = await SiteSettingsFunction.saveNewSiteSettings(site);

      if (isSuccessful) {
        await sendNotifToAll();
        successMessage(
            title: "Success!",
            desc: "Site settings successfully added",
            context: context);
      }
      return;
    } else {
      await onSavingPic();
      Map<String, dynamic> siteDetails = {
        'site_header': tcHeader.text,
        'site_subd_name': tcSubdName.text,
        'site_subheader': tcSubHeader.text,
        'site_about': tcAbout.text,
        'site_theme_color': currentThemeColor.value,
        'site_logo': logoImgUrl,
        'site_logo_dark': logoImgUrlDark,
        'site_homepage_image': homeImgUrl,
        'site_about_image': aboutImgUrl,
      };
      await SiteSettingsFunction.updateSiteSettings(siteDetails);
      await getSiteSettings();
      await sendNotifToAll();
      // ignore: use_build_context_synchronously
      successMessage(
          title: "Success!",
          desc: "Site settings successfully updated",
          context: context);
    }

    setState(() {
      isLoading = false;
    });
  }

  getSiteSettings() async {
    siteModel =
        await SiteSettingsFunction.getSiteSettings(_auth.currentUser!.uid);
    tcHeader.text = siteModel?.siteHeader ?? "";
    tcSubdName.text = siteModel?.siteSubdName ?? "";
    tcSubHeader.text = siteModel?.siteSubheader ?? "";
    tcAbout.text = siteModel?.siteAbout ?? "";
    homeImgUrl = siteModel?.siteHomepageImage ?? "";
    aboutImgUrl = siteModel?.siteAboutImage ?? "";
    logoImgUrl = siteModel?.siteLogo ?? "";
    logoImgUrlDark = siteModel?.siteLogoDark ?? "";

    setState(() {
      isLoading = false;
    });
  }

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
      "Site Settings had changed: ",
      "Refresh to see changes.",
    );

    //ADD sa notification TAB
    NotificationModel notificationModel = NotificationModel(
      notifId: DateTime.now().toIso8601String(),
      notifTitle: "Site Settings had changed: ",
      notifBody: "Refresh to see changes.",
      notifTime: formattedDate(),
      notifLocation: "SITE",
      isRead: false,
      isArchived: false,
    );

    await NotificationFunction.addNotification(notificationModel, user.userId);
  }

  //send notif to all at once
  sendNotifToAll() async {
    await Future.forEach(allUsers, sendNotificaton);
  }

  editOfficer(doc, officerDetails, candidateId) async {
    await SiteSettingsFunction.updateOfficers(
        doc, officerDetails, mainElectionModel!.electionId, candidateId);
    await getOfficers();
    setState(() {});
  }

  List<CandidateModel> officersModel = [];
  CandidateModel? presModel,
      vpModel,
      secModel,
      astSecModel,
      tresModel,
      audModel,
      astAudModel;
  List<CandidateModel> bodModels = [];
  getOfficers() async {
    officersModel.clear();
    officersModel =
        await SiteSettingsFunction.getOfficers(_auth.currentUser!.uid) ?? [];
    if (officersModel.isNotEmpty) {
      presModel = officersModel
          .where((element) => element.position == "PRESIDENT")
          .take(1)
          .toList()[0];
      vpModel = officersModel
          .where((element) => element.position == "VICE PRESIDENT")
          .take(1)
          .toList()[0];
      secModel = officersModel
          .where((element) => element.position == "SECRETARY")
          .take(1)
          .toList()[0];
      astSecModel = officersModel
          .where((element) => element.position == "ASSISTANT SECRETARY")
          .take(1)
          .toList()[0];
      tresModel = officersModel
          .where((element) => element.position == "TREASURER")
          .take(1)
          .toList()[0];
      audModel = officersModel
          .where((element) => element.position == "AUDITOR")
          .take(1)
          .toList()[0];
      astAudModel = officersModel
          .where((element) => element.position == "ASSISTANT AUDITOR")
          .take(1)
          .toList()[0];
      bodModels = officersModel
          .where((element) => element.position == "BOARD OF DIRECTORS")
          .take(8)
          .toList();
    }
  }

  @override
  void initState() {
    super.initState();
    getAllUsers();
    getOfficers();
    getSiteSettings();
  }

  @override
  void dispose() {
    tcHeader.dispose();
    tcSubdName.dispose();
    tcSubHeader.dispose();
    tcAbout.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const LoadingScreen()
        : Container(
            padding: EdgeInsets.symmetric(
              vertical: widget.deviceScreenType == DeviceScreenType.desktop
                  ? 30.h
                  : 15.h,
              horizontal: 15.w,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.deviceScreenType == DeviceScreenType.desktop)
                  TabHeader(
                    title: "Site Settings",
                    callback: () {
                      widget.drawer();
                    },
                  ),
                if (widget.deviceScreenType == DeviceScreenType.desktop)
                  const SizedBox(
                    height: 20,
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: SizedBox(
                        width: 1024,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GridView(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                gridDelegate:
                                    const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 500,
                                  childAspectRatio: 500 / 400,
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 20,
                                ),
                                children: [
                                  Stack(
                                    children: [
                                      Image(
                                        image: homeImg != null ||
                                                homeImgByte != null
                                            ? kIsWeb
                                                ? MemoryImage(
                                                    homeImgByte!.bytes!)
                                                : FileImage(homeImg!)
                                                    as ImageProvider
                                            : siteModel?.siteHomepageImage ==
                                                    null
                                                ? const AssetImage(noImage)
                                                    as ImageProvider
                                                : NetworkImage(siteModel
                                                        ?.siteHomepageImage ??
                                                    homeImgUrl),
                                        fit: BoxFit.cover,
                                        width: 550,
                                        height: 400,
                                      ),
                                      Positioned(
                                        bottom: 10,
                                        left: 10,
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            pickImage('home');
                                          },
                                          icon:
                                              const Icon(Icons.image_outlined),
                                          label: const Text(
                                              "Change 'Homepage' Image"),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Stack(
                                    children: [
                                      Image(
                                        image: aboutImg != null ||
                                                aboutImgByte != null
                                            ? kIsWeb
                                                ? MemoryImage(
                                                    aboutImgByte!.bytes!)
                                                : FileImage(aboutImg!)
                                                    as ImageProvider
                                            : siteModel?.siteAboutImage == null
                                                ? const AssetImage(noImage)
                                                    as ImageProvider
                                                : NetworkImage(
                                                    siteModel?.siteAboutImage ??
                                                        aboutImgUrl),
                                        fit: BoxFit.cover,
                                        width: 550,
                                        height: 400,
                                      ),
                                      Positioned(
                                        bottom: 10,
                                        left: 10,
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            pickImage('about');
                                          },
                                          icon:
                                              const Icon(Icons.image_outlined),
                                          label: const Text(
                                              "Change 'About' Image"),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Divider(),
                              ListTile(
                                onTap: () {
                                  pickImage('logo');
                                },
                                leading: CircleAvatar(
                                  backgroundColor: Colors.white54,
                                  backgroundImage: logoImg != null ||
                                          logoImgByte != null
                                      ? kIsWeb
                                          ? MemoryImage(logoImgByte!.bytes!)
                                          : FileImage(logoImg!) as ImageProvider
                                      : siteModel?.siteLogo == null
                                          ? const AssetImage(noImage)
                                              as ImageProvider
                                          : NetworkImage(siteModel?.siteLogo ??
                                              logoImgUrl),
                                ),
                                title: const Text("Change Logo"),
                              ),
                              const Divider(),
                              ListTile(
                                onTap: () {
                                  pickImage('logoDark');
                                },
                                leading: CircleAvatar(
                                  backgroundColor: Colors.black54,
                                  backgroundImage: logoImgDark != null ||
                                          logoImgByteDark != null
                                      ? kIsWeb
                                          ? MemoryImage(logoImgByteDark!.bytes!)
                                          : FileImage(logoImgDark!)
                                              as ImageProvider
                                      : siteModel?.siteLogoDark == null
                                          ? const AssetImage(noImage)
                                              as ImageProvider
                                          : NetworkImage(
                                              siteModel?.siteLogoDark ??
                                                  logoImgUrlDark),
                                ),
                                title: const Text("Change Logo (Darkmode)"),
                              ),
                              const Divider(),
                              const LightDarkMode(),
                              const Divider(),
                              const ThemeColorPicker(),
                              const Divider(),
                              const SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                controller: tcSubdName,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "Subdivision Name",
                                  alignLabelWithHint: true,
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                controller: tcHeader,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "Homepage Header",
                                  alignLabelWithHint: true,
                                ),
                                maxLines: 5,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                controller: tcSubHeader,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "Homepage Subheader",
                                  alignLabelWithHint: true,
                                ),
                                maxLines: 5,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                controller: tcAbout,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "Homepage About",
                                  alignLabelWithHint: true,
                                ),
                                maxLines: 10,
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton.icon(
                                      onPressed: () {
                                        getSiteSettings();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        foregroundColor: Colors.red,
                                      ),
                                      icon: const Icon(Icons.delete_outline),
                                      label: const Text("Discard")),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  ElevatedButton.icon(
                                      onPressed: () {
                                        onSavingSettings(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .inversePrimary,
                                        foregroundColor: Theme.of(context)
                                            .colorScheme
                                            .onBackground,
                                      ),
                                      icon: const Icon(Icons.save_outlined),
                                      label: const Text("Save")),
                                ],
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              const Divider(),
                              if (officersModel.isNotEmpty)
                                Text(
                                  "Officers",
                                  textAlign: TextAlign.start,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              if (officersModel.isNotEmpty)
                                GridView(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 350,
                                    childAspectRatio: 250 / 250,
                                    mainAxisSpacing: 10,
                                    crossAxisSpacing: 10,
                                  ),
                                  children: [
                                    OfficerAvatar(
                                        deviceScreenType:
                                            widget.deviceScreenType,
                                        editOfficerCallback: editOfficer,
                                        doc: "president",
                                        officerModel: presModel!,
                                        position: "President"),
                                    OfficerAvatar(
                                        deviceScreenType:
                                            widget.deviceScreenType,
                                        editOfficerCallback: editOfficer,
                                        doc: "vice_president",
                                        officerModel: vpModel!,
                                        position: "Vice President"),
                                    OfficerAvatar(
                                        deviceScreenType:
                                            widget.deviceScreenType,
                                        editOfficerCallback: editOfficer,
                                        doc: "secretary",
                                        officerModel: secModel!,
                                        position: "Secretary"),
                                    OfficerAvatar(
                                        deviceScreenType:
                                            widget.deviceScreenType,
                                        editOfficerCallback: editOfficer,
                                        doc: "assistant_secretary",
                                        officerModel: astSecModel!,
                                        position: "Assistant Secretary"),
                                    OfficerAvatar(
                                        deviceScreenType:
                                            widget.deviceScreenType,
                                        editOfficerCallback: editOfficer,
                                        doc: "treasurer",
                                        officerModel: tresModel!,
                                        position: "Treasurer"),
                                    OfficerAvatar(
                                        deviceScreenType:
                                            widget.deviceScreenType,
                                        editOfficerCallback: editOfficer,
                                        doc: "auditor",
                                        officerModel: audModel!,
                                        position: "Auditor"),
                                    OfficerAvatar(
                                        deviceScreenType:
                                            widget.deviceScreenType,
                                        editOfficerCallback: editOfficer,
                                        doc: "assistant_auditor",
                                        officerModel: astAudModel!,
                                        position: "Assistant Auditor"),
                                    OfficerAvatar(
                                        deviceScreenType:
                                            widget.deviceScreenType,
                                        editOfficerCallback: editOfficer,
                                        doc: "bod_1",
                                        officerModel: bodModels[0],
                                        position: "Board of Director"),
                                    OfficerAvatar(
                                        deviceScreenType:
                                            widget.deviceScreenType,
                                        editOfficerCallback: editOfficer,
                                        doc: "bod_2",
                                        officerModel: bodModels[1],
                                        position: "Board of Director"),
                                    OfficerAvatar(
                                        deviceScreenType:
                                            widget.deviceScreenType,
                                        editOfficerCallback: editOfficer,
                                        doc: "bod_3",
                                        officerModel: bodModels[2],
                                        position: "Board of Director"),
                                    OfficerAvatar(
                                        deviceScreenType:
                                            widget.deviceScreenType,
                                        editOfficerCallback: editOfficer,
                                        doc: "bod_4",
                                        officerModel: bodModels[3],
                                        position: "Board of Director"),
                                    OfficerAvatar(
                                        deviceScreenType:
                                            widget.deviceScreenType,
                                        editOfficerCallback: editOfficer,
                                        doc: "bod_5",
                                        officerModel: bodModels[4],
                                        position: "Board of Director"),
                                    OfficerAvatar(
                                        deviceScreenType:
                                            widget.deviceScreenType,
                                        editOfficerCallback: editOfficer,
                                        doc: "bod_6",
                                        officerModel: bodModels[5],
                                        position: "Board of Director"),
                                    OfficerAvatar(
                                        deviceScreenType:
                                            widget.deviceScreenType,
                                        editOfficerCallback: editOfficer,
                                        doc: "bod_7",
                                        officerModel: bodModels[6],
                                        position: "Board of Director"),
                                    OfficerAvatar(
                                        deviceScreenType:
                                            widget.deviceScreenType,
                                        editOfficerCallback: editOfficer,
                                        doc: "bod_8",
                                        officerModel: bodModels[7],
                                        position: "Board of Director"),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}

class OfficerAvatar extends StatefulWidget {
  const OfficerAvatar({
    super.key,
    required this.officerModel,
    required this.position,
    required this.doc,
    required this.deviceScreenType,
    required this.editOfficerCallback,
  });

  final CandidateModel officerModel;
  final String position;
  final String doc;
  final DeviceScreenType deviceScreenType;
  final Function editOfficerCallback;

  @override
  State<OfficerAvatar> createState() => _OfficerAvatarState();
}

class _OfficerAvatarState extends State<OfficerAvatar> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fNameController = TextEditingController();
  final TextEditingController _lNameController = TextEditingController();
  File? profileImage;
  PlatformFile? profileImageByte;
  String profileImageUrl = "";
  bool _isHovering = false;

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

  Future<void> onSavingPic(ppImage, ppImageByte) async {
    if (ppImage != null || ppImageByte != null) {
      profileImageUrl = kIsWeb
          ? await ProfileFunction.uploadImageWeb(ppImageByte!.bytes!,
                  ppImageByte!.name, ppImageByte!.extension!) ??
              ""
          : await ProfileFunction.uploadImage(ppImage!) ?? "";
    }
  }

  void onClearForm() {
    _fNameController.text = widget.officerModel.firstName;
    _lNameController.text = widget.officerModel.lastName;
    profileImage = null;
    profileImageByte = null;
    profileImageUrl = widget.officerModel.profilePicture;
  }

  editOfficer() async {
    await onSavingPic(profileImage, profileImageByte);
    Map<String, dynamic> officerDetails = {
      'first_name': _fNameController.text,
      'last_name': _lNameController.text,
      'profile_picture': profileImageUrl,
    };
    // ignore: use_build_context_synchronously
    successMessage(
        title: "Success!", desc: "Officer was updated", context: context);
    widget.editOfficerCallback(
        widget.doc, officerDetails, widget.officerModel.candidateId);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    profileImageUrl = widget.officerModel.profilePicture;
    _fNameController.text = widget.officerModel.firstName;
    _lNameController.text = widget.officerModel.lastName;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _fNameController.dispose();
    _lNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        widget.deviceScreenType == DeviceScreenType.mobile
            ? InkWell(
                onTap: () {
                  setState(() => _isHovering = !_isHovering);
                },
                splashColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: officerAvatar(context),
              )
            : MouseRegion(
                onEnter: (_) => setState(() => _isHovering = true),
                onExit: (_) => setState(() => _isHovering = false),
                child: officerAvatar(context),
              ),
        const SizedBox(
          height: 10,
        ),
        Text(
          "${widget.officerModel.firstName} ${widget.officerModel.lastName}",
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          widget.position,
          style: Theme.of(context).textTheme.titleMedium!,
        ),
      ],
    );
  }

  CircleAvatar officerAvatar(BuildContext context) {
    return CircleAvatar(
      radius: 100,
      backgroundColor:
          _isHovering ? Theme.of(context).colorScheme.inversePrimary : null,
      child: ClipOval(
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 95,
              child: widget.officerModel.profilePicture == ""
                  ? Image.asset(guestIcon)
                  : FadeInImage.assetNetwork(
                      placeholder: guestIcon,
                      image: widget.officerModel.profilePicture),
            ),
            if (_isHovering)
              CircleAvatar(
                radius: 95,
                backgroundColor: Theme.of(context).primaryColor.withOpacity(.3),
                child: ElevatedButton(
                  onPressed: () {
                    widget.deviceScreenType == DeviceScreenType.mobile
                        ? showModalBottomSheet(
                            isScrollControlled: true,
                            useSafeArea: true,
                            showDragHandle: true,
                            context: context,
                            builder: (context) {
                              return Padding(
                                padding: MediaQuery.of(context).viewInsets,
                                child: thisOfficerModal(widget.officerModel),
                              );
                            })
                        : showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: thisOfficerModal(widget.officerModel),
                              );
                            });
                  },
                  child: const Text("Edit"),
                ),
              )
          ],
        ),
      ),
    );
  }

  StatefulBuilder thisOfficerModal(CandidateModel officer) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter mySetState) => Container(
        padding: const EdgeInsets.all(8.0),
        width: widget.deviceScreenType == DeviceScreenType.mobile
            ? double.infinity
            : 350,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Edit Officer",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 80,
                        backgroundImage: profileImage != null ||
                                profileImageByte != null
                            ? kIsWeb
                                ? MemoryImage(profileImageByte!.bytes!)
                                : FileImage(profileImage!) as ImageProvider
                            : officer.profilePicture == ""
                                ? const AssetImage(guestIcon) as ImageProvider
                                : NetworkImage(officer.profilePicture),
                      ),
                      Positioned(
                        bottom: 5,
                        right: 8,
                        child: CircleAvatar(
                          backgroundColor: Colors.grey,
                          child: IconButton(
                            onPressed: () {
                              //update picture
                              pickImage(mySetState);
                            },
                            icon: const Icon(Icons.camera_alt),
                            color: Colors.white,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  myTextFormField(_fNameController, "First Name"),
                  const SizedBox(
                    height: 20,
                  ),
                  myTextFormField(_lNameController, "Last Name"),
                  const SizedBox(
                    height: 60,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          mySetState(() {
                            onClearForm();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          foregroundColor: Colors.red,
                        ),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text("Discard"),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            editOfficer();
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          backgroundColor:
                              Theme.of(context).colorScheme.inversePrimary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onBackground,
                        ),
                        icon: const Icon(Icons.save),
                        label: const Text("Save"),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextFormField myTextFormField(controller, label, [maxlines]) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        label: Text(label),
        alignLabelWithHint: true,
      ),
      validator: (value) {
        if (value == '' || value == null) {
          return "Enter value to this field";
        }
        return null;
      },
      maxLines: maxlines,
    );
  }
}
