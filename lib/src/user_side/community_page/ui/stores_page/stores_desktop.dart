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
import 'package:neighboard/services/notification/notification.dart';
import 'package:neighboard/src/admin_side/hoa_voting/voters/voters_function.dart';
import 'package:neighboard/src/admin_side/stores/store_function.dart';
import 'package:neighboard/src/loading_screen/loading_screen.dart';
import 'package:neighboard/src/profile_screen/profile_screen_function.dart';
import 'package:neighboard/widgets/chat/chat.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_bar.dart';
import 'package:neighboard/widgets/notification/mini_notif/elegant_notif.dart';
import 'package:neighboard/widgets/notification/notification_drawer.dart';
import 'package:neighboard/widgets/notification/notification_function.dart';
import 'package:neighboard/widgets/others/tab_header.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:universal_io/io.dart';

class StoresDesktop extends StatefulWidget {
  const StoresDesktop({super.key, required this.isAdmin, this.drawer});

  final bool isAdmin;
  final Function? drawer;

  @override
  State<StoresDesktop> createState() => _StoresDesktopState();
}

class _StoresDesktopState extends State<StoresDesktop> {
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
  final String _contactInfo = '';
  bool isOnNewPost = false;

  File? image;
  PlatformFile? imageByte;
  String imageUrl = "";

  List<StoreModel> storeModels = [];
  List<StoreModel> allStoreModels = [];

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
    setState(() {
      isLoading = true;
    });
    storeModels = await StoreFunction.getAllStores() ?? [];
    allStoreModels = storeModels;
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
        successMessage(
          title: "Success!",
          desc: 'Store successfully added',
          context: context,
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

  String searchedText = "";
  void searchStore(String text) {
    text = text.toLowerCase();
    storeModels = allStoreModels;
    if (text.isNotEmpty) {
      storeModels = storeModels
          .where((store) =>
              store.storeHouseNumber.toLowerCase().contains(text) ||
              store.storeName.toLowerCase().contains(text) ||
              store.storeStreetName.toLowerCase().contains(text) ||
              store.storeOffers.toLowerCase().contains(text))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const LoadingScreen()
        : Scaffold(
            key: widget.isAdmin ? null : _scaffoldKey,
            appBar: widget.isAdmin
                ? null
                : NavBar(
                    openNotification: _openNotification,
                    openChat: _openChat,
                    currentPage: "Community",
                  ),
            endDrawer: widget.isAdmin
                ? null
                : NotificationDrawer(
                    deviceScreenType: DeviceScreenType.desktop,
                    stateSetter: setState,
                  ),
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
          horizontal: 15.w, vertical: widget.isAdmin ? 30.h : 15.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.inversePrimary.withAlpha(100),
            Theme.of(context).colorScheme.onInverseSurface,
          ],
        ),
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
            height: 20.h,
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
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
                Expanded(
                  child: Form(
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
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Container allStores(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: 15.w, vertical: widget.isAdmin ? 30.h : 15.h),
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
              ? TabHeader(
                  title: "Stores",
                  callback: () {
                    widget.drawer!();
                  },
                )
              : SizedBox(
                  width: double.infinity,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        'Stores',
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge!
                            .copyWith(
                                fontFamily: "Montserrat",
                                fontWeight: FontWeight.bold),
                      ),
                      Positioned(
                        right: 0,
                        child: SizedBox(
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
                                searchStore(searchText);
                              });
                            },
                            onTap: () {
                              // showSearch(
                              //     context: context, delegate: SearchScreenUI());
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ),
          widget.isAdmin
              ? Container()
              : const SizedBox(
                  height: 15,
                ),
          if (widget.isAdmin)
            Row(
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
                        searchStore(searchText);
                      });
                    },
                    onTap: () {
                      // showSearch(
                      //     context: context, delegate: SearchScreenUI());
                    },
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    onNewStore();
                  },
                  style: ElevatedButton.styleFrom(elevation: 5),
                  icon: const Icon(Icons.add),
                  label: const Text("New Store"),
                )
              ],
            ),
          widget.isAdmin
              ? SizedBox(
                  height: 10.h,
                )
              : Container(),
          Expanded(
            child: storeModels.isEmpty
                ? Center(
                    child: Column(
                      children: [
                        Image.asset(
                          noStore,
                          height: 300,
                          width: 300,
                        ),
                        const Text("No Stores"),
                      ],
                    ),
                  )
                : GridView(
                    padding: widget.isAdmin
                        ? EdgeInsets.symmetric(horizontal: 15.w)
                        : null,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 500,
                      childAspectRatio: 400 / 300,
                    ),
                    children: [
                      for (StoreModel stModel in storeModels)
                        StoresCards(
                          storeModel: stModel,
                          stateSetter: getAllStores,
                          isAdmin: widget.isAdmin,
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class StoresCards extends StatelessWidget {
  StoresCards({
    super.key,
    required this.storeModel,
    required this.isAdmin,
    required this.stateSetter,
  });

  final bool isAdmin;
  final Function stateSetter;
  final StoreModel storeModel;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _offersController = TextEditingController();
  final TextEditingController _houseNoController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  bool isEditing = false;

  removeStore(BuildContext context) async {
    bool isSuccess = await StoreFunction.removeStore(storeModel.storeId);
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
          desc: "This store isn't deleted!",
          context: context);
    }
  }

  updateStore(BuildContext context) async {
    if (_nameController.text.isNotEmpty &&
        _offersController.text.isNotEmpty &&
        _houseNoController.text.isNotEmpty &&
        _streetController.text.isNotEmpty) {
      bool isSuccess = await StoreFunction.updateStore(
          storeModel.storeId,
          _nameController.text,
          _offersController.text,
          _houseNoController.text,
          _streetController.text);

      if (isSuccess) {
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
            desc: "This store isn't updated!",
            context: context);
      }
    }
  }

  theModal(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: StatefulBuilder(builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: 1000,
                    height: 450,
                    padding: const EdgeInsets.all(32),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              isEditing
                                  ? TextField(
                                      controller: _nameController,
                                      decoration: InputDecoration(
                                          suffixIcon: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _nameController.text =
                                                    storeModel.storeName;
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
                                              updateStore(context);
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
                                      storeModel.storeName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge!
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                              const SizedBox(
                                height: 20,
                              ),
                              isEditing
                                  ? TextField(
                                      controller: _offersController,
                                      decoration: InputDecoration(
                                          suffixIcon: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _offersController.text =
                                                    storeModel.storeOffers;
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
                                              updateStore(context);
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
                                      storeModel.storeOffers,
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                              const SizedBox(
                                height: 20,
                              ),
                              isEditing
                                  ? Column(
                                      children: [
                                        TextField(
                                          controller: _houseNoController,
                                          decoration: InputDecoration(
                                              suffixIcon: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _houseNoController.text =
                                                        storeModel
                                                            .storeHouseNumber;
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
                                                  updateStore(context);
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
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        TextField(
                                          controller: _streetController,
                                          decoration: InputDecoration(
                                              suffixIcon: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _streetController.text =
                                                        storeModel
                                                            .storeStreetName;
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
                                                  updateStore(context);
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
                                        ),
                                      ],
                                    )
                                  : Text(
                                      "${storeModel.storeHouseNumber}, ${storeModel.storeStreetName}",
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 32,
                        ),
                        Flexible(
                          child: Container(
                            width: 400,
                            height: 400,
                            decoration: storeModel.storeImage == ""
                                ? BoxDecoration(
                                    image: const DecorationImage(
                                      image: AssetImage(noImage),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(30))
                                : BoxDecoration(
                                    image: DecorationImage(
                                      image:
                                          NetworkImage(storeModel.storeImage),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(30)),
                          ),
                        )
                      ],
                    ),
                  ),
                  if (isAdmin)
                    Container(
                      height: 100,
                      width: 1000,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30)),
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Confirm Delete?"),
                                      content: const Text(
                                          "Would you like to continue removing this store?"),
                                      actions: [
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text("NO"),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            removeStore(context);
                                            Navigator.pop(context);
                                          },
                                          child: const Text("YES"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor:
                                    Theme.of(context).colorScheme.onBackground,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
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
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                foregroundColor:
                                    Theme.of(context).colorScheme.background,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: const Text("Edit")),
                        ],
                      ),
                    )
                ],
              ),
            );
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _nameController.text = storeModel.storeName;
    _offersController.text = storeModel.storeOffers;
    _houseNoController.text = storeModel.storeHouseNumber;
    _streetController.text = storeModel.storeStreetName;
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
