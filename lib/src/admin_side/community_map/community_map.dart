import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocode/geocode.dart';

class AdminCommunityMap extends StatefulWidget {
  const AdminCommunityMap({super.key});

  @override
  State<AdminCommunityMap> createState() => _AdminCommunityMapState();
}

class _AdminCommunityMapState extends State<AdminCommunityMap> {
  TextEditingController controller = TextEditingController();
  MapController mapController = MapController();
  LatLng currentCenter = const LatLng(14.852694046899718, 120.81603489600447);
  double newLatitude = 14.852694046899718;
  double newLongitude = 120.81603489600447;
  double currentZoom = 13.0;

  void _moveMap() {
    mapController.move(LatLng(newLatitude, newLongitude), currentZoom);
  }

  void _getLatLngFromAddress(String address) async {
    List<Location> locations = await locationFromAddress(address);

    if (locations.isNotEmpty) {
      Location location = locations.first;
      newLatitude = location.latitude;
      newLongitude = location.longitude;
      currentCenter = LatLng(newLatitude, newLongitude);
      setState(() {});
    }
  }

  void _getLatLngFromAddressWeb(String address) async {
    GeoCode geoCode = GeoCode(apiKey: '538204048447379774119x21710');
    try {
      Coordinates coordinates =
          await geoCode.forwardGeocoding(address: address);
      newLatitude = coordinates.latitude ?? 14.827335497500572;
      newLongitude = coordinates.longitude ?? 120.87190527693967;
      currentCenter = LatLng(newLatitude, newLongitude);
      setState(() {});
    } catch (e) {
      //TODO: Catch error
    }
  }

  void _handleTap(point) {
    newLatitude = point.latitude;
    newLongitude = point.longitude;
    setState(() {});
    // Do something with the latitude and longitude
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
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          center: currentCenter,
          zoom: currentZoom,
          maxZoom: 18,
          onTap: (tapPosition, point) => _handleTap(point),
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
        child: const Icon(Icons.map),
      ),
    );
  }
}
