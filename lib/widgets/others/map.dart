import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:neighboard/main.dart';

class MyMap extends StatefulWidget {
  const MyMap({super.key, required this.setLocation, this.lat, this.long});

  final Function setLocation;
  final double? lat, long;

  @override
  State<MyMap> createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  double currentZoom = 18.0;
  LatLng? center;
  double? lat, lng;

  void _handleTap(point, context) {
    lat = point.latitude;
    lng = point.longitude;
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    lat = widget.lat;
    lng = widget.long;
    center = LatLng(double.parse(siteModel!.siteLocation.split('|')[0]),
        double.parse(siteModel!.siteLocation.split('|')[1]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FlutterMap(
        options: MapOptions(
          center: center,
          zoom: currentZoom,
          maxZoom: 18,
          minZoom: 16,
          onTap: (tapPosition, point) => _handleTap(point, context),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          if (lat != null && lng != null)
            MarkerLayer(
              markers: [
                Marker(
                  height: 30,
                  width: 30,
                  anchorPos: AnchorPos.align(AnchorAlign.center),
                  point: LatLng(lat!, lng!),
                  builder: (context) => Icon(
                    Icons.store,
                    color: Theme.of(context).colorScheme.primary,
                    size: 30,
                  ),
                ),
              ],
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          widget.setLocation(lat, lng);
          Navigator.pop(context);
        },
        tooltip: "Save",
        child: const Icon(Icons.done_outlined),
      ),
    );
  }
}
