import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/routes/routes.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_bar.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_drawer.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class CommunityMapMobile extends StatelessWidget {
  const CommunityMapMobile({super.key, required this.deviceScreenType});

  final DeviceScreenType deviceScreenType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Community Map"),
        centerTitle: true,
        actions: [
          NavBarCircularImageDropDownButton(
            callback: Routes().navigate,
            isAdmin: false,
          ),
          SizedBox(
            width: 2.5.w,
          )
        ],
      ),
      drawer: deviceScreenType == DeviceScreenType.mobile
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
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point:
                          const LatLng(14.827335497500572, 120.87190527693967),
                      width: 20.w,
                      height: 40.h,
                      builder: (context) => Icon(
                        Icons.location_pin,
                        color: ccMapPinColor(context),
                        weight: 4,
                        size: 50.sp,
                      ),
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point:
                          const LatLng(14.827783593750764, 120.87393430014184),
                      width: 80,
                      height: 80,
                      builder: (context) => const Image(
                          image: AssetImage('assets/waltermart.png')),
                    ),
                  ],
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }
}
