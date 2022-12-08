import 'package:flutter/material.dart';
import 'dart:async';

import 'package:pedometer/pedometer.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';
import 'package:flutter_foreground_service/flutter_foreground_service.dart';

DateTime now = DateTime.now();

String formatDate(DateTime d) {
  return d.toString().substring(0, 19);
}

void main() {
  runApp(const MaterialApp(home: MyApp(), debugShowCheckedModeBanner: false));
  startForegroundService();
}

void startForegroundService() async {
  ForegroundService().start();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int previousSteps = 0;
  int activeTime = 0;
  int weight = 70;
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = '?', _steps = '0';

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 15), (Timer t) => dayChecker());
    Timer.periodic(const Duration(seconds: 1), (Timer t) => walkingTime());
    initPlatformState();
  }

  double percentageCal() {
    double percentage;
    try {
      percentage = double.parse(dailySteps()) / 10000.0;
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
      _status = 'Pedestrian Status not available';
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
    if (DateFormat.Hm().format(DateTime.now()) == "00:00") {
      previousSteps = int.parse(_steps);
      activeTime = 0;
    }
  }

  String dailySteps() {
    return (int.parse(_steps) - previousSteps).toString();
  }

  String goalChecker() {
    int step = 10000 - int.parse(_steps) - previousSteps;
    return (step > 0) ? step.toString() : "You Reached Your Goal!";
  }

  void walkingTime() {
    if (_status == "walking") activeTime += 1;
  }

  double caloriesBurned() {
    return double.parse(dailySteps()) * 0.04;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Joggernaut'),
          backgroundColor: const Color.fromARGB(255, 124, 77, 255),
        ),
        body: Container(
          color: const Color.fromARGB(255, 255, 255, 255),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              //Row(children: [
              // Image.asset('Assets/logopng.png',
              //     width: 130, height: 130, alignment: Alignment.topLeft),
              const SizedBox(height: 10),
              CircularPercentIndicator(
                radius: 80.0,
                lineWidth: 15.0,
                percent: percentageCal(),
                center: Text(
                  dailySteps(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15.0),
                ),
                backgroundColor: const Color.fromARGB(255, 130, 205, 71),
                circularStrokeCap: CircularStrokeCap.butt,
                progressColor: const Color.fromARGB(255, 68, 27, 183),
              ) /*])*/,
              Row(children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      MediaQuery.of(context).size.width / 7, 0, 0, 0),
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
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      MediaQuery.of(context).size.width / 6, 0, 0, 0),
                  child: Column(
                    children: [
                      Image.asset('Assets/time.png', width: 20, height: 20),
                      Text(
                          "${(activeTime ~/ 60).toString().padLeft(2, '0')}:${(activeTime % 60).toString().padLeft(2, '0')}",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const Text('Mins', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      MediaQuery.of(context).size.width / 6, 0, 0, 0),
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
                height: 100,
                thickness: 1,
                color: Color.fromARGB(255, 124, 77, 255),
              ),
              const Text(
                'Pedestrian status:',
                style: TextStyle(fontSize: 15),
              ),
              Icon(
                _status == 'walking'
                    ? Icons.directions_walk
                    : _status == 'stopped'
                        ? Icons.accessibility_new
                        : Icons.error,
                size: 80,
              ),
              Center(
                child: Text(
                  _status,
                  style: _status == 'walking' || _status == 'stopped'
                      ? const TextStyle(fontSize: 30)
                      : const TextStyle(fontSize: 20),
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
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.bold),
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(0.0),
                                  topLeft: Radius.circular(0.0),
                                ))),
                            child: const Text('Home'))),
                    SizedBox(
                        width: (MediaQuery.of(context).size.width / 4),
                        height: 50,
                        child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 124, 77, 255),
                                textStyle: const TextStyle(
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.bold),
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(0.0),
                                  topLeft: Radius.circular(0.0),
                                ))),
                            child: const Text('Map'))),
                    SizedBox(
                        width: (MediaQuery.of(context).size.width / 4),
                        height: 50,
                        child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 124, 77, 255),
                                textStyle: const TextStyle(
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.bold),
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(0.0),
                                  topLeft: Radius.circular(0.0),
                                ))),
                            child: const Text('Race'))),
                    SizedBox(
                      width: (MediaQuery.of(context).size.width / 4),
                      height: 50,
                      child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 124, 77, 255),
                              textStyle: const TextStyle(
                                  fontSize: 10.0, fontWeight: FontWeight.bold),
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                topRight: Radius.circular(0.0),
                                topLeft: Radius.circular(0.0),
                              ))),
                          child: const Text('Leaderboard')),
                    ),
                  ])
            ],
          ),
        ),
      ),
    );
  }
}
