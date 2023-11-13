import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/main.dart';
import 'package:neighboard/models/user_model.dart';
import 'package:neighboard/routes/routes.dart';
import 'package:neighboard/src/loading_screen/loading_screen.dart';
import 'package:neighboard/src/profile_screen/profile_screen_function.dart';
import 'package:neighboard/src/user_side/login_register_page/register_page/register_function.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_bar.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_drawer.dart';
import 'package:neighboard/widgets/notification/mini_notif/elegant_notif.dart';
import "package:responsive_builder/responsive_builder.dart";
import 'package:universal_io/io.dart';

class ProfileScreenMobile extends StatefulWidget {
  const ProfileScreenMobile(
      {super.key,
      required this.deviceScreenType,
      required this.userId,
      required this.isAdmin});
  final DeviceScreenType deviceScreenType;
  final String userId;
  final bool isAdmin;

  @override
  State<ProfileScreenMobile> createState() => _ProfileScreenMobileState();
}

class _ProfileScreenMobileState extends State<ProfileScreenMobile> {
  final TextEditingController tcFname = TextEditingController();
  final TextEditingController tcLname = TextEditingController();
  final TextEditingController tcUsername = TextEditingController();
  final TextEditingController tcEmail = TextEditingController();
  final TextEditingController tcBlock = TextEditingController();
  final TextEditingController tcLot = TextEditingController();
  final TextEditingController tcCNo = TextEditingController();
  final TextEditingController tcPass = TextEditingController();
  final TextEditingController tcConfirmPass = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool passToggle = true;
  bool passToggle1 = true;
  File? profileImage;
  PlatformFile? profileImageByte;
  String profileImageUrl = "", street = "";

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
        tcPass.text.isNotEmpty &&
        tcConfirmPass.text.isNotEmpty) {
      await ProfileFunction.changePassword(tcConfirmPass.text);
      tcPass.clear();
      tcConfirmPass.clear();
    }
    Map<String, dynamic> userDetails = {
      'first_name': tcFname.text,
      'last_name': tcLname.text,
      'username': tcUsername.text,
      'email': tcEmail.text,
      'address': "Blk ${tcBlock.text} Lot ${tcLot.text}, $street",
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
  }

  getCurrentUserDetails() async {
    userModel = await ProfileFunction.getUserDetails(widget.userId);
    await controllerInitialization();
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getCurrentUserDetails();
  }

  controllerInitialization() async {
    try {
      tcBlock.text = userModel!.address.split(' ')[1];
      tcLot.text =
          userModel!.address.split(' ')[3].replaceFirst(RegExp(r','), '');
      List<String> addressParts = userModel!.address.split(', ');
      if (addressParts.length >= 2) {
        street = addressParts[1];
      } else {
        // Handle the case where the split result doesn't have enough elements.
        print('Error: userModel.address does not have enough parts');
      }
    } catch (e) {
      print(e);
    }
    tcCNo.text = userModel!.contactNo.isNotEmpty
        ? int.parse(userModel!.contactNo).toString()
        : "";
    tcEmail.text = userModel!.email;
    tcFname.text = userModel!.firstName;
    tcLname.text = userModel!.lastName;
    tcUsername.text = userModel!.username;
    currentUsername = userModel!.username;
  }

  @override
  void dispose() {
    tcBlock.dispose();
    tcLot.dispose();
    tcCNo.dispose();
    tcEmail.dispose();
    tcFname.dispose();
    tcLname.dispose();
    tcUsername.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return userModel == null || isLoading
        ? const LoadingScreen()
        : Scaffold(
            appBar: widget.isAdmin
                ? null
                : AppBar(
                    actions: [
                      NavBarCircularImageDropDownButton(
                        callback: Routes().navigate,
                        isAdmin: widget.isAdmin,
                      ),
                      SizedBox(
                        width: 2.5.w,
                      )
                    ],
                  ),
            drawer: widget.deviceScreenType == DeviceScreenType.mobile
                ? const NavDrawer()
                : null,
            body: Container(
              padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 15.h),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      "MY PROFILE",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
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
            SizedBox(height: 20.h),
            Row(
              children: [
                Text(
                  "Personal \nInformation",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton.filledTonal(
                  onPressed: () {
                    setState(() {
                      isEditing = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).disabledColor.withOpacity(.1),
                  ),
                  icon: const Icon(Icons.cancel),
                  tooltip: "Cancel",
                ),
                const SizedBox(
                  width: 10,
                ),
                IconButton.filledTonal(
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  icon: const Icon(Icons.save),
                  tooltip: "Save",
                ),
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
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 400,
                        childAspectRatio: 400 / 150,
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
                                  return "Symbols and Numbers are not allowed.";
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
                                final alpha = RegExp(r'^[a-zA-Z ]+$');
                                if (!alpha.hasMatch(value)) {
                                  return "Symbols and Numbers are not allowed.";
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            infoTitle(context, "Address"),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text("Block"),
                                const SizedBox(width: 5),
                                TextFormField(
                                  controller: tcBlock,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d{0,2}$'),
                                    ),
                                  ],
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    border: OutlineInputBorder(),
                                    constraints: BoxConstraints(
                                      maxWidth: 50,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                const Text("Lot"),
                                const SizedBox(width: 5),
                                TextFormField(
                                  controller: tcLot,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d{0,2}$'),
                                    ),
                                  ],
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    border: OutlineInputBorder(),
                                    constraints: BoxConstraints(
                                      maxWidth: 50,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: DropdownButtonFormField(
                                    onChanged: (value) {
                                      setState(() {
                                        street = value.toString();
                                      });
                                    },
                                    items: siteModel == null
                                        ? []
                                        : siteModel!.siteStreets
                                            .map((String e) {
                                            return DropdownMenuItem<String>(
                                              value: e,
                                              child: Text(e),
                                            );
                                          }).toList(),
                                    //value: street,
                                    hint: const Text('Street'),
                                    value: street.isEmpty ? null : street,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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
                                  RegExp(r'^\d{0,10}$'),
                                ),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return null;
                                } else if (value.length != 10) {
                                  return 'Please enter exactly 10 digits';
                                }
                                return null;
                              },
                              decoration:
                                  const InputDecoration(prefix: Text("+63")),
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
                                  return 'Atleast 8 characters\nand an uppercase letter and a number';
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
                                  child: Icon(passToggle1
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
                                  return 'Atleast 8 characters\nand an uppercase letter and a number';
                                }
                                return null;
                              },
                            ),
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
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Personal \nInformation",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                isCurrentUser
                    ? IconButton.filledTonal(
                        onPressed: () {
                          setState(() {
                            isEditing = true;
                          });
                        },
                        icon: const Icon(Icons.edit),
                        tooltip: "Edit Info",
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
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 400,
                      childAspectRatio: 400 / 150,
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          infoTitle(context, "Address"),
                          actualInfo(context, userModel!.address),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          infoTitle(context, "Contact Number"),
                          actualInfo(
                              context,
                              userModel!.contactNo.isEmpty
                                  ? "+63"
                                  : "+63${int.parse(userModel!.contactNo).toString()}"),
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
          .titleMedium!
          .copyWith(color: ccProfileInfoTextColor),
    );
  }

  Padding profilePanel1(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 7.w),
        decoration: BoxDecoration(
          border: Border.all(color: ccProfileContainerBorderColor),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
                                              .copyWith(
                                                  fontWeight: FontWeight.bold),
                                        ),
                                        const Divider(),
                                        Stack(
                                          children: [
                                            CircleAvatar(
                                              radius: 100,
                                              backgroundImage: profileImage !=
                                                          null ||
                                                      profileImageByte != null
                                                  ? kIsWeb
                                                      ? MemoryImage(
                                                          profileImageByte!
                                                              .bytes!)
                                                      : FileImage(profileImage!)
                                                          as ImageProvider
                                                  : userModel!.profilePicture ==
                                                          ""
                                                      ? const AssetImage(
                                                              guestIcon)
                                                          as ImageProvider
                                                      : NetworkImage(userModel!
                                                          .profilePicture),
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
                                                  icon: const Icon(
                                                      Icons.camera_alt),
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            IconButton.filledTonal(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                profileImage = null;
                                                profileImageByte = null;
                                                profileImageUrl = "";
                                                checker = false;
                                              },
                                              style: IconButton.styleFrom(
                                                backgroundColor:
                                                    Colors.red[800],
                                                foregroundColor: Colors.white,
                                              ),
                                              icon: const Icon(Icons.cancel),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            IconButton.filledTonal(
                                              onPressed: () {
                                                try {
                                                  if ((profileImage != null ||
                                                          profileImageByte !=
                                                              null) &&
                                                      checker) {
                                                    onSavingPic();
                                                    Navigator.pop(context);
                                                    successMessage(
                                                        title: "Success!",
                                                        desc:
                                                            "Profile Picture Updated",
                                                        context: context);
                                                    //This will now allow user to upload picture
                                                    checker = false;
                                                    setState(() {});
                                                  } else {
                                                    infoMessage(
                                                        title: "Info!",
                                                        desc: "No Changes",
                                                        context: context);
                                                  }
                                                } catch (e) {
                                                  errorMessage(
                                                      title: "Error!",
                                                      desc: e.toString(),
                                                      context: context);
                                                }
                                              },
                                              style: IconButton.styleFrom(
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                foregroundColor: Colors.white,
                                              ),
                                              icon: const Icon(Icons.save),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
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
              height: 7.w,
            ),
            Text(
              "${userModel!.firstName} ${userModel!.lastName}",
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(fontWeight: FontWeight.w900, letterSpacing: 1.5),
            ),
            SizedBox(
              height: 5.h,
            ),
            Text(
              userModel!.username,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                  color: ccProfileUserNameTextColor),
            )
          ],
        ),
      ),
    );
  }
}
