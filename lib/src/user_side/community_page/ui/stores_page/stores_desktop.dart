import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/models/store_model.dart';
import 'package:neighboard/src/admin_side/stores/store_function.dart';
import 'package:neighboard/src/loading_screen/loading_screen.dart';
import 'package:neighboard/src/profile_screen/profile_screen_function.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_bar.dart';
import 'package:neighboard/widgets/others/tab_header.dart';
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
  final TextEditingController _ctrlHouseNo = TextEditingController();
  final TextEditingController _ctrlStreet = TextEditingController();
  final TextEditingController _ctrlContactInfo = TextEditingController();
  String _name = '';
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
          storeHouseNumber: _houseNo,
          storeStreetName: _street,
          storeContactNo: _contactInfo,
          storeImage: imageUrl);

      bool isSuccessful = await StoreFunction.addStore(storeModel);

      if (isSuccessful) {
        storeModels.add(storeModel);
        storeModels.sort((a, b) => b.storeId.compareTo(a.storeId));
        onNewStore();
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Announcement successfully posted"),
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

  @override
  void initState() {
    super.initState();
    getAllStores();
  }

  @override
  void dispose() {
    _ctrlContactInfo.dispose();
    _ctrlHouseNo.dispose();
    _ctrlName.dispose();
    _ctrlStreet.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const LoadingScreen()
        : Scaffold(
            appBar: widget.isAdmin ? null : const NavBar(),
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
              : Text(
                  'Stores',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
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
              padding: widget.isAdmin
                  ? EdgeInsets.symmetric(horizontal: 15.w)
                  : null,
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
          child: Column(
            children: [
              const Expanded(child: SizedBox()),
              InkWell(
                onTap: () {
                  showDialog(
                    // The Modal
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      storeModel.storeName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium,
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      "${storeModel.storeHouseNumber}, ${storeModel.storeStreetName}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 32,
                              ),
                              Flexible(
                                flex: 3,
                                child: Container(
                                  width: 600,
                                  height: 600,
                                  decoration: storeModel.storeImage == ""
                                      ? BoxDecoration(
                                          image: const DecorationImage(
                                            image: AssetImage(noImage),
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(5))
                                      : BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage(
                                                storeModel.storeImage),
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Container(
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
                          style: Theme.of(context).textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        'View Details..',
                        style: Theme.of(context).textTheme.titleMedium,
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
