import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/data/posts_data.dart';
import 'package:neighboard/models/notification_model.dart';
import 'package:neighboard/models/store_model.dart';
import 'package:neighboard/models/user_model.dart';
import 'package:neighboard/routes/routes.dart';
import 'package:neighboard/services/notification/notification.dart';
import 'package:neighboard/src/admin_side/hoa_voting/voters/voters_function.dart';
import 'package:neighboard/src/admin_side/stores/store_function.dart';
import 'package:neighboard/src/profile_screen/profile_screen_function.dart';
import 'package:neighboard/widgets/chat/chat.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_bar.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_drawer.dart';
import 'package:neighboard/widgets/notification/notification_function.dart';
import 'package:neighboard/widgets/others/tab_header.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:universal_io/io.dart';

class StoresMobile extends StatefulWidget {
  const StoresMobile(
      {super.key, required this.deviceScreenType, required this.isAdmin});

  final DeviceScreenType deviceScreenType;
  final bool isAdmin;

  @override
  State<StoresMobile> createState() => _StoresMobileState();
}

class _StoresMobileState extends State<StoresMobile> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _ctrlName = TextEditingController();
  final TextEditingController _ctrlOffers = TextEditingController();
  final TextEditingController _ctrlHouseNo = TextEditingController();
  final TextEditingController _ctrlStreet = TextEditingController();
  final TextEditingController _ctrlContactInfo = TextEditingController();
  String _name = '';
  String _offers = '';
  String _houseNo = '';
  String _street = '';
  String _contactInfo = '';
  bool isOnNewPost = false;

  File? image;
  PlatformFile? imageByte;
  String imageUrl = "";

  List<StoreModel> storeModels = [];

  bool isLoading = true;

  void onNewStore() {
    setState(() {
      _ctrlContactInfo.text = '';
      _ctrlName.text = '';
      _ctrlOffers.text = '';
      _ctrlHouseNo.text = '';
      _ctrlStreet.text = '';
      isOnNewPost = !isOnNewPost;
    });
  }

  void getAllStores() async {
    storeModels = await StoreFunction.getAllStores() ?? [];
    storeModels.sort((a, b) => b.storeId.compareTo(a.storeId));
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void onPublishNewStore() async {
    setState(() {
      isLoading = true;
    });
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (image != null || imageByte != null) {
        imageUrl = kIsWeb
            ? await ProfileFunction.uploadImageWeb(imageByte!.bytes!,
                    imageByte!.name, imageByte!.extension!) ??
                ""
            : await ProfileFunction.uploadImage(image!) ?? "";
      }

      StoreModel storeModel = StoreModel(
          storeId: DateTime.now().toIso8601String(),
          storeName: _name,
          storeOffers: _offers,
          storeHouseNumber: _houseNo,
          storeStreetName: _street,
          storeContactNo: _contactInfo,
          storeImage: imageUrl);

      bool isSuccessful = await StoreFunction.addStore(storeModel);

      if (isSuccessful) {
        storeModels.add(storeModel);
        storeModels.sort((a, b) => b.storeId.compareTo(a.storeId));
        await sendNotifToAll();
        onNewStore();
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Store successfully Added"),
          ),
        );
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  void pickImage() async {
    if (kIsWeb) {
      FilePickerResult? result = await FilePicker.platform
          .pickFiles(allowMultiple: false, type: FileType.image);
      if (result != null) {
        imageByte = result.files.single;
      }
    } else if (!kIsWeb) {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        image = File(pickedImage.path);
      }
    }
    setState(() {});
  }

  void _openChat() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return const MyChat();
      },
    );
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
      "New Store Added: ",
      _ctrlName.text,
    );

    //ADD sa notification TAB
    NotificationModel notificationModel = NotificationModel(
      notifId: DateTime.now().toIso8601String(),
      notifTitle: "New Store Added: ",
      notifBody: _ctrlName.text,
      notifTime: formattedDate(),
      notifLocation: "STORE",
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
    getAllStores();
  }

  @override
  void dispose() {
    _ctrlContactInfo.dispose();
    _ctrlHouseNo.dispose();
    _ctrlName.dispose();
    _ctrlOffers.dispose();
    _ctrlStreet.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.isAdmin
          ? null
          : AppBar(
              title: const Text("Stores"),
              actions: [
                IconButton(
                  onPressed: () {
                    _openChat();
                  },
                  icon: const Icon(Icons.chat_outlined),
                  tooltip: "Global Chat",
                ),
                NavBarCircularImageDropDownButton(
                  callback: Routes().navigate,
                  isAdmin: false,
                ),
                SizedBox(
                  width: 2.5.w,
                )
              ],
            ),
      drawer: widget.deviceScreenType == DeviceScreenType.mobile
          ? const NavDrawer()
          : null,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: Container(
          key: ValueKey(isOnNewPost),
          child: isOnNewPost && widget.isAdmin
              ? newStore(context)
              : allStores(context),
        ),
      ),
    );
  }

  Container newStore(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: 15.w, vertical: widget.isAdmin ? 15.h : 15.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onInverseSurface,
      ),
      child: Column(
        children: [
          TabHeader(
            title: "Store Information",
            callback: () {
              //widget.drawer!();
              onNewStore();
            },
          ),
          SizedBox(
            height: 5.h,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 3,
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Container(
                        decoration: image != null || imageByte != null
                            ? BoxDecoration(
                                image: DecorationImage(
                                  image: kIsWeb
                                      ? MemoryImage(imageByte!.bytes!)
                                      : FileImage(image!) as ImageProvider,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(15),
                              )
                            : BoxDecoration(
                                image: const DecorationImage(
                                  image: AssetImage(noImage),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                      ),
                    ),
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextFormField(
                          controller: _ctrlName,
                          onSaved: (newValue) => _name = newValue!,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 4.0),
                            ),
                            labelText: "Name",
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        TextFormField(
                          controller: _ctrlOffers,
                          onSaved: (newValue) => _offers = newValue!,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 4.0),
                            ),
                            labelText: "Products and Services",
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Products and Services is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        TextFormField(
                          controller: _ctrlHouseNo,
                          onSaved: (newValue) => _houseNo = newValue!,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 4.0),
                            ),
                            labelText: "House Number",
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'House Number is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        TextFormField(
                          controller: _ctrlStreet,
                          onSaved: (newValue) => _street = newValue!,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 4.0),
                            ),
                            labelText: "Street Name",
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Street Name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        TextFormField(
                          controller: _ctrlContactInfo,
                          onSaved: (newValue) => _contactInfo = newValue!,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 4.0),
                            ),
                            labelText: "Contact Information",
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Contact Info is required';
                            }
                            return null;
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                backgroundColor: Colors.indigo[900],
                                foregroundColor: Colors.white,
                              ),
                              onPressed: pickImage,
                              icon: const Icon(Icons.image),
                              label: const Text("Add Image"),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary,
                                foregroundColor:
                                    Theme.of(context).colorScheme.onBackground,
                              ),
                              onPressed: onPublishNewStore,
                              icon: const Icon(Icons.send_outlined),
                              label: const Text("Publish"),
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Container allStores(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: widget.isAdmin
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          widget.isAdmin
              ? Container()
              : const SizedBox(
                  height: 15,
                ),
          widget.isAdmin
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        onNewStore();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text("New Store"),
                    )
                  ],
                )
              : Container(),
          widget.isAdmin
              ? SizedBox(
                  height: 10.h,
                )
              : Container(),
          Expanded(
            child: GridView(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400,
                childAspectRatio: 400 / 300,
              ),
              children: [
                for (StoreModel stModel in storeModels)
                  StoresCards(storeModel: stModel),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StoresCards extends StatelessWidget {
  const StoresCards({
    super.key,
    required this.storeModel,
  });

  final StoreModel storeModel;

  theModal(context) {
    showModalBottomSheet(
      isScrollControlled: true,
      showDragHandle: true,
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: Container(
                    width: 500,
                    height: 300,
                    decoration: storeModel.storeImage == ""
                        ? BoxDecoration(
                            image: const DecorationImage(
                              image: AssetImage(noImage),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(5))
                        : BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(storeModel.storeImage),
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        storeModel.storeName,
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        storeModel.storeOffers,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "${storeModel.storeHouseNumber}, ${storeModel.storeStreetName}",
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
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
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Card(
        elevation: 4,
        child: Container(
          decoration: storeModel.storeImage == ""
              ? BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage(noImage),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(5))
              : BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(storeModel.storeImage),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(5)),
          child: InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: () {
              // The Modal
              theModal(context);
            },
            child: Column(
              children: [
                const Expanded(child: SizedBox()),
                Container(
                  decoration: BoxDecoration(
                      color: ccStoresBannerColor(context),
                      borderRadius: BorderRadius.circular(5)),
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          storeModel.storeName,
                          style:
                              Theme.of(context).textTheme.titleMedium!.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          theModal(context);
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8))),
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
      ),
    );
  }
}
