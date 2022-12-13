import 'dart:math';

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

  Set<Marker> markers = Set();
  Set<Circle> circles = Set();

  LatLng getRandomLocation(LatLng point, int radiusMax, int radiusMin) {
    Random random = Random();

    double angle = random.nextDouble() * pi * 2;

    int randomRadius = random.nextInt(radiusMax - radiusMin) + radiusMin;

    double relativeX = cos(angle) * randomRadius / 11000;
    double relativeY = sin(angle) * randomRadius / 11000;

    LatLng randomLatLng =
        LatLng(point.latitude + relativeX, point.longitude + relativeY);

    return randomLatLng;
  }

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

  static const initialPosition = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps'),
      ),
      body: Column(
        children: [
          Expanded(
              child: GoogleMap(
            mapType: MapType.hybrid,
            initialCameraPosition: initialPosition,
            onMapCreated: (GoogleMapController controller) {
              location.onLocationChanged.listen((l) {
                Circle locationCircle = Circle(
                  circleId: const CircleId("locationCircle"),
                  center: LatLng(l.latitude!, l.longitude!),
                  radius: 110,
                  strokeColor: const Color.fromARGB(204, 16, 148, 230),
                );
                Circle maxCircle = Circle(
                  circleId: const CircleId("maxCircle"),
                  center: LatLng(l.latitude!, l.longitude!),
                  radius: 300,
                  strokeColor: Color.fromARGB(204, 230, 62, 16),
                );
                Circle minCircle = Circle(
                  circleId: const CircleId("minCircle"),
                  center: LatLng(l.latitude!, l.longitude!),
                  radius: 150,
                  strokeColor: Color.fromARGB(204, 230, 62, 16),
                );
                Circle lostCircle = Circle(
                  circleId: const CircleId("lostCircle"),
                  center: LatLng(l.latitude!, l.longitude!),
                  radius: 320,
                  strokeColor: Color.fromARGB(255, 90, 90, 90),
                );

                setState(() {
                  circles.add(locationCircle);
                  circles.add(maxCircle);
                  circles.add(minCircle);
                  circles.add(lostCircle);
                });
              });
              _controller.complete(controller);
            },
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            markers: markers,
            circles: circles,
          )),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterTop,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addRandomMarker,
        label: const Text('Add random marker'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Future<void> addRandomMarker() async {
    final GoogleMapController controller = await _controller.future;
    var userLocation = await location.getLocation();
    print(userLocation);
    var randomLatLng = getRandomLocation(
        LatLng(userLocation.latitude!, userLocation.longitude!), 30, 20);

    Marker randomMarker = Marker(
      markerId: const MarkerId("randomMarker"),
      position: randomLatLng,
    );

    setState(() {
      markers.add(randomMarker);
    });
  }
}
