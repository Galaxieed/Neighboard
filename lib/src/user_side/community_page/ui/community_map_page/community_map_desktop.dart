import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/widgets/chat/chat.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_bar.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class CommunityMapDesktop extends StatelessWidget {
  const CommunityMapDesktop({super.key});

  @override
  Widget build(BuildContext context) {
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
                options: MapOptions(
                  center: const LatLng(14.827335497500572, 120.87190527693967),
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
                        point: const LatLng(
                            14.827335497500572, 120.87190527693967),
                        width: 20.w,
                        height: 40.h,
                        builder: (context) => Icon(
                          Icons.location_pin,
                          color: ccMapPinColor(context),
                          weight: 4,
                          size: 20.sp,
                        ),
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: const LatLng(
                            14.827783593750764, 120.87393430014184),
                        width: 80,
                        height: 80,
                        builder: (context) => const Image(
                            image: AssetImage('assets/waltermart.png')),
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
