import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:joggernaut/map_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pedometer/pedometer.dart';
import 'package:intl/intl.dart';
import 'BETUL/leaderboard-adim.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:permission_handler/permission_handler.dart';
import 'ZEYNEP/SettingsPage.dart';

DateTime selectedDate = DateTime.now();

const Color purple = Color.fromARGB(255, 124, 77, 255);
const Color black = Color.fromARGB(255, 14, 14, 14);
const Color greenBright = Color.fromARGB(255, 130, 205, 71);
const Color green = Color.fromARGB(255, 84, 180, 53);
const Color greenDark = Color.fromARGB(255, 55, 146, 55);
const Color yellow = Color.fromARGB(255, 240, 255, 66);
const Color blue = Color.fromARGB(255, 33, 71, 132);
const Color mainColor = blue;

class NavigationButton extends StatelessWidget {
  final String text;
  final String image;
  final void Function()? onPressed;

  const NavigationButton({
    required Key key,
    required this.text,
    required this.image,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width / 3),
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            backgroundColor: mainColor,
            textStyle:
                const TextStyle(fontSize: 11.0, fontWeight: FontWeight.bold),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
              topRight: Radius.circular(0.0),
              topLeft: Radius.circular(0.0),
            ))),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [Text(text), Image.asset(image, width: 20, height: 20)]),
      ),
    );
  }
}

class StepsPage extends StatefulWidget {
  const StepsPage({super.key});
  @override
  StateStepsPage createState() => StateStepsPage();
}

class StateStepsPage extends State<StepsPage> with WidgetsBindingObserver {
  int previousSteps = 0; // database?
  int activeTime = 0; // database
  int weight = 0; // database
  int height = 0;

  double kcalGoal = 400.0; // database
  double stepGoal = 10000.0; // database
  double timeGoal = 7000.0; // database
  double kmGoal = 0.00;

  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;

  String _status = 'Loading';
  String _steps = '0';
  String bufferNow = "";
  String selectedTime = "00:00";
  String selectedKcal = "0";
  String selectedSteps = "0";
  String selectedKm = "0.00";

  bool isSelectedDayToday = true;

  @override
  void initState() {
    super.initState();

    Timer.periodic(const Duration(seconds: 15), (Timer t) => dayChecker());
    Timer.periodic(const Duration(seconds: 1), (Timer t) => walkingTime());

    WidgetsBinding.instance.addObserver(this);
    retrieveData();
    _requestPermission();
    initData();
    initPlatformState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      saveValue();
    }
  }

  final FirebaseAuth auth = FirebaseAuth.instance;
  void saveToDB() async {
    final User user = auth.currentUser!;
    final collectionReference = FirebaseFirestore.instance.collection('users');

    final query = collectionReference.where('email', isEqualTo: user.email);
    final querySnapshot = await query.get();

    if (querySnapshot.docs.isNotEmpty) {
      final documentSnapshot = querySnapshot.docs.first;
      await documentSnapshot.reference.set({
        'step': int.parse(_steps),
        'calendar': {
          now(): {
            'step': dailySteps(),
            'time': dailyTime(),
            'kcal': caloriesBurned().toInt().toString(),
            'km': kmRunned().toString(),
          }
        }
      }, SetOptions(merge: true));
    }
  }

  void reset() {
    selectedTime = "00:00";
    selectedKcal = "0";
    selectedSteps = "0";
    selectedKm = "0.00";
  }

  void initData() async {
    final User user = auth.currentUser!;
    final collectionReference = FirebaseFirestore.instance.collection('users');

    final query = collectionReference.where('email', isEqualTo: user.email);
    final querySnapshot = await query.get();
    setState(() {
      if (querySnapshot.docs.isNotEmpty) {
        final db = querySnapshot.docs.first;
        height = db.data()['height'];
        weight = db.data()['weight'];
        stepGoal = db.data()['stepGoal'];
        kcalGoal = db.data()['kcalGoal'];
        timeGoal = db.data()['timeGoal'];
        kmGoal = db.data()['kmGoal'];
      }
    });
  }

  void getData() async {
    final User user = auth.currentUser!;
    final collectionReference = FirebaseFirestore.instance.collection('users');

    final query = collectionReference.where('email', isEqualTo: user.email);
    final querySnapshot = await query.get();
    setState(() {
      if (querySnapshot.docs.isNotEmpty) {
        final db = querySnapshot.docs.first;
        try {
          final data =
              db.data()['calendar'][DateFormat.MMMd().format(selectedDate)];
          selectedTime = data["time"];
          selectedKcal = data["kcal"];
          selectedSteps = data["step"];
          selectedKm = data["km"];
        } catch (e) {
          reset();
        }
      } else {
        reset();
      }
    });
  }

  double goalPercentage(double goal, double progress) {
    double percentage = progress / goal;
    if (percentage > 1.0) percentage = 1.0;
    return percentage;
  }

  double stepGoalPercentage() {
    return goalPercentage(stepGoal, double.parse(dailySteps()));
  }

  double kcalGoalPercentage() {
    return goalPercentage(kcalGoal, caloriesBurned());
  }

  double timeGoalPercentage() {
    return goalPercentage(timeGoal, activeTime.toDouble());
  }

  double kmGoalPercentage() {
    return goalPercentage(kmGoal, kmRunned());
  }

  void onStepCount(StepCount event) {
    setState(() {
      _steps = event.steps.toString();
    });
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    setState(() {
      _status = event.status;
    });
  }

  void onPedestrianStatusError(error) {
    setState(() {
      _status = 'Loading';
    });
  }

  void onStepCountError(error) {
    setState(() {
      _steps = '0';
    });
  }

  void initPlatformState() {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);

    if (!mounted) return;
  }

  void dayChecker() {
    // kaydedilen ay/gün şuanki tarihten farklıysa gün değişmiştir
    if (bufferNow != now()) {
      saveStep();
      setState(() {
        previousSteps = int.parse(_steps);
        activeTime = 0;
        selectedDate = DateTime.now();
        bufferNow = now();
      });
    }
    if (isSelectedDayToday) saveToDB();
  }

  void walkingTime() {
    if (_status == "walking") ++activeTime;
  }

  void _requestPermission() async {
    // Check if the permission is already granted
    PermissionStatus permissionStatus = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.sensors);
    if (permissionStatus == PermissionStatus.granted) {
      // Permission already granted, do nothing
      return;
    }

    // Check if the user has previously denied the permission
    bool shouldShowRequestPermissionRationale = await PermissionHandler()
        .shouldShowRequestPermissionRationale(PermissionGroup.sensors);

    if (shouldShowRequestPermissionRationale) {
      // Provide an explanation before requesting the permission again
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Permission needed'),
          content: const Text(
              'We need access to your pedometer data to provide step count information. Please grant the permission.'),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Ok'),
              onPressed: () {
                // Request the permission again
                _requestPermission();
              },
            ),
          ],
        ),
      );
      return;
    }

    // Request the permission
    Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler().requestPermissions([PermissionGroup.sensors]);

    if (permissions[PermissionGroup.sensors] == PermissionStatus.granted) {
      // Permission granted, do something
    } else {
      // Permission denied, do something else
    }
  }

  void swapFocus(String direction) {
    setState(() {
      final temp = focus;
      if (direction == 'left') {
        focus = left;
        left = temp;
      } else if (direction == 'center') {
        focus = center;
        center = temp;
      } else if (direction == 'right') {
        focus = right;
        right = temp;
      }
    });
  }

  String now() {
    return DateFormat.MMMd().format(DateTime.now());
  }

  String dailyTime() {
    return (isSelectedDayToday)
        ? "${(activeTime ~/ 3600).toString().padLeft(2, '0')}:${((activeTime % 3600) ~/ 60).toString().padLeft(2, '0')}"
        : selectedTime;
  }

  String dailySteps() {
    return (isSelectedDayToday)
        ? (int.parse(_steps) - previousSteps).toString()
        : selectedSteps;
  }

  String stepsLeft() {
    int step = stepGoal.toInt() - (int.parse(_steps) - previousSteps);
    return (step < 0) ? step.toString() : "0";
  }

  double caloriesBurned() {
    return (isSelectedDayToday)
        ? double.parse(dailySteps()) * 0.04 * (weight / 75)
        : double.parse(selectedKcal);
  }

  double kmRunned() {
    return (isSelectedDayToday)
        ? double.parse(dailySteps()) * 0.00065 * (height / 175)
        : double.parse(selectedKcal);
  }

  Future<void> saveValue() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('bufferNow', now());
    await prefs.setInt('activeTime', activeTime);
    saveToDB();
  }

  Future<void> saveStep() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt("previousSteps", int.parse(_steps));
  }

  Future<void> retrieveData() async {
    final prefs = await SharedPreferences.getInstance();

    bufferNow = prefs.getString('bufferNow') ?? now();
    activeTime = prefs.getInt('activeTime') ?? 0;
    previousSteps = prefs.getInt('previousSteps') ?? 0;
  }

  SizedBox activityBox(Image icon, String value, String label) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width / 3),
      child: Column(
        children: [
          icon,
          Text(value,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          Text(label,
              style: const TextStyle(fontSize: 14, color: Colors.white)),
        ],
      ),
    );
  }

  SizedBox circularGoalProgression(
      double percentage, double size, String icon, String value, String label) {
    return SizedBox(
        height: size,
        width: size,
        child: SfRadialGauge(
            enableLoadingAnimation: true,
            animationDuration: 1500,
            axes: <RadialAxis>[
              RadialAxis(
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                        widget: SizedBox(
                            height: 75, //pixel tasmasi
                            width: 75,
                            child: activityBox(
                                Image.asset(icon, width: 29, height: 29),
                                value,
                                label)))
                  ],
                  showLabels: false,
                  showTicks: false,
                  axisLineStyle: const AxisLineStyle(
                    color: Color.fromARGB(160, 160, 160, 160),
                    thickness: 0.06,
                    thicknessUnit: GaugeSizeUnit.factor,
                  ),
                  pointers: <GaugePointer>[
                    RangePointer(
                      value: percentage * 100,
                      width: 0.10,
                      sizeUnit: GaugeSizeUnit.factor,
                      gradient: const SweepGradient(colors: <Color>[
                        blue,
                        Color.fromARGB(255, 0, 200, 255)
                      ], stops: <double>[
                        0.25,
                        0.75
                      ]),
                    )
                  ]),
            ]));
  }

  final globalKey = GlobalKey<ScaffoldState>();

  List swapFocusValues(int a) {
    String value = "";
    double percent = 0.0;

    switch (a) {
      case 0:
        value = dailySteps();
        percent = stepGoalPercentage();
        break;
      case 1:
        value = dailyTime();
        percent = timeGoalPercentage();
        break;
      case 2:
        value = caloriesBurned().toInt().toString();
        percent = kcalGoalPercentage();
        break;
      case 3:
        value = kmRunned().toString();
        percent = kmGoalPercentage();
        break;
    }
    return [percent, value];
  }

  late List<dynamic> focus = [0, 'Assets/blue/steps.png', 'Steps'];
  late List<dynamic> left = [1, "Assets/blue/clock.png", "Hours"];
  late List<dynamic> center = [2, "Assets/blue/fire.png", "Kcal"];
  late List<dynamic> right = [3, "Assets/blue/distance.png", "Km"];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
            )),
        body: Container(
          color: black,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                TextButton(
                    child: const Text("<"),
                    onPressed: () {
                      setState(() {
                        selectedDate =
                            selectedDate.subtract(const Duration(days: 1));
                        isSelectedDayToday = false;
                        getData();
                      });
                    }),
                Text(
                    (DateFormat.MMMd().format(selectedDate) != now())
                        ? DateFormat.MMMd().format(selectedDate)
                        : "Today",
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                TextButton(
                    child: const Text(">"),
                    onPressed: () {
                      setState(() {
                        if (DateFormat.MMMd().format(selectedDate) != now()) {
                          selectedDate =
                              selectedDate.add(const Duration(days: 1));
                        }
                        if (DateFormat.MMMd().format(selectedDate) != now()) {
                          isSelectedDayToday = false;
                          getData();
                        } else {
                          isSelectedDayToday = true;
                          reset();
                        }
                      });
                    })
              ]),
              circularGoalProgression(swapFocusValues(focus[0])[0], 200.0,
                  focus[1], swapFocusValues(focus[0])[1], focus[2]),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onLongPress: () {
                      swapFocus("left");
                    },
                    child: SizedBox(
                        width: (MediaQuery.of(context).size.width / 3),
                        height: 100,
                        child: circularGoalProgression(
                            swapFocusValues(left[0])[0],
                            100.0,
                            left[1],
                            swapFocusValues(left[0])[1],
                            left[2]))),
                GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onLongPress: () {
                      swapFocus("center");
                    },
                    child: SizedBox(
                        width: (MediaQuery.of(context).size.width / 3),
                        height: 100,
                        child: circularGoalProgression(
                            swapFocusValues(center[0])[0],
                            100.0,
                            center[1],
                            swapFocusValues(center[0])[1],
                            center[2]))),
                GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onLongPress: () {
                      swapFocus("right");
                    },
                    child: SizedBox(
                        width: (MediaQuery.of(context).size.width / 3),
                        height: 100,
                        child: circularGoalProgression(
                            swapFocusValues(right[0])[0],
                            100.0,
                            right[1],
                            swapFocusValues(right[0])[1],
                            right[2]))),
              ]),
              const Divider(
                thickness: 1,
                color: mainColor,
              ),
              const Text(
                'Pedestrian status:',
                style: TextStyle(fontSize: 15, color: Colors.white),
              ),
              Image.asset(
                  _status == 'walking'
                      ? 'Assets/blue/walking.png'
                      : 'Assets/blue/standing.png',
                  width: 80,
                  height: 80),
              Center(
                child: Text(
                  _status,
                  style: _status == 'walking' || _status == 'stopped'
                      ? const TextStyle(fontSize: 20, color: Colors.white)
                      : const TextStyle(fontSize: 15, color: Colors.white),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
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
      ),
    );
  }
}
