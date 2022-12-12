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
    //This is to generate 10 random points
    double x0 = point.latitude;
    double y0 = point.longitude;

    Random random = Random();

    int randomRadius = random.nextInt(radiusMax - radiusMin) + radiusMin;

    // Convert radius from meters to degrees
    double radiusInDegrees = randomRadius / 111000;

    double u = random.nextDouble();
    double v = random.nextDouble();
    double w = radiusInDegrees * sqrt(u);
    double t = 2 * pi * v;
    double x = w * cos(t);
    double y = w * sin(t) * 1.75;

    // Adjust the x-coordinate for the shrinking of the east-west distances
    double new_x = x / sin(y0);

    double foundLatitude = new_x + x0;
    double foundLongitude = y + y0;
    LatLng randomLatLng = LatLng(foundLatitude, foundLongitude);

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
            mapType: MapType.normal,
            initialCameraPosition: initialPosition,
            onMapCreated: (GoogleMapController controller) {
              location.onLocationChanged.listen((l) {
                Circle locationCircle = Circle(
                  circleId: const CircleId("locationCircle"),
                  center: LatLng(l.latitude!, l.longitude!),
                  radius: 500,
                  strokeColor: const Color.fromARGB(204, 16, 148, 230),
                );
                Circle maxCircle = Circle(
                  circleId: const CircleId("maxCircle"),
                  center: LatLng(l.latitude!, l.longitude!),
                  radius: 1500,
                  strokeColor: Color.fromARGB(204, 230, 62, 16),
                );
                Circle minCircle = Circle(
                  circleId: const CircleId("minCircle"),
                  center: LatLng(l.latitude!, l.longitude!),
                  radius: 700,
                  strokeColor: Color.fromARGB(204, 230, 62, 16),
                );

                setState(() {
                  circles.add(locationCircle);
                  circles.add(maxCircle);
                  circles.add(minCircle);
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
        LatLng(userLocation.latitude!, userLocation.longitude!), 1500, 700);

    Marker randomMarker = Marker(
      markerId: const MarkerId("randomMarker"),
      position: randomLatLng,
    );

    setState(() {
      markers.add(randomMarker);
    });
  }
}
