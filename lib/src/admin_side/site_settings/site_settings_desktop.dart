import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/main.dart';
import 'package:neighboard/models/site_model.dart';
import 'package:neighboard/src/admin_side/site_settings/site_settings_function.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_drawer.dart';
import 'package:neighboard/widgets/others/tab_header.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:universal_io/io.dart';

class SiteSettingsDesktop extends StatefulWidget {
  const SiteSettingsDesktop(
      {super.key, required this.drawer, required this.deviceScreenType});
  final DeviceScreenType deviceScreenType;
  final void Function() drawer;

  @override
  State<SiteSettingsDesktop> createState() => _SiteSettingsDesktopState();
}

class _SiteSettingsDesktopState extends State<SiteSettingsDesktop> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController tcHeader = TextEditingController();
  final TextEditingController tcSubHeader = TextEditingController();
  final TextEditingController tcAbout = TextEditingController();

  SiteModel? siteModel;

  File? homeImg, aboutImg, logoImg;
  PlatformFile? homeImgByte, aboutImgByte, logoImgByte;
  String homeImgUrl = "", aboutImgUrl = "", logoImgUrl = "";

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
  }

  void onSavingSettings(context) async {
    setState(() {
      isLoading = true;
    });
    if (siteModel == null) {
      await onSavingPic();
      SiteModel site = SiteModel(
        siteId: _auth.currentUser!.uid,
        siteName: '',
        siteLocation: '',
        siteHeader: tcHeader.text,
        siteSubheader: tcSubHeader.text,
        siteAbout: tcAbout.text,
        siteThemeColor: currentThemeColor.value,
        siteLogo: logoImgUrl,
        siteHomepageImage: homeImgUrl,
        siteAboutImage: aboutImgUrl,
      );

      bool isSuccessful = await SiteSettingsFunction.saveNewSiteSettings(site);

      if (isSuccessful) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Site settings successfully added"),
          ),
        );
      }
      return;
    } else {
      await onSavingPic();
      Map<String, dynamic> siteDetails = {
        'site_header': tcHeader.text,
        'site_subheader': tcSubHeader.text,
        'site_about': tcAbout.text,
        'site_theme_color': currentThemeColor.value,
        'site_logo': logoImgUrl,
        'site_homepage_image': homeImgUrl,
        'site_about_image': aboutImgUrl,
      };
      await SiteSettingsFunction.updateSiteSettings(siteDetails);
      await getSiteSettings();
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Site settings successfully updated"),
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  getSiteSettings() async {
    siteModel =
        await SiteSettingsFunction.getSiteSettings(_auth.currentUser!.uid);
    tcHeader.text = siteModel?.siteHeader ?? "";
    tcSubHeader.text = siteModel?.siteSubheader ?? "";
    tcAbout.text = siteModel?.siteAbout ?? "";
    homeImgUrl = siteModel?.siteHomepageImage ?? "";
    aboutImgUrl = siteModel?.siteAboutImage ?? "";
    logoImgUrl = siteModel?.siteLogo ?? "";

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getSiteSettings();
  }

  @override
  void dispose() {
    tcHeader.dispose();
    tcSubHeader.dispose();
    tcAbout.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical:
            widget.deviceScreenType == DeviceScreenType.desktop ? 30.h : 15.h,
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
                                  image: homeImg != null || homeImgByte != null
                                      ? kIsWeb
                                          ? MemoryImage(homeImgByte!.bytes!)
                                          : FileImage(homeImg!) as ImageProvider
                                      : siteModel?.siteHomepageImage == null
                                          ? const AssetImage(noImage)
                                              as ImageProvider
                                          : NetworkImage(
                                              siteModel?.siteHomepageImage ??
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
                                    icon: const Icon(Icons.image_outlined),
                                    label:
                                        const Text("Change 'Homepage' Image"),
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
                                          ? MemoryImage(aboutImgByte!.bytes!)
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
                                    icon: const Icon(Icons.image_outlined),
                                    label: const Text("Change 'About' Image"),
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
                            backgroundImage: logoImg != null ||
                                    logoImgByte != null
                                ? kIsWeb
                                    ? MemoryImage(logoImgByte!.bytes!)
                                    : FileImage(logoImg!) as ImageProvider
                                : siteModel?.siteLogo == null
                                    ? const AssetImage(noImage) as ImageProvider
                                    : NetworkImage(
                                        siteModel?.siteLogo ?? logoImgUrl),
                          ),
                          title: const Text("Change Logo"),
                        ),
                        const Divider(),
                        const LightDarkMode(),
                        const Divider(),
                        const ThemeColorPicker(),
                        const Divider(),
                        TextFormField(
                          controller: tcHeader,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Homepage Header",
                          ),
                          maxLines: 5,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: tcSubHeader,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Homepage Subheader",
                          ),
                          maxLines: 5,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: tcAbout,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Homepage About",
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
                                icon: const Icon(Icons.delete_outline),
                                label: const Text("Discard")),
                            const SizedBox(
                              width: 20,
                            ),
                            ElevatedButton.icon(
                                onPressed: () {
                                  onSavingSettings(context);
                                },
                                icon: const Icon(Icons.save_outlined),
                                label: const Text("Save")),
                          ],
                        ),
                        const SizedBox(
                          height: 30,
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
