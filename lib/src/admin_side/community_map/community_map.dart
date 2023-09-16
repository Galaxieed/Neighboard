import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocode/geocode.dart';
import 'package:neighboard/main.dart';
import 'package:neighboard/models/site_model.dart';
import 'package:neighboard/src/admin_side/site_settings/site_settings_function.dart';

class AdminCommunityMap extends StatefulWidget {
  const AdminCommunityMap({super.key});

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
  double currentZoom = 13.0;
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
    GeoCode geoCode = GeoCode(apiKey: '538204048447379774119x21710');
    try {
      setState(() {
        isLoading = true;
      });
      Coordinates coordinates =
          await geoCode.forwardGeocoding(address: address);
      newLatitude = coordinates.latitude ?? 14.827335497500572;
      newLongitude = coordinates.longitude ?? 120.87190527693967;
      currentCenter = LatLng(newLatitude, newLongitude);
      _moveMap();
    } catch (e) {
      //TODO: Catch error
    }
    setState(() {
      isLoading = false;
    });
  }

  getSiteLocation() async {
    siteModel =
        await SiteSettingsFunction.getSiteSettings(_auth.currentUser!.uid);
    if (siteModel == null || siteModel?.siteLocation == "") return;
    newLatitude = double.parse(siteModel!.siteLocation.split('|')[0]);
    newLongitude = double.parse(siteModel!.siteLocation.split('|')[1]);
    currentCenter = LatLng(newLatitude, newLongitude);
    setState(() {});
    _moveMap();
  }

  void onUpdateLocation(context) async {
    // setState(() {
    //   isLoading = true;
    // });
    if (siteModel == null) {
      SiteModel site = SiteModel(
        siteId: _auth.currentUser!.uid,
        siteName: '',
        siteLocation: '$newLatitude|$newLongitude',
        siteHeader: '',
        siteSubheader: '',
        siteAbout: '',
        siteThemeColor: currentThemeColor.value,
        siteLogo: '',
        siteHomepageImage: '',
        siteAboutImage: '',
      );

      bool isSuccessful = await SiteSettingsFunction.saveNewSiteSettings(site);

      if (isSuccessful) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Site successfully updated"),
          ),
        );
      }
      return;
    } else {
      Map<String, dynamic> siteDetails = {
        'site_location': '$newLatitude|$newLongitude',
      };
      await SiteSettingsFunction.updateSiteSettings(siteDetails);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Map location successfully updated"),
        ),
      );
    }

    setState(() {
      // isLoading = false;
    });
  }

  void _handleTap(point, context) {
    newLatitude = point.latitude;
    newLongitude = point.longitude;
    onUpdateLocation(context);
    setState(() {});

    // Do something with the latitude and longitude
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSiteLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: controller,
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
            icon: const Icon(Icons.location_searching_outlined),
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
