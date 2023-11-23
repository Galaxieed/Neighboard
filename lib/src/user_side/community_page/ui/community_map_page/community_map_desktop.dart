import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/main.dart';
import 'package:neighboard/models/store_model.dart';
import 'package:neighboard/src/admin_side/community_map/community_map.dart';
import 'package:neighboard/src/admin_side/stores/store_function.dart';
import 'package:neighboard/widgets/chat/chat.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_bar.dart';
import 'package:latlong2/latlong.dart';
import 'package:neighboard/widgets/notification/notification_drawer.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:url_launcher/url_launcher.dart';

class CommunityMapDesktop extends StatefulWidget {
  const CommunityMapDesktop({super.key});

  @override
  State<CommunityMapDesktop> createState() => _CommunityMapDesktopState();
}

class _CommunityMapDesktopState extends State<CommunityMapDesktop> {
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

  bool isLoading = true;
  double lat = 0;
  double long = 0;
  late LatLng centerLoc;
  void getMapLoc() async {
    if (siteModel != null && siteModel!.siteLocation != '') {
      lat = double.parse(siteModel!.siteLocation.split('|')[0]);
      long = double.parse(siteModel!.siteLocation.split('|')[1]);
    }
    centerLoc = LatLng(lat, long);
    await getStoresLocation();
    setState(() {
      isLoading = false;
    });
  }

  List<StoreModel> storeModels = [];
  getStoresLocation() async {
    storeModels = await StoreFunction.getStoresLocation() ?? [];
  }

  MapController mapController = MapController();
  void _moveMap() {
    mapController.move(LatLng(lat, long), 17);
  }

  @override
  void initState() {
    super.initState();
    getMapLoc();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: NavBar(
        openNotification: _openNotification,
        openChat: _openChat,
        currentPage: "Community",
      ),
      endDrawer: NotificationDrawer(
        deviceScreenType: DeviceScreenType.desktop,
        stateSetter: setState,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _moveMap,
        tooltip: 'Move Map',
        child: const Icon(Icons.my_location_outlined),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    'Community Map',
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                        fontFamily: "Montserrat", fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Expanded(
                    child: FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                        center: centerLoc,
                        zoom: 17,
                        maxZoom: 18,
                      ),
                      nonRotatedChildren: [
                        RichAttributionWidget(
                          attributions: [
                            TextSourceAttribution(
                              'OpenStreetMap contributors',
                              onTap: () => launchUrl(Uri.parse(
                                  'https://openstreetmap.org/copyright')),
                            ),
                          ],
                        ),
                      ],
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.app',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: centerLoc,
                              width: 20,
                              height: 20,
                              builder: (context) => Icon(
                                Icons.location_pin,
                                color: ccMapPinColor(context),
                                weight: 4,
                                size: 40,
                              ),
                            ),
                            ...storeModels
                                .map(
                                  (e) => Marker(
                                    height: 30,
                                    width: 30,
                                    anchorPos:
                                        AnchorPos.align(AnchorAlign.center),
                                    point: LatLng(
                                        double.parse(e.storeLoc.split('|')[0]),
                                        double.parse(e.storeLoc.split('|')[1])),
                                    builder: (context) => GestureDetector(
                                      onTap: () {
                                        showDialog(
                                            context: context,
                                            builder: (_) => Dialog(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12)),
                                                child:
                                                    StoreModal(storeModel: e)));
                                      },
                                      child: Icon(
                                        Icons.store,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
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
                  ),
                ],
              ),
            ),
    );
  }
}
