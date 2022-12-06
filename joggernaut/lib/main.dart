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
  runApp(MaterialApp(home: MyApp()));
  startForegroundService();
}

void startForegroundService() async {
  ForegroundService().start();
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int previousSteps = 0;
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = '?', _steps = '0';

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 15), (Timer t) => dayChecker());
    initPlatformState();
  }

  double percentageCal() {
    double percentage;
    try {
      percentage = double.parse(dailySteps()) / 10000.0;
    } catch (e) {
      percentage = 0.0;
    }
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
    }
  }

  String dailySteps() {
    return (int.parse(_steps) - previousSteps).toString();
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
          decoration: const BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 240, 255, 66),
              Color.fromARGB(255, 55, 146, 55)
            ],
          )),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset('Assets/logopng.png',
                        width: 130, height: 130, alignment: Alignment.topLeft),
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
                      progressColor: const Color.fromARGB(255, 124, 77, 255),
                    )
                  ]),
              const Divider(
                height: 100,
                thickness: 0,
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
                size: 100,
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
                        width: (MediaQuery.of(context).size.width /
                            4), // <-- Your width
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Text('Home'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 124, 77, 255),
                              textStyle: const TextStyle(
                                  fontSize: 12.0, fontWeight: FontWeight.bold)),
                        )),
                    SizedBox(
                        width: (MediaQuery.of(context).size.width /
                            4), // <-- Your width
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Text('Map'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 124, 77, 255),
                              textStyle: const TextStyle(
                                  fontSize: 12.0, fontWeight: FontWeight.bold)),
                        )),
                    SizedBox(
                        width: (MediaQuery.of(context).size.width /
                            4), // <-- Your width
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Text('Race'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 124, 77, 255),
                              textStyle: const TextStyle(
                                  fontSize: 12.0, fontWeight: FontWeight.bold)),
                        )),
                    SizedBox(
                        width: (MediaQuery.of(context).size.width /
                            4), // <-- Your width
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Text('Leaderboard'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 124, 77, 255),
                              textStyle: const TextStyle(
                                  fontSize: 12.0, fontWeight: FontWeight.bold)),
                        )),
                  ])
            ],
          ),
        ),
      ),
    );
  }
}
