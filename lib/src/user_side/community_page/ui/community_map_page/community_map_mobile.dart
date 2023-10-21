import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/main.dart';
import 'package:neighboard/routes/routes.dart';
import 'package:neighboard/widgets/chat/chat.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_bar.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_drawer.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class CommunityMapMobile extends StatefulWidget {
  const CommunityMapMobile({super.key, required this.deviceScreenType});

  final DeviceScreenType deviceScreenType;

  @override
  State<CommunityMapMobile> createState() => _CommunityMapMobileState();
}

class _CommunityMapMobileState extends State<CommunityMapMobile> {
  double lat = 0;
  double long = 0;
  late LatLng centerLoc;

  void getMapLoc() {
    if (siteModel != null && siteModel!.siteLocation != '') {
      lat = double.parse(siteModel!.siteLocation.split('|')[0]);
      long = double.parse(siteModel!.siteLocation.split('|')[1]);
    }
    centerLoc = LatLng(lat, long);
    setState(() {});
  }

  MapController mapController = MapController();

  void _moveMap() {
    mapController.move(LatLng(lat, long), 17);
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
  void initState() {
    super.initState();
    getMapLoc();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Community Map"),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _moveMap,
        tooltip: 'Move Map',
        child: const Icon(Icons.my_location_outlined),
      ),
      drawer: widget.deviceScreenType == DeviceScreenType.mobile
          ? const NavDrawer()
          : null,
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
                        onTap: () => launchUrl(
                            Uri.parse('https://openstreetmap.org/copyright')),
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
