import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:joggernaut/BETUL/leaderboard-adim.dart';
import 'package:joggernaut/steps.dart';
import 'package:location/location.dart';
import 'dart:async';

import 'ZEYNEP/SettingsPage.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // Google Map Controller
  final Completer<GoogleMapController> _controller = Completer();

  // Firebase Instance
  final FirebaseAuth auth = FirebaseAuth.instance;

  final globalKey = GlobalKey<ScaffoldState>();

  Color mainColor = const Color.fromARGB(255, 33, 71, 132);
  Color black = Color.fromARGB(255, 220, 214, 214);

  Location location = Location();
  var flagPoint;
  Set<Marker> markers = Set();
  Set<Circle> circles = Set();

  @override
  void initState() {
    setFlagPointInit();
    super.initState();
  }

  // Gets the users flag point during the initialization
  Future<void> setFlagPointInit() async {
    try {
      // Gets the current signed in user
      final User user = auth.currentUser!;
      List currentUserData = [];

      // Gets the user's flag points from firebase
      await FirebaseFirestore.instance
          .collection('users')
          .where("email", isEqualTo: user.email)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((element) {
          if (mounted) {
            setState(() {
              currentUserData.add(element.data());
              flagPoint = currentUserData.first["flag"];
            });
          }
        });
      });
    } catch (e) {
      print(e.toString());
    }
  }

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

  // Adds a flag point to the user's account if the user claimed a flag
  Future addFlagPoint() async {
    try {
      final User user = auth.currentUser!;
      List currentUserData = [];
      var newFlagPoint, docID;

      // Gets user's flag points
      await FirebaseFirestore.instance
          .collection('users')
          .where("email", isEqualTo: user.email)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((element) {
          if (mounted) {
            setState(() {
              currentUserData.add(element.data());
              docID = element.id;
            });
          }
        });
      });

      newFlagPoint = currentUserData.first["flag"] + 1;

      if (mounted) {
        flagPoint = newFlagPoint;
      }

      // Sets user's new flag points
      FirebaseFirestore.instance
          .collection('users')
          .doc(docID)
          .update({"flag": newFlagPoint});
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Claim the flag if it's in user's range
  Future<void> claimFlag() async {
    if (markers.isNotEmpty) {
      LocationData userLocation = await location.getLocation();

      double distanceToTheFlag = getDistanceBetweenTwoPointsInMeters(
          markers.first.position.latitude,
          markers.first.position.longitude,
          userLocation.latitude!,
          userLocation.longitude!);

      // Checks to see if a flag is in the users claim range
      if (distanceToTheFlag <= 110) {
        addFlagPoint();
        markers = Set();
        addRandomMarker();
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

  void mapCreatedCallback(GoogleMapController controller) {
    location.onLocationChanged.listen((l) {
      // The circle which represents the user's claim range
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

      // End of Debug Circles

      // The circle which represents the user's range where the flag despawns
      Circle lostCircle = Circle(
        circleId: const CircleId("lostCircle"),
        center: LatLng(l.latitude!, l.longitude!),
        radius: 320,
        strokeWidth: 3,
        strokeColor: Color.fromARGB(255, 208, 5, 5),
      );

      if (mounted) {
        setState(() {
          if (markers.isNotEmpty) {
            double distanceToTheFlag = getDistanceBetweenTwoPointsInMeters(
                markers.first.position.latitude,
                markers.first.position.longitude,
                l.latitude,
                l.longitude);
            // Cheks to see if the flag went outside of the user's lost range during map callback
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
      }
    });
    _controller.complete(controller);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: globalKey,
        appBar: AppBar(
          title: const Text('Joggernaut'),
          backgroundColor: mainColor,
          leading: IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SettingsPage()));
            },
          ),
        ),
        body: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: GoogleMap(
                // The map
                compassEnabled: true,
                mapType: MapType.normal,
                initialCameraPosition: const CameraPosition(
                  target: LatLng(0, 0),
                  zoom: 15.5,
                ),
                onMapCreated: (GoogleMapController controller) async {
                  var here = await location.getLocation();
                  controller.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                          zoom: 15.5,
                          target: LatLng(here.latitude!, here.longitude!)),
                    ),
                  );
                  mapCreatedCallback(controller);
                },
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
                markers: markers,
                circles: circles,
              ),
            ),
            Flexible(
              child: Scaffold(
                backgroundColor: black,
                body: Center(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        // UI buttons
                        children: [
                          Image.asset("Assets/red-flag.png", height: 48),
                          Text(
                            '${flagPoint ?? "Loading"}',
                            style: const TextStyle(fontSize: 25),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: claimFlag,
                        child: const Text("Claim Flag"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Naavigation buttons
                NavigationButton(
                  key: const Key('HomeButton'),
                  text: 'Home',
                  image: 'Assets/home.png',
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const StepsPage()));
                  },
                ),
                NavigationButton(
                  key: const Key('RaceButton'),
                  text: 'Race',
                  image: 'Assets/race.png',
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MapPage()));
                  },
                ),
                NavigationButton(
                  key: const Key('LeaderboardButton'),
                  text: 'Leaderboard',
                  image: 'Assets/leaderboard.png',
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LeaderboardStep()));
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // Adds a random flag arount the user
  Future<void> addRandomMarker() async {
    BitmapDescriptor flagIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      "Assets/red-flag.png",
    );

    markers = Set();
    final GoogleMapController controller = await _controller.future;
    var userLocation = await location.getLocation();
    print(userLocation);
    var randomLatLng = getRandomLocation(
        LatLng(userLocation.latitude!, userLocation.longitude!), 30, 20);

    Marker randomMarker = Marker(
      markerId: const MarkerId("randomMarker"),
      position: randomLatLng,
      infoWindow: InfoWindow(title: "Claim to get a flag point!"),
      icon: flagIcon,
    );

    if (mounted) {
      setState(() {
        markers.add(randomMarker);
      });
    }
  }
}
