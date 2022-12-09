import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:pedometer/pedometer.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';
import 'package:flutter_foreground_service/flutter_foreground_service.dart';

DateTime now = DateTime.now();
DateTime selectedDate = now;
double kcalGoal = 400.0;
double stepGoal = 10000.0;
double timeGoal = 7000.0;
String bufferNow = "";

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
            backgroundColor: const Color.fromARGB(255, 124, 77, 255),
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
  bool _bStateLeft = false;
  bool _bStateRight = false;
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = 'Loading', _steps = '0';

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 15), (Timer t) => dayChecker());
    Timer.periodic(const Duration(seconds: 1), (Timer t) => walkingTime());
    retrieveDate();
    WidgetsBinding.instance.addObserver(this);
    initPlatformState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      saveValue();
    }
  }

  double stepGoalPercentage() {
    double percentage;
    try {
      percentage = double.parse(dailySteps()) / stepGoal;
    } catch (e) {
      percentage = 0.0;
    }
    if (percentage > 1.0) percentage = 1.0;
    return percentage;
  }

  double kcalGoalPercentage() {
    double percentage;
    try {
      percentage = caloriesBurned() / kcalGoal;
    } catch (e) {
      percentage = 0.0;
    }
    if (percentage > 1.0) percentage = 1.0;
    return percentage;
  }

  double timeGoalPercentage() {
    double percentage;
    try {
      percentage = activeTime / timeGoal;
    } catch (e) {
      percentage = 0.0;
    }
    if (percentage > 1.0) percentage = 1.0;
    return percentage;
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
      activeTime = 0;
      bufferNow = DateFormat.MMMd().format(now);
    }
  }

  String dailySteps() {
    return (int.parse(_steps) - previousSteps).toString();
  }

  String goalChecker() {
    int step = stepGoal.toInt() - int.parse(_steps) - previousSteps;
    return (step > 0) ? step.toString() : "You Reached Your Goal!";
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

  Future<void> retrieveDate() async {
    final prefs = await SharedPreferences.getInstance();

    bufferNow = prefs.getString('bufferNow') ?? DateFormat.MMMd().format(now);
    activeTime = prefs.getInt('activeTime') ?? 0;
    previousSteps = prefs.getInt('previousSteps') ?? 0;
  }

  final globalKey = GlobalKey<ScaffoldState>();

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
            backgroundColor: const Color.fromARGB(255, 124, 77, 255),
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
                    decoration:
                        BoxDecoration(color: Color.fromARGB(255, 124, 77, 255)),
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
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 200, 200, 255),
                Color.fromARGB(255, 255, 255, 255)
              ],
              begin: Alignment.topCenter,
              end: Alignment.center,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const SizedBox(),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                TextButton(
                    child: const Text("<"),
                    onPressed: () {
                      setState(() {
                        selectedDate =
                            selectedDate.subtract(const Duration(days: 1));
                      });
                    }),
                Text(DateFormat.MMMd().format(selectedDate),
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold)),
                TextButton(
                    child: const Text(">"),
                    onPressed: () {
                      setState(() {
                        selectedDate =
                            selectedDate.add(const Duration(days: 1));
                      });
                    })
              ]),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                GestureDetector(
                    onTap: () {
                      setState(() {
                        _bStateLeft = !_bStateLeft;
                        _bStateRight = false;
                      });
                    },
                    child: SizedBox(
                        width: (MediaQuery.of(context).size.width / 3),
                        child: CircularPercentIndicator(
                          radius: 30.0,
                          lineWidth: 4.0,
                          center: _bStateLeft
                              ? const Text("Steps")
                              : const Text("Time"),
                          percent: _bStateLeft
                              ? stepGoalPercentage()
                              : timeGoalPercentage(),
                          backgroundColor: _bStateLeft
                              ? const Color.fromARGB(255, 130, 205, 71)
                              : const Color.fromARGB(255, 71, 71, 205),
                          circularStrokeCap: CircularStrokeCap.butt,
                          progressColor:
                              const Color.fromARGB(255, 124, 77, 255),
                        ))),
                Center(
                    child: SizedBox(
                        width: (MediaQuery.of(context).size.width / 3),
                        child: Center(
                            child: SizedBox(
                                width: 140.0,
                                height: 140.0,
                                child: LiquidCircularProgressIndicator(
                                  value: _bStateLeft
                                      ? timeGoalPercentage()
                                      : _bStateRight
                                          ? kcalGoalPercentage()
                                          : stepGoalPercentage(),
                                  center: _bStateLeft
                                      ? Text(
                                          "${(activeTime ~/ 3600).toString().padLeft(2, '0')}:${((activeTime % 3600) ~/ 60).toString().padLeft(2, '0')}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        )
                                      : _bStateRight
                                          ? Text(
                                              caloriesBurned()
                                                  .toInt()
                                                  .toString(),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15),
                                            )
                                          : Text(
                                              dailySteps(),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15),
                                            ),
                                  borderColor: _bStateLeft
                                      ? const Color.fromARGB(255, 71, 71, 205)
                                      : _bStateRight
                                          ? const Color.fromARGB(
                                              255, 205, 71, 71)
                                          : const Color.fromARGB(
                                              255, 130, 205, 71),
                                  borderWidth: 5.0,
                                  backgroundColor:
                                      const Color.fromARGB(0, 0, 0, 0),
                                  direction: Axis.vertical,
                                  valueColor: const AlwaysStoppedAnimation(
                                      Color.fromARGB(255, 124, 77, 255)),
                                ))))),
                GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      setState(() {
                        _bStateRight = !_bStateRight;
                        _bStateLeft = false;
                      });
                    },
                    child: SizedBox(
                        width: (MediaQuery.of(context).size.width / 3),
                        child: CircularPercentIndicator(
                          radius: 30.0,
                          lineWidth: 4.0,
                          center: _bStateRight
                              ? const Text("Steps")
                              : const Text("Kcal"),
                          percent: _bStateRight
                              ? stepGoalPercentage()
                              : kcalGoalPercentage(),
                          backgroundColor: _bStateRight
                              ? const Color.fromARGB(255, 130, 205, 71)
                              : const Color.fromARGB(255, 205, 71, 71),
                          circularStrokeCap: CircularStrokeCap.butt,
                          progressColor:
                              const Color.fromARGB(255, 124, 77, 255),
                        )))
              ]),
              Row(children: [
                SizedBox(
                  width: (MediaQuery.of(context).size.width / 3),
                  child: Column(
                    children: [
                      Image.asset('Assets/steps.png', width: 20, height: 20),
                      Text(goalChecker(),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const Text('Steps Left', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                SizedBox(
                  width: (MediaQuery.of(context).size.width / 3),
                  child: Column(
                    children: [
                      Image.asset('Assets/clock.png', width: 20, height: 20),
                      Text(
                          "${(activeTime ~/ 3600).toString().padLeft(2, '0')}:${((activeTime % 3600) ~/ 60).toString().padLeft(2, '0')}",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const Text('Hours', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                SizedBox(
                  width: (MediaQuery.of(context).size.width / 3),
                  child: Column(
                    children: [
                      Image.asset('Assets/fire.png', width: 20, height: 20),
                      Text(caloriesBurned().toInt().toString(),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const Text('kcal', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ]),
              const Divider(
                thickness: 1,
                color: Color.fromARGB(255, 124, 77, 255),
              ),
              const Text(
                'Pedestrian status:',
                style: TextStyle(fontSize: 15),
              ),
              Image.asset(
                  _status == 'walking'
                      ? 'Assets/walking.png'
                      : _status == 'stopped'
                          ? 'Assets/standing.png'
                          : 'Assets/loading_p.gif', // kalitesiz, değiştir
                  width: 80,
                  height: 80),
              Center(
                child: Text(
                  _status,
                  style: _status == 'walking' || _status == 'stopped'
                      ? const TextStyle(fontSize: 20)
                      : const TextStyle(fontSize: 15),
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
