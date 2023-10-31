import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/models/user_model.dart';
import 'package:neighboard/src/loading_screen/loading_screen.dart';
import 'package:neighboard/src/profile_screen/profile_screen_function.dart';
import 'package:neighboard/src/user_side/login_register_page/register_page/register_function.dart';
import 'package:neighboard/widgets/chat/chat.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_bar.dart';
import 'package:neighboard/widgets/notification/mini_notif/elegant_notif.dart';
import 'package:neighboard/widgets/notification/notification_drawer.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:universal_io/io.dart';
import 'package:flutter/services.dart';

class ProfileScreenDesktop extends StatefulWidget {
  const ProfileScreenDesktop(
      {super.key,
      required this.userId,
      required this.isAdmin,
      required this.stateSetter});
  final String userId;
  final bool isAdmin;
  final Function stateSetter;

  @override
  State<ProfileScreenDesktop> createState() => _ProfileScreenDesktopState();
}

class _ProfileScreenDesktopState extends State<ProfileScreenDesktop> {
  final TextEditingController tcFname = TextEditingController();
  final TextEditingController tcLname = TextEditingController();
  final TextEditingController tcUsername = TextEditingController();
  final TextEditingController tcEmail = TextEditingController();
  final TextEditingController tcAddress = TextEditingController();
  final TextEditingController tcCNo = TextEditingController();
  final TextEditingController tcPass = TextEditingController();
  final TextEditingController tcConfirmPass = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool passToggle = true;
  bool passToggle1 = true;
  File? profileImage;
  PlatformFile? profileImageByte;
  String profileImageUrl = "";

  UserModel? userModel;
  bool isEditing = false;
  bool isLoading = false;

  ///this is to prevent user to simultaniously upload same profile picture without
  ///changing new profile picture at all
  bool checker = false;

  bool get isCurrentUser =>
      FirebaseAuth.instance.currentUser!.uid == widget.userId;

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
    checker = true;
  }

  void onSavingPic() async {
    setState(() {
      isLoading = true;
    });
    if (profileImage != null || profileImageByte != null) {
      profileImageUrl = kIsWeb
          ? await ProfileFunction.uploadImageWeb(profileImageByte!.bytes!,
                  profileImageByte!.name, profileImageByte!.extension!) ??
              ""
          : await ProfileFunction.uploadImage(profileImage!) ?? "";
      Map<String, dynamic> profilePicture = {
        'profile_picture': profileImageUrl,
      };
      await ProfileFunction.updateUserProfile(profilePicture);
      await getCurrentUserDetails();
    }

    setState(() {
      isLoading = false;
      isEditing = false;
    });
  }

  String? currentUsername;
  void onSavingDetails() async {
    setState(() {
      isLoading = true;
    });
    bool isUsernameExist = await RegisterFunction.userExists(tcUsername.text);
    if (isUsernameExist && currentUsername != tcUsername.text) {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Neighboard Says..'),
            content:
                Text("The Username ${tcUsername.text}\nis already in use."),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      setState(() {
        isLoading = false;
      });
      return;
    }
    if (tcPass.text == tcConfirmPass.text &&
        (tcPass.text.isNotEmpty || tcConfirmPass.text.isNotEmpty)) {
      await ProfileFunction.changePassword(tcConfirmPass.text).then((value) {
        tcPass.clear();
        tcConfirmPass.clear();
      });
    }
    Map<String, dynamic> userDetails = {
      'first_name': tcFname.text,
      'last_name': tcLname.text,
      'username': tcUsername.text,
      'email': tcEmail.text,
      'address': tcAddress.text,
      'contact_no': tcCNo.text,
    };
    await ProfileFunction.updateUserProfile(userDetails);
    await getCurrentUserDetails();
    // ignore: use_build_context_synchronously
    successMessage(
        title: "Success!", desc: "Updated Successfully", context: context);
    setState(() {
      isLoading = false;
      isEditing = false;
    });
    widget.stateSetter();
  }

  getCurrentUserDetails() async {
    userModel = await ProfileFunction.getUserDetails(widget.userId);
    await controllerInitialization();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getCurrentUserDetails();
  }

  controllerInitialization() async {
    tcAddress.text = userModel!.address;
    tcCNo.text = userModel!.contactNo;
    tcEmail.text = userModel!.email;
    tcFname.text = userModel!.firstName;
    tcLname.text = userModel!.lastName;
    tcUsername.text = userModel!.username;
    currentUsername = userModel!.username;
  }

  @override
  void dispose() {
    tcAddress.dispose();
    tcCNo.dispose();
    tcEmail.dispose();
    tcFname.dispose();
    tcLname.dispose();
    tcUsername.dispose();
    super.dispose();
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
    return userModel == null || isLoading
        ? const LoadingScreen()
        : Scaffold(
            key: _scaffoldKey,
            appBar: widget.isAdmin
                ? null
                : NavBar(
                    openNotification: _openNotification,
                    openChat: _openChat,
                    currentPage: "Profile",
                  ),
            endDrawer: NotificationDrawer(
              deviceScreenType: DeviceScreenType.desktop,
              stateSetter: setState,
            ),
            body: Padding(
              padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "My Profile",
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  profilePanel1(context),
                  isEditing
                      ? editProfilePanel2(context)
                      : profilePanel2(context),
                ],
              ),
            ),
          );
  }

  Padding editProfilePanel2(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 7.w, horizontal: 7.w),
        decoration: BoxDecoration(
          border: Border.all(color: ccProfileContainerBorderColor),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  "Personal Information",
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      isEditing = false;
                    });
                  },
                  icon: const Icon(Icons.cancel),
                  label: const Text("Cancel"),
                ),
                SizedBox(
                  width: 2.w,
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      try {
                        onSavingDetails();
                      } catch (e) {
                        errorMessage(
                            title: "Error!",
                            desc: e.toString(),
                            context: context);
                      }
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: const Text("Save"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.inversePrimary,
                  ),
                )
              ],
            ),
            SizedBox(height: 20.h),
            const Divider(),
            SizedBox(height: 20.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: GridView(
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 400,
                        childAspectRatio: 400 / 200,
                        crossAxisSpacing: 10,
                      ),
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            infoTitle(context, "First Name"),
                            TextFormField(
                              controller: tcFname,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "First name is required";
                                }
                                final alpha = RegExp(r'^[a-zA-Z ]+$');
                                if (!alpha.hasMatch(value)) {
                                  return "Symbols and Numbers are not allowed.\nFor suffixes like 2nd or 3rd, use Roman Numeral letters";
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            infoTitle(context, "Last Name"),
                            TextFormField(
                              controller: tcLname,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Last name is required";
                                }
                                final alpha = RegExp(r'^[a-zA-Z]+$');
                                if (!alpha.hasMatch(value)) {
                                  return "Symbols and Numbers are not allowed.\nFor suffixes like 2nd or 3rd, use Roman Numeral letters";
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            infoTitle(context, "Username"),
                            TextFormField(
                              controller: tcUsername,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Username is required";
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                        if (!widget.isAdmin)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              infoTitle(context, "Address"),
                              TextFormField(
                                controller: tcAddress,
                              ),
                            ],
                          ),
                        if (!widget.isAdmin)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              infoTitle(context, "Contact Number"),
                              TextFormField(
                                controller: tcCNo,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d{0,11}$')),
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return null;
                                  } else if (value.length != 11) {
                                    return 'Please enter exactly 11 digits';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            infoTitle(context, "Email Address"),
                            TextFormField(
                              controller: tcEmail,
                              readOnly: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Email is required';
                                }
                                String pattern = r'\w+@\w+\.\w+';
                                RegExp regex = RegExp(pattern);
                                if (!regex.hasMatch(value)) {
                                  return 'Invalid Email format';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            infoTitle(context, "New Password"),
                            TextFormField(
                              controller: tcPass,
                              obscureText: passToggle,
                              decoration: InputDecoration(
                                suffix: InkWell(
                                  onTap: () {
                                    setState(() {
                                      passToggle = !passToggle;
                                    });
                                  },
                                  child: Icon(passToggle
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return null;
                                }
                                String pattern =
                                    r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$';
                                RegExp regex = RegExp(pattern);
                                if (!regex.hasMatch(value)) {
                                  return 'Password must be at least 8 characters, \nInclude an uppercase letter and a number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            infoTitle(context, "Confirm Password"),
                            TextFormField(
                              controller: tcConfirmPass,
                              obscureText: passToggle1,
                              decoration: InputDecoration(
                                suffix: InkWell(
                                  onTap: () {
                                    setState(() {
                                      passToggle1 = !passToggle1;
                                    });
                                  },
                                  child: Icon(passToggle
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return null;
                                }
                                if (value != tcPass.text) {
                                  return "Password does not match";
                                }
                                String pattern =
                                    r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$';
                                RegExp regex = RegExp(pattern);
                                if (!regex.hasMatch(value)) {
                                  return 'Password must be at least 8 characters, \nInclude an uppercase letter and a number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Padding profilePanel2(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 7.w, horizontal: 7.w),
        decoration: BoxDecoration(
          border: Border.all(color: ccProfileContainerBorderColor),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Personal Information",
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                isCurrentUser
                    ? ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            isEditing = true;
                          });
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text("Edit"),
                      )
                    : Container(),
              ],
            ),
            SizedBox(height: 20.h),
            const Divider(),
            SizedBox(height: 20.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: GridView(
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 400,
                      childAspectRatio: 400 / 200,
                      crossAxisSpacing: 10,
                    ),
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          infoTitle(context, "First Name"),
                          actualInfo(context, userModel!.firstName),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          infoTitle(context, "Last Name"),
                          actualInfo(context, userModel!.lastName),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          infoTitle(context, "Username"),
                          actualInfo(context, userModel!.username),
                        ],
                      ),
                      if (!widget.isAdmin)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            infoTitle(context, "Address"),
                            actualInfo(context, userModel!.address),
                          ],
                        ),
                      if (!widget.isAdmin)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            infoTitle(context, "Contact Number"),
                            actualInfo(context, userModel!.contactNo),
                          ],
                        ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          infoTitle(context, "Email Address"),
                          actualInfo(context, userModel!.email),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Text actualInfo(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }

  Text infoTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleLarge!
          .copyWith(color: ccProfileInfoTextColor),
    );
  }

  Padding profilePanel1(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 7.w, horizontal: 7.w),
        decoration: BoxDecoration(
          border: Border.all(color: ccProfileContainerBorderColor),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                userModel!.profilePicture.isEmpty
                    ? CircleAvatar(
                        radius: 80,
                        child: Image.asset(guestIcon),
                      )
                    : CircleAvatar(
                        radius: 80,
                        backgroundImage:
                            profileImage != null || profileImageByte != null
                                ? kIsWeb
                                    ? MemoryImage(profileImageByte!.bytes!)
                                    : FileImage(profileImage!) as ImageProvider
                                : NetworkImage(userModel!.profilePicture),
                      ),
                Positioned(
                  bottom: 5,
                  right: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: IconButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return StatefulBuilder(builder:
                                  (BuildContext context,
                                      StateSetter stateSetter) {
                                return updateProfilePicModal(
                                    context, stateSetter);
                              });
                            });
                      },
                      icon: const Icon(Icons.camera_alt),
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              width: 7.w,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${userModel!.firstName} ${userModel!.lastName}",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(fontWeight: FontWeight.w900, letterSpacing: 3),
                ),
                SizedBox(
                  height: 5.h,
                ),
                Text(
                  userModel!.username,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      letterSpacing: 3,
                      fontWeight: FontWeight.w700,
                      color: ccProfileUserNameTextColor),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Dialog updateProfilePicModal(BuildContext context, StateSetter stateSetter) {
    return Dialog(
      child: Container(
        width: 700,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Change Profile Picture",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Stack(
              children: [
                CircleAvatar(
                  radius: 120,
                  backgroundImage:
                      profileImage != null || profileImageByte != null
                          ? kIsWeb
                              ? MemoryImage(profileImageByte!.bytes!)
                              : FileImage(profileImage!) as ImageProvider
                          : userModel!.profilePicture == ""
                              ? const AssetImage(guestIcon) as ImageProvider
                              : NetworkImage(userModel!.profilePicture),
                ),
                Positioned(
                  bottom: 15,
                  right: 15,
                  child: CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: IconButton(
                      onPressed: () {
                        try {
                          pickImage(stateSetter);
                        } catch (e) {
                          errorMessage(
                              title: "Error!",
                              desc: e.toString(),
                              context: context);
                        }
                      },
                      icon: const Icon(Icons.camera_alt),
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
            const Divider(),
            const SizedBox(
              height: 16,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    profileImage = null;
                    profileImageByte = null;
                    profileImageUrl = "";
                    checker = false;
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size.fromWidth(150),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    backgroundColor: Colors.red[800],
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.cancel),
                  label: const Text("Cancel"),
                ),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    try {
                      if ((profileImage != null || profileImageByte != null) &&
                          checker) {
                        onSavingPic();
                        Navigator.pop(context);
                        successMessage(
                            title: "Success!",
                            desc: "Profile Picture Updated",
                            context: context);
                        //This will now allow user to upload picture
                        checker = false;
                        setState(() {});
                      } else {
                        infoMessage(
                            title: "Info!",
                            desc: "No changes",
                            context: context);
                      }
                    } catch (e) {
                      errorMessage(
                          title: "Error!",
                          desc: e.toString(),
                          context: context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size.fromWidth(150),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  icon: const Icon(Icons.save),
                  label: const Text("Save"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
