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
  final TextEditingController _searchController = TextEditingController();
  Location location = Location();

  Set<Marker> markers = Set();
  Set<Circle> circles = Set();

  // Get a random coordinate around the user
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

  // Claim the flag if it's in user's range
  Future<void> claimFlag() async {
    // 109.84697079152 m in users range to claim the flag
    // 319.8563475922185m out of lost range

    if (markers.isNotEmpty) {
      LocationData userLocation = await location.getLocation();

      double distanceToTheFlag = getDistanceBetweenTwoPointsInMeters(
          markers.first.position.latitude,
          markers.first.position.longitude,
          userLocation.latitude!,
          userLocation.longitude!);

      if (distanceToTheFlag <= 110) {
        markers = Set();
        addRandomMarker();

        // addFlagPoint();
      }
    }
  }

  double deg2rad(deg) {
    return deg * (pi / 180);
  }

  double getDistanceBetweenTwoPointsInMeters(lat1, lon1, lat2, lon2) {
    var R = 6371; // Radius of the earth in km
    var dLat = deg2rad(lat2 - lat1); // deg2rad below
    var dLon = deg2rad(lon2 - lon1);
    var a = sin(dLat / 2) * sin(dLat / 2) +
        cos(deg2rad(lat1)) * cos(deg2rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    var d = R * c; // Distance in km
    return d * 1000;
  }

  static const initialPosition = CameraPosition(
    target: LatLng(41, 28),
    zoom: 14.4746,
  );

  void mapCreatedCallback(GoogleMapController controller) {
    location.onLocationChanged.listen((l) {
      Circle locationCircle = Circle(
        circleId: const CircleId("locationCircle"),
        center: LatLng(l.latitude!, l.longitude!),
        radius: 110,
        strokeWidth: 1,
        fillColor: Color.fromARGB(106, 16, 148, 230),
        strokeColor: const Color.fromARGB(204, 16, 148, 230),
      );

      // Debug Circles

      // Circle maxCircle = Circle(
      //   circleId: const CircleId("maxCircle"),
      //   center: LatLng(l.latitude!, l.longitude!),
      //   radius: 300,
      //   strokeColor: Color.fromARGB(204, 230, 62, 16),
      // );
      // Circle minCircle = Circle(
      //   circleId: const CircleId("minCircle"),
      //   center: LatLng(l.latitude!, l.longitude!),
      //   radius: 150,
      //   strokeColor: Color.fromARGB(204, 230, 62, 16),
      // );
      Circle lostCircle = Circle(
        circleId: const CircleId("lostCircle"),
        center: LatLng(l.latitude!, l.longitude!),
        radius: 320,
        strokeWidth: 3,
        strokeColor: Color.fromARGB(255, 208, 5, 5),
      );

      // End of Debug Circles

      setState(() {
        if (markers.isNotEmpty) {
          double distanceToTheFlag = getDistanceBetweenTwoPointsInMeters(
              markers.first.position.latitude,
              markers.first.position.longitude,
              l.latitude,
              l.longitude);
          if (distanceToTheFlag >= 320) {
            markers = Set();
            addRandomMarker();
          }
        } else {
          markers = Set();
          addRandomMarker();
        }

        circles.add(locationCircle);
        // circles.add(maxCircle);
        // circles.add(minCircle);
        circles.add(lostCircle);
      });
    });
    _controller.complete(controller);
  }

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
                mapCreatedCallback(controller);
              },
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              markers: markers,
              circles: circles,
            ),
          ),
          // Flexible(
          //   child: Scaffold(
          //     body: Center(
          //       child: ButtonBar(
          //         mainAxisSize: MainAxisSize.min,
          //         children: <Widget>[
          //           ElevatedButton(
          //             onPressed: addRandomMarker,
          //             child: const Text("Add Random Marker"),
          //           ),
          //           ElevatedButton(
          //             onPressed: claimFlag,
          //             child: const Text("Claim Flag"),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: claimFlag,
        label: const Text('Claim the Flag'),
        icon: const Icon(Icons.flag),
      ),
    );
  }

  Future<void> addRandomMarker() async {
    markers = Set();
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
