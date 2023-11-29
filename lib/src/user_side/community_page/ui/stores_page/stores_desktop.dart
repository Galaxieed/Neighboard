// ignore_for_file: use_build_context_synchronously

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/data/posts_data.dart';
import 'package:neighboard/main.dart';
import 'package:neighboard/models/notification_model.dart';
import 'package:neighboard/models/store_model.dart';
import 'package:neighboard/models/user_model.dart';
import 'package:neighboard/services/notification/notification.dart';
import 'package:neighboard/src/admin_side/dashboard/activity_logs.dart';
import 'package:neighboard/src/admin_side/hoa_voting/voters/voters_function.dart';
import 'package:neighboard/src/admin_side/stores/store_function.dart';
import 'package:neighboard/src/loading_screen/loading_screen.dart';
import 'package:neighboard/src/profile_screen/profile_screen_function.dart';
import 'package:neighboard/widgets/chat/chat.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_bar.dart';
import 'package:neighboard/widgets/notification/mini_notif/elegant_notif.dart';
import 'package:neighboard/widgets/notification/notification_drawer.dart';
import 'package:neighboard/widgets/notification/notification_function.dart';
import 'package:neighboard/widgets/others/map.dart';
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
  final TextEditingController _ctrlBlock = TextEditingController();
  final TextEditingController _ctrlLot = TextEditingController();
  final TextEditingController _ctrlContactInfo = TextEditingController();
  String _name = '';
  String _offers = '';
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
      _ctrlBlock.text = '';
      _ctrlLot.text = '';
      _street = '';
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
    await getArchivedStores();
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  double? lat, long;
  void setStoreLocation(double lat, double long) {
    this.lat = lat;
    this.long = long;
  }

  void onPublishNewStore() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
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
        storeHouseNumber: "Blk ${_ctrlBlock.text} Lot ${_ctrlLot.text}",
        storeStreetName: _street,
        storeContactNo: _contactInfo,
        storeImage: imageUrl,
        storeLoc: lat != null || long != null ? '$lat|$long' : "",
      );

      bool isSuccessful = await StoreFunction.addStore(storeModel);

      if (isSuccessful) {
        storeModels.add(storeModel);
        storeModels.sort((a, b) => b.storeId.compareTo(a.storeId));
        onNewStore();

        successMessage(
          title: "Success!",
          desc: 'Store successfully added',
          context: context,
        );
        setState(() {
          isLoading = false;
        });
        await sendNotifToAll();
      } else {
        setState(() {
          isLoading = false;
        });
      }
    }
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
  Future<void> sendNotificaton(
      UserModel user, NotificationModel notificationModel) async {
    await MyNotification().sendPushMessage(
      user.deviceToken,
      "New Store Added: ",
      _ctrlName.text,
    );

    //ADD sa notification TAB
    await NotificationFunction.addNotification(notificationModel, user.userId);
  }

  //send notif to all at once
  sendNotifToAll() async {
    NotificationModel notificationModel = NotificationModel(
      notifId: DateTime.now().toIso8601String(),
      notifTitle: "New Store Added: ",
      notifBody: _ctrlName.text,
      notifTime: formattedDate(),
      notifLocation: "STORE",
      isRead: false,
      isArchived: false,
    );

    await Future.forEach(allUsers, (user) {
      sendNotificaton(user, notificationModel);
    });
    await ActivityLogsFunction.addLogs(notificationModel);
  }

  List<StoreModel> archivedStores = [];
  getArchivedStores() async {
    archivedStores = await StoreFunction.getArchivedStores() ?? [];
  }

  retrieveStore(StoreModel store) async {
    bool status = await StoreFunction.retrieveArchivedStore(store);
    if (status) {
      successMessage(
          title: "Retrieved!", desc: "Store retrieved!", context: context);
    } else {
      errorMessage(
          title: "Error", desc: "Something went wrong!", context: context);
    }
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
    _ctrlBlock.dispose();
    _ctrlLot.dispose();
    _ctrlName.dispose();
    _ctrlOffers.dispose();
    super.dispose();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openNotification() {
    _scaffoldKey.currentState!.openEndDrawer();
  }

  void _openChat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
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
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _ctrlBlock,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d{0,2}$'),
                                  ),
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Block Number is required';
                                  }
                                  return null;
                                },
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 4.0),
                                  ),
                                  prefixIcon: Text(" Block"),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _ctrlLot,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d{0,2}$'),
                                  ),
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Lot Number is required';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 4.0),
                                  ),
                                  prefixIcon: Text(" Lot"),
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                          ],
                        ),
                        DropdownButtonFormField(
                          onChanged: (value) {
                            setState(() {
                              _street = value.toString();
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Street is required';
                            }
                            return null;
                          },
                          items: siteModel == null
                              ? []
                              : siteModel!.siteStreets.map((String e) {
                                  return DropdownMenuItem<String>(
                                    value: e,
                                    child: Text(e),
                                  );
                                }).toList(),
                          //value: street,
                          hint: const Text('Street'),
                          value: _street.isEmpty ? null : _street,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
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
                            if (siteModel != null)
                              ElevatedButton.icon(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => MyMap(
                                      setLocation: setStoreLocation,
                                      lat: lat,
                                      long: long,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.map),
                                label: const Text("Map Location"),
                              ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                foregroundColor:
                                    Theme.of(context).colorScheme.onPrimary,
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
                          ),
                        ),
                      )
                    ],
                  ),
                ),
          if (!widget.isAdmin)
            const SizedBox(
              height: 20,
            ),
          if (widget.isAdmin)
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: SizedBox(
                            height: 500,
                            width: 500,
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 30,
                                ),
                                Text(
                                  "Archives",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                ListView.separated(
                                  padding: const EdgeInsets.all(30),
                                  shrinkWrap: true,
                                  itemCount: archivedStores.length,
                                  itemBuilder: (context, index) {
                                    StoreModel str = archivedStores[index];
                                    return ListTile(
                                      title: Text(str.storeName),
                                      subtitle: Text(str.storeStreetName),
                                      trailing: IconButton(
                                        onPressed: () {
                                          retrieveStore(str);
                                        },
                                        icon: const Icon(Icons.recycling),
                                      ),
                                    );
                                  },
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    return const Divider();
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  label: const Text("Archives"),
                  icon: const Icon(Icons.archive),
                ),
                const Spacer(),
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
    bool isSuccess = await StoreFunction.removeStore(storeModel);
    if (isSuccess) {
      successMessage(
          title: "Success!", desc: "Refresh to see changes!", context: context);
      stateSetter();

      Navigator.pop(context);
    } else {
      errorMessage(
          title: "Something went wrong!",
          desc: "This store isn't archived!",
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
        successMessage(
            title: "Success!",
            desc: "Refresh to see changes!",
            context: context);
        stateSetter();
      } else {
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: StatefulBuilder(builder: (context, setState) {
            return Stack(
              children: [
                SizedBox(
                  width: 550,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isAdmin)
                          Container(
                            height: 75,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
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
                                            title: const Text("Confirm?"),
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
                                      foregroundColor: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    child: const Text("Archive")),
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
                                      foregroundColor: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    child: Text(isEditing ? "Cancel" : "Edit")),
                              ],
                            ),
                          ),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          width: double.infinity,
                          height: 400,
                          decoration: storeModel.storeImage == ""
                              ? BoxDecoration(
                                  image: const DecorationImage(
                                    image: AssetImage(noImage),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(12))
                              : BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(storeModel.storeImage),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(12)),
                        ),
                        const SizedBox(height: 16),
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
                                            .primary,
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
                                              .primary,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(width: 5),
                                  const Icon(Icons.shopping_cart_rounded),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      storeModel.storeOffers,
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ),
                                ],
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
                                                    storeModel.storeHouseNumber;
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
                                                  .primary,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
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
                                                    storeModel.storeStreetName;
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
                                                  .primary,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(width: 5),
                                  const Icon(Icons.pin_drop),
                                  const SizedBox(width: 5),
                                  Text(
                                    "${storeModel.storeHouseNumber}, ${storeModel.storeStreetName}",
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                        const SizedBox(
                          height: 16,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                  ),
                ),
              ],
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
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimary,
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
