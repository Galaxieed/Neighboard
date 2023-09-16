import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/main.dart';
import 'package:neighboard/widgets/chat/chat.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_bar.dart';
import 'package:latlong2/latlong.dart';
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
      builder: (context) {
        return const MyChat();
      },
    );
  }

  double lat = 14.827335497500572;
  double long = 120.87190527693967;
  late LatLng centerLoc;
  void getMapLoc() {
    if (siteModel != null) {
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

  @override
  void initState() {
    // TODO: implement initState
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
      ),
      endDrawer: const Drawer(
        child: Column(
          children: [Text("Notifications")],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _moveMap,
        tooltip: 'Move Map',
        child: const Icon(Icons.my_location_outlined),
      ),
      body: Container(
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
              style: Theme.of(context).textTheme.headlineLarge,
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
