import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
// ignore: depend_on_referenced_packages
import 'package:latlong2/latlong.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class CommunityMap extends StatelessWidget {
  const CommunityMap({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NavBar(),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 30),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 10,
            ),
            Text(
              'Community Map',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(
              height: 40,
            ),
            Expanded(
                child: FlutterMap(
              options: MapOptions(
                center: const LatLng(14.827335497500572, 120.87190527693967),
                zoom: 18,
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
                      width: 80,
                      height: 80,
                      builder: (context) => const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        weight: 4,
                        size: 100,
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
