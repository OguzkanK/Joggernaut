// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GoalView extends StatefulWidget {
  const GoalView({super.key});

  @override
  State<GoalView> createState() => _GoalViewState();
}

class _GoalViewState extends State<GoalView> {
  // text conterollers

  final _stepGoalController = TextEditingController();
  final _kcalGoalController = TextEditingController();
  final _timeGoalController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _kmGoalController = TextEditingController();

  //memory management
  @override
  void dispose() {
    _stepGoalController.dispose();
    _kcalGoalController.dispose();
    _timeGoalController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _kmGoalController.dispose();
    super.dispose();
  }

  void saveToDB() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser!;
    final collectionReference = FirebaseFirestore.instance.collection('users');

    final query = collectionReference.where('email', isEqualTo: user.email);
    final querySnapshot = await query.get();

    if (querySnapshot.docs.isNotEmpty) {
      final documentSnapshot = querySnapshot.docs.first;
      await documentSnapshot.reference.set({
        'stepGoal': double.parse(_stepGoalController.text.trim()),
        'height': int.parse(_heightController.text.trim()),
        'weight': int.parse(_weightController.text.trim()),
        'kcalGoal': double.parse(_kcalGoalController.text.trim()),
        'timeGoal': double.parse(_timeGoalController.text.trim()),
        'kmGoal': double.parse(_kmGoalController.text.trim()),
      }, SetOptions(merge: true));
    }
  }

  // Future Commit() async {
  //   final FirebaseAuth auth = FirebaseAuth.instance;
  //   final User user = auth.currentUser!;
  //     //adding user details

  //     addUserDetails(

  //       double.parse(_stepGoalController.text.trim()),
  //       int.parse(_heightController.text.trim()),
  //       int.parse(_weightController.text.trim()),
  //       double.parse(_kcalGoalController.text.trim()),
  //       double.parse(_timeGoalController.text.trim()),
  //       double.parse(_kmGoalController.text.trim()),
  //     );

  // }

  // Future addUserDetails(

  //   double stepgoal,
  //   int height,
  //   int weight,
  //   double kcalgoal,
  //   double timegoal,
  //   double kmGoal,
  // ) async {
  //   await FirebaseFirestore.instance.collection('users').add({
  //     'stepGoal': stepgoal,
  //     'height': height,
  //     'weight': weight,
  //     'kcalGoal': kcalgoal,
  //     'timeGoal': timegoal,
  //     'kmGoal': kmGoal,
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
          backgroundColor: Color.fromARGB(255, 33, 71, 102),
          body: SafeArea(
              child: Center(
            child: SingleChildScrollView(
              //bu wrap yazı yazmak istedğimizde klavye çıakrken ekran bozulmasınd iye
              child: Column(children: [
                Text('Set Your Goals',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                SizedBox(height: 120),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(17)),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextField(
                        controller: _weightController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Weight',
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(17)),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextField(
                        controller: _heightController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Height',
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(17)),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextField(
                        controller: _stepGoalController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Daily Step Goal',
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(17)),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextField(
                        controller: _kcalGoalController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Daily Kcal Goal',
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(17)),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextField(
                        controller: _timeGoalController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Daily Time Goal',
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(17)),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextField(
                        controller: _kmGoalController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Daily Km Goal',
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 32),
                      child: GestureDetector(
                        onTap: saveToDB,
                        child: Container(
                          padding:
                              EdgeInsets.only(right: 10, top: 10, bottom: 10),
                          decoration: BoxDecoration(
                              color: Color.fromARGB(255, 15, 32, 46),
                              borderRadius: BorderRadius.circular(17)),
                          child: Center(
                              child: Row(
                            children: [
                              Text(
                                '     Commit  ',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                              Icon(Icons.directions_run, color: Colors.white),
                            ],
                          )),
                        ),
                      ),
                    ),
                  ],
                ),
              ]),
            ),
          ))),
    );
  }
}
