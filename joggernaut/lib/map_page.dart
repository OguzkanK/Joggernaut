import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:async';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller = Completer();
  Location location = Location();
  final TextEditingController _searchController = TextEditingController();

  void locateUser(GoogleMapController controller) {
    location.onLocationChanged.listen((l) {
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(l.latitude!, l.longitude!),
          zoom: 15,
        ),
      ));
    });
    _controller.complete(controller);
  }

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps'),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 480,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.red,
              ),
            ),
          ),
          Expanded(
              child: GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              // location.onLocationChanged.listen((l) {
              //   controller.animateCamera(CameraUpdate.newCameraPosition(
              //     CameraPosition(
              //       target: LatLng(l.latitude!, l.longitude!),
              //       zoom: 15,
              //     ),
              //   ));
              // });
              _controller.complete(controller);
            },
            myLocationEnabled: true,
            // markers: {_kGooglePlexMarker, _kLakeMarker},
            // polylines: {_kPolyline},
            // polygons: {_kPolygon},
          )),
        ],
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: _goToTheLake,
      //   label: const Text('To the lake!'),
      //   icon: const Icon(Icons.directions_boat),
      // ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }
}
