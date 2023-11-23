import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocode/geocode.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/data/posts_data.dart';
import 'package:neighboard/main.dart';
import 'package:neighboard/models/notification_model.dart';
import 'package:neighboard/models/site_model.dart';
import 'package:neighboard/models/store_model.dart';
import 'package:neighboard/models/user_model.dart';
import 'package:neighboard/services/notification/notification.dart';
import 'package:neighboard/src/admin_side/hoa_voting/voters/voters_function.dart';
import 'package:neighboard/src/admin_side/site_settings/site_settings_function.dart';
import 'package:neighboard/src/admin_side/stores/store_function.dart';
import 'package:neighboard/widgets/notification/mini_notif/elegant_notif.dart';
import 'package:neighboard/widgets/notification/notification_function.dart';
import 'package:responsive_builder/responsive_builder.dart';

class AdminCommunityMap extends StatefulWidget {
  const AdminCommunityMap({super.key, required this.deviceScreenType});
  final DeviceScreenType deviceScreenType;

  @override
  State<AdminCommunityMap> createState() => _AdminCommunityMapState();
}

class _AdminCommunityMapState extends State<AdminCommunityMap> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  SiteModel? siteModel;
  TextEditingController controller = TextEditingController();
  MapController mapController = MapController();
  LatLng? currentCenter;
  double newLatitude = 14.852694046899718;
  double newLongitude = 120.81603489600447;
  double currentZoom = 16.0;
  bool isLoading = false;

  void _moveMap() {
    mapController.move(LatLng(newLatitude, newLongitude), currentZoom);
  }

  void _getLatLngFromAddress(String address) async {
    List<Location> locations = await locationFromAddress(address);
    if (locations.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      Location location = locations.first;
      newLatitude = location.latitude;
      newLongitude = location.longitude;
      currentCenter = LatLng(newLatitude, newLongitude);
      _moveMap();
    }
    setState(() {
      isLoading = false;
    });
  }

  void _getLatLngFromAddressWeb(String address) async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    try {
      GeoCode geoCode = GeoCode(apiKey: '538204048447379774119x21710');
      Coordinates coordinates =
          await geoCode.forwardGeocoding(address: address);
      newLatitude = coordinates.latitude ?? 14.827335497500572;
      newLongitude = coordinates.longitude ?? 120.87190527693967;
      currentCenter = LatLng(newLatitude, newLongitude);
      _moveMap();
    } catch (e) {
      // ignore: use_build_context_synchronously
      //errorMessage(title: "Error!", desc: e.toString(), context: context);
    }
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  getSiteLocation() async {
    if (_auth.currentUser != null) {
      siteModel =
          await SiteSettingsFunction.getSiteSettings(_auth.currentUser!.uid);
      await getStoresLocation();
      if (siteModel == null || siteModel?.siteLocation == "") return;
      newLatitude = double.parse(siteModel!.siteLocation.split('|')[0]);
      newLongitude = double.parse(siteModel!.siteLocation.split('|')[1]);
      currentCenter = LatLng(newLatitude, newLongitude);
      setState(() {
        isLoading = false;
      });
      _moveMap();
    }
  }

  List<StoreModel> storeModels = [];
  getStoresLocation() async {
    storeModels = await StoreFunction.getStoresLocation() ?? [];
  }

  void onUpdateLocation(context) async {
    // setState(() {
    //   isLoading = true;
    // });
    if (_auth.currentUser == null) return;

    if (siteModel == null) {
      SiteModel site = SiteModel(
        siteId: _auth.currentUser!.uid,
        siteSubdName: '',
        siteLocation: '$newLatitude|$newLongitude',
        siteHeader: '',
        siteSubheader: '',
        siteAbout: '',
        siteOfficeAddress: '',
        siteContactNo: [],
        siteStreets: [],
        siteThemeColor: currentThemeColor.value,
        siteLogo: '',
        siteLogoDark: '',
        siteHomepageImage: '',
        siteAboutImage: '',
      );

      bool isSuccessful = await SiteSettingsFunction.saveNewSiteSettings(site);

      if (isSuccessful) {
        successMessage(
            title: "Success!",
            desc: "Site successfully updated",
            context: context);
        setState(() {
          // isLoading = false;
        });
        await sendNotifToAll();
      }
      return;
    } else {
      Map<String, dynamic> siteDetails = {
        'site_location': '$newLatitude|$newLongitude',
      };
      await SiteSettingsFunction.updateSiteSettings(siteDetails);

      successMessage(
          title: "Success!",
          desc: "Map location successfully updated",
          context: context);
      setState(() {
        // isLoading = false;
      });
      await sendNotifToAll();
    }
  }

  void _handleTap(point, context) {
    newLatitude = point.latitude;
    newLongitude = point.longitude;
    onUpdateLocation(context);
    setState(() {});

    // Do something with the latitude and longitude
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
      "New map location has been set: ",
      "",
    );

    //ADD sa notification TAB
    NotificationModel notificationModel = NotificationModel(
      notifId: DateTime.now().toIso8601String(),
      notifTitle: "New map location has been set: ",
      notifBody: "",
      notifTime: formattedDate(),
      notifLocation: "MAP",
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
    getSiteLocation();
  }

  @override
  void dispose() {
    super.dispose();
    mapController.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: TextField(
          controller: controller,
          onSubmitted: (value) {
            kIsWeb
                ? _getLatLngFromAddressWeb(controller.text)
                : _getLatLngFromAddress(controller.text);
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            hintText: "Search location..",
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              kIsWeb
                  ? _getLatLngFromAddressWeb(controller.text)
                  : _getLatLngFromAddress(controller.text);
            },
            icon: const Icon(Icons.search),
          ),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : FlutterMap(
              mapController: mapController,
              options: MapOptions(
                center: currentCenter,
                zoom: currentZoom,
                maxZoom: 18,
                onTap: (tapPosition, point) => _handleTap(point, context),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      height: 50,
                      width: 50,
                      point: LatLng(newLatitude, newLongitude),
                      builder: (context) => const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        weight: 4,
                        size: 50,
                      ),
                    ),
                    ...storeModels
                        .map(
                          (e) => Marker(
                            height: 30,
                            width: 30,
                            anchorPos: AnchorPos.align(AnchorAlign.center),
                            point: LatLng(
                                double.parse(e.storeLoc.split('|')[0]),
                                double.parse(e.storeLoc.split('|')[1])),
                            builder: (context) => GestureDetector(
                              onTap: () {
                                if (widget.deviceScreenType ==
                                    DeviceScreenType.mobile) {
                                  showModalBottomSheet(
                                      isScrollControlled: true,
                                      context: context,
                                      builder: (_) =>
                                          StoreModal(storeModel: e));
                                } else {
                                  showDialog(
                                      context: context,
                                      builder: (_) => Dialog(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          child: StoreModal(storeModel: e)));
                                }
                              },
                              child: Icon(
                                Icons.store,
                                color: Theme.of(context).colorScheme.primary,
                                size: 30,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ],
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _moveMap,
        tooltip: 'Move Map',
        child: const Icon(Icons.my_location_outlined),
      ),
    );
  }
}

class StoreModal extends StatelessWidget {
  const StoreModal({super.key, required this.storeModel});

  final StoreModel storeModel;

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, setState) {
      return Stack(
        children: [
          SizedBox(
            width: 550,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Text(
                    storeModel.storeName,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(width: 5),
                      const Icon(Icons.shopping_cart_rounded),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          storeModel.storeOffers,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 5),
                      const Icon(Icons.pin_drop),
                      const SizedBox(width: 5),
                      Text(
                        "${storeModel.storeHouseNumber}, ${storeModel.storeStreetName}",
                        style: Theme.of(context).textTheme.bodyLarge,
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
    });
  }
}
