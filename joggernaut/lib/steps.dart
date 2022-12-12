import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';

//import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pedometer/pedometer.dart';
import 'package:intl/intl.dart';
import 'package:flutter_foreground_service/flutter_foreground_service.dart';

DateTime now = DateTime.now();
DateTime selectedDate = now;
//const double pi = 3.1415926535897932;

const Color purple = Color.fromARGB(255, 124, 77, 255);
const Color black = Color.fromARGB(255, 14, 14, 14);
const Color greenBright = Color.fromARGB(255, 130, 205, 71);
const Color green = Color.fromARGB(255, 84, 180, 53);
const Color greenDark = Color.fromARGB(255, 55, 146, 55);
const Color yellow = Color.fromARGB(255, 240, 255, 66);
const Color blue = Color.fromARGB(255, 33, 71, 132);
const Color mainColor = blue;

String formatDate(DateTime d) {
  return d.toString().substring(0, 19);
}

void startForegroundService() async {
  ForegroundService().start();
}

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
      width: (MediaQuery.of(context).size.width / 4),
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
  int previousSteps = 0; //database
  int activeTime = 0; //database?
  int weight = 70; //database

  double kcalGoal = 400.0;
  double stepGoal = 10000.0;
  double timeGoal = 7000.0;

  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;

  String _status = 'Loading';
  String _steps = '0';
  String bufferNow = "";

  @override
  void initState() {
    super.initState();

    Timer.periodic(const Duration(seconds: 15), (Timer t) => dayChecker());
    Timer.periodic(const Duration(seconds: 1), (Timer t) => walkingTime());

    WidgetsBinding.instance.addObserver(this);
    retrieveData();

    initPlatformState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      saveValue();
    }
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
    if (bufferNow != DateFormat.MMMd().format(now)) {
      saveStep();
      setState(() {
        previousSteps = int.parse(_steps);
        activeTime = 0;
        selectedDate = now;
        bufferNow = DateFormat.MMMd().format(now);
      });
    }
  }

  String dailySteps() {
    return (int.parse(_steps) - previousSteps).toString();
  }

  String goalChecker() {
    int step = stepGoal.toInt() - int.parse(_steps) - previousSteps;
    return (step < 0) ? step.toString() : "0";
  }

  void walkingTime() {
    if (_status == "walking") ++activeTime;
  }

  double caloriesBurned() {
    return double.parse(dailySteps()) * 0.04 * (weight / 75);
  }

  Future<void> saveValue() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('bufferNow', DateFormat.MMMd().format(now));
    await prefs.setInt('activeTime', activeTime);
  }

  Future<void> saveStep() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt("previousSteps", int.parse(_steps));
  }

  Future<void> retrieveData() async {
    final prefs = await SharedPreferences.getInstance();

    bufferNow = prefs.getString('bufferNow') ?? DateFormat.MMMd().format(now);
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

  SizedBox circularGoal(
      double percentage, double size, String icon, String value, String label) {
    return SizedBox(
        height: size,
        width: size,
        child: SfRadialGauge(
            enableLoadingAnimation: true,
            animationDuration: 1500,
            axes: <RadialAxis>[
              RadialAxis(
                  //startAngle: 270, çember
                  //endAngle: 270,
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
                      cornerStyle: CornerStyle.bothCurve,
                      value: percentage * 100,
                      width: 0.10,
                      sizeUnit: GaugeSizeUnit.factor,
                      gradient: const SweepGradient(colors: <Color>[
                        // Color.fromARGB(255, 55, 20, 141),
                        // Color.fromARGB(255, 136, 93, 255)
                        //Color.fromARGB(255, 5, 233, 9),
                        // Color.fromARGB(255, 22, 167, 66)
                        Color.fromARGB(255, 55, 99, 250),
                        blue
                        //Colors.green,
                        //Colors.yellow,
                        //Colors.red
                      ], stops: <double>[
                        0.25,
                        0.75
                      ]),
                    )
                  ]),
            ]));
  }

  final globalKey = GlobalKey<ScaffoldState>();

  List switchValue(int a) {
    String value = "";
    double percent = 0.0;

    switch (a) {
      case 0:
        value = dailySteps();
        percent = stepGoalPercentage();
        break;
      case 1:
        value =
            "${(activeTime ~/ 3600).toString().padLeft(2, '0')}:${((activeTime % 3600) ~/ 60).toString().padLeft(2, '0')}";
        percent = timeGoalPercentage();
        break;
      case 2:
        value = caloriesBurned().toInt().toString();
        percent = kcalGoalPercentage();
        break;
      case 3:
        value = "30";
        percent = 0.9;
        break;
    }
    return [percent, value];
  }

  late List<dynamic> focus = [0, 'Assets/blue/steps.png', 'Steps'];
  late List<dynamic> left = [1, "Assets/blue/clock.png", "Hours"];
  late List<dynamic> center = [2, "Assets/blue/fire.png", "Kcal"];
  late List<dynamic> right = [3, "Assets/home.png", "label"];

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
              icon: const Icon(Icons.density_medium),
              onPressed: () {
                globalKey.currentState!.openDrawer();
              },
            )),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              SizedBox(
                  height: AppBar().preferredSize.height + kToolbarHeight,
                  child: const DrawerHeader(
                    decoration: BoxDecoration(color: mainColor),
                    child: Text('Dashboard'),
                  )),
              ListTile(
                title: const Text('Item 1'),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Item 2'),
                onTap: () {},
              ),
            ],
          ),
        ),
        body: Container(
          color: black,
          // decoration: const BoxDecoration(
          //   gradient: LinearGradient(
          //     colors: [
          //       Color.fromARGB(255, 200, 200, 255),
          //       Color.fromARGB(255, 255, 255, 255)
          //     ],
          //     begin: Alignment.topCenter,
          //     end: Alignment.center,
          //   ),
          //),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              //const SizedBox(),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                TextButton(
                    child: const Text("<"),
                    onPressed: () {
                      setState(() {
                        selectedDate =
                            selectedDate.subtract(const Duration(days: 1));
                      });
                    }),
                Text(
                    (selectedDate != now)
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
                        if (selectedDate != now) {
                          selectedDate =
                              selectedDate.add(const Duration(days: 1));
                        }
                      });
                    })
              ]),
              //iç içe su

              // Stack(
              //   children: [
              //     Transform(
              //         alignment: Alignment.center,
              //         transform: Matrix4.rotationY(pi * 4),
              //         child: SizedBox(
              //             height: 100,
              //             width: 100,
              //             child: LiquidCircularProgressIndicator(
              //               value: 0.75,
              //               valueColor: AlwaysStoppedAnimation(
              //                   Color.fromARGB(255, 20, 153, 62)),
              //               backgroundColor: Color.fromARGB(0, 251, 251, 251),
              //             ))),
              //     SizedBox(
              //         height: 100,
              //         width: 100,
              //         child: LiquidCircularProgressIndicator(
              //           value: 0.75,
              //           valueColor: AlwaysStoppedAnimation(Colors.green),
              //           backgroundColor: Color.fromARGB(0, 244, 4, 4),
              //         )),
              //   ],
              // ),

              circularGoal(switchValue(focus[0])[0], 200.0, focus[1],
                  switchValue(focus[0])[1], focus[2]),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onLongPress: () {
                      swapFocus("left");
                    },
                    child: SizedBox(
                        width: (MediaQuery.of(context).size.width / 3),
                        height: 100,
                        child: circularGoal(switchValue(left[0])[0], 100.0,
                            left[1], switchValue(left[0])[1], left[2]))),
                GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onLongPress: () {
                      swapFocus("center");
                    },
                    child: SizedBox(
                        width: (MediaQuery.of(context).size.width / 3),
                        height: 100,
                        child: circularGoal(switchValue(center[0])[0], 100.0,
                            center[1], switchValue(center[0])[1], center[2]))),
                GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onLongPress: () {
                      swapFocus("right");
                    },
                    child: SizedBox(
                        width: (MediaQuery.of(context).size.width / 3),
                        height: 100,
                        child: circularGoal(switchValue(right[0])[0], 100.0,
                            right[1], switchValue(right[0])[1], right[2]))),
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
                    onPressed: () {},
                  ),
                  NavigationButton(
                    key: const Key('MapButton'),
                    text: 'Map',
                    image: 'Assets/map.png',
                    onPressed: () {},
                  ),
                  NavigationButton(
                    key: const Key('RaceButton'),
                    text: 'Race',
                    image: 'Assets/race.png',
                    onPressed: () {},
                  ),
                  NavigationButton(
                    key: const Key('LeaderboardButton'),
                    text: 'Leaderboard',
                    image: 'Assets/leaderboard.png',
                    onPressed: () {},
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
