import 'package:flutter/material.dart';
import 'dart:async';

import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:pedometer/pedometer.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';
import 'package:flutter_foreground_service/flutter_foreground_service.dart';

DateTime now = DateTime.now();
DateTime bufferNow = now; //database?
DateTime selectedDate = now;
double kcalGoal = 400.0;
double stepGoal = 10000.0;
double timeGoal = 7000.0;

String formatDate(DateTime d) {
  return d.toString().substring(0, 19);
}

void startForegroundService() async {
  ForegroundService().start();
}

class StepsPage extends StatefulWidget {
  const StepsPage({super.key});
  @override
  StateStepsPage createState() => StateStepsPage();
}

class StateStepsPage extends State<StepsPage> {
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
    initPlatformState();
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
    if (DateFormat.MMMd().format(bufferNow) != DateFormat.MMMd().format(now)) {
      previousSteps = int.parse(_steps);
      activeTime = 0;
      bufferNow = now;
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
    return double.parse(dailySteps()) * 0.04;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('    Joggernaut'),
          backgroundColor: const Color.fromARGB(255, 124, 77, 255),
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

          //color: Color.fromARGB(255, 255, 255, 255),
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
                        child: _bStateLeft
                            ? CircularPercentIndicator(
                                radius: 30.0,
                                lineWidth: 4.0,
                                center: const Text("Steps"),
                                percent: stepGoalPercentage(),
                                backgroundColor:
                                    const Color.fromARGB(255, 130, 205, 71),
                                circularStrokeCap: CircularStrokeCap.butt,
                                progressColor:
                                    const Color.fromARGB(255, 124, 77, 255),
                              )
                            : CircularPercentIndicator(
                                radius: 30.0,
                                lineWidth: 4.0,
                                center: const Text("Time"),
                                percent: timeGoalPercentage(),
                                backgroundColor:
                                    const Color.fromARGB(255, 130, 205, 71),
                                circularStrokeCap: CircularStrokeCap.butt,
                                progressColor:
                                    const Color.fromARGB(255, 124, 77, 255)))),
                Center(
                    child: SizedBox(
                        width: (MediaQuery.of(context).size.width / 3),
                        child: _bStateLeft
                            ? SizedBox(
                                width: 140.0,
                                height: 140.0,
                                child: LiquidCircularProgressIndicator(
                                    value: timeGoalPercentage(),
                                    center: Text(
                                      "${(activeTime ~/ 60).toString().padLeft(2, '0')}:${(activeTime % 60).toString().padLeft(2, '0')}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
                                    borderColor:
                                        const Color.fromARGB(255, 130, 205, 71),
                                    borderWidth: 5.0,
                                    backgroundColor:
                                        const Color.fromARGB(0, 0, 0, 0),
                                    direction: Axis.vertical,
                                    valueColor: const AlwaysStoppedAnimation(
                                        Color.fromARGB(255, 124, 77, 255))))
                            : _bStateRight
                                ? SizedBox(
                                    width: 140.0,
                                    height: 140.0,
                                    child: LiquidCircularProgressIndicator(
                                        value: kcalGoalPercentage(),
                                        center: Text(
                                          caloriesBurned().toString(),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                        borderColor: const Color.fromARGB(
                                            255, 130, 205, 71),
                                        borderWidth: 5.0,
                                        backgroundColor:
                                            const Color.fromARGB(0, 0, 0, 0),
                                        direction: Axis.vertical,
                                        valueColor: const AlwaysStoppedAnimation(
                                            Color.fromARGB(255, 124, 77, 255))))
                                : SizedBox(
                                    width: 140.0,
                                    height: 140.0,
                                    child: LiquidCircularProgressIndicator(
                                        value: stepGoalPercentage(),
                                        center: Text(
                                          dailySteps(),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                        backgroundColor:
                                            const Color.fromARGB(0, 0, 0, 0),
                                        borderColor: const Color.fromARGB(
                                            255, 130, 205, 71),
                                        borderWidth: 5.0,
                                        direction: Axis.vertical,
                                        valueColor: const AlwaysStoppedAnimation(
                                            Color.fromARGB(255, 124, 77, 255)))))),
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
                        child: _bStateRight
                            ? CircularPercentIndicator(
                                radius: 30.0,
                                lineWidth: 4.0,
                                center: const Text("Steps"),
                                percent: stepGoalPercentage(),
                                backgroundColor:
                                    const Color.fromARGB(255, 130, 205, 71),
                                circularStrokeCap: CircularStrokeCap.butt,
                                progressColor:
                                    const Color.fromARGB(255, 124, 77, 255),
                              )
                            : CircularPercentIndicator(
                                radius: 30.0,
                                lineWidth: 4.0,
                                center: const Text("Kcal"),
                                percent: kcalGoalPercentage(),
                                backgroundColor:
                                    const Color.fromARGB(255, 130, 205, 71),
                                circularStrokeCap: CircularStrokeCap.butt,
                                progressColor:
                                    const Color.fromARGB(255, 124, 77, 255))))
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
                          "${(activeTime ~/ 60).toString().padLeft(2, '0')}:${(activeTime % 60).toString().padLeft(2, '0')}", // saat ekle
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const Text('Mins', style: TextStyle(fontSize: 12)),
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
                    SizedBox(
                        width: (MediaQuery.of(context).size.width / 4),
                        height: 50,
                        child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 124, 77, 255),
                                textStyle: const TextStyle(
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.bold),
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(0.0),
                                  topLeft: Radius.circular(0.0),
                                ))),
                            child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Text('Home'),
                                  Image.asset('Assets/home.png',
                                      width: 20, height: 20)
                                ]))),
                    SizedBox(
                        width: (MediaQuery.of(context).size.width / 4),
                        height: 50,
                        child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 124, 77, 255),
                                textStyle: const TextStyle(
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.bold),
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(0.0),
                                  topLeft: Radius.circular(0.0),
                                ))),
                            child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Text('Map'),
                                  Image.asset('Assets/map.png',
                                      width: 20, height: 20)
                                ]))),
                    SizedBox(
                        width: (MediaQuery.of(context).size.width / 4),
                        height: 50,
                        child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 124, 77, 255),
                                textStyle: const TextStyle(
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.bold),
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(0.0),
                                  topLeft: Radius.circular(0.0),
                                ))),
                            child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Text('Race'),
                                  Image.asset('Assets/race.png',
                                      width: 20, height: 20)
                                ]))),
                    SizedBox(
                        width: (MediaQuery.of(context).size.width / 4),
                        height: 50,
                        child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 124, 77, 255),
                                textStyle: const TextStyle(
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.bold),
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(0.0),
                                  topLeft: Radius.circular(0.0),
                                ))),
                            child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Text('Leaderboard'),
                                  Image.asset('Assets/leaderboard.png',
                                      width: 20, height: 20)
                                ]))),
                  ])
            ],
          ),
        ),
      ),
    );
  }
}
