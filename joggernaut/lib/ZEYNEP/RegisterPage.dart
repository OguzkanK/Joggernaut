// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  const RegisterPage({super.key, required this.showLoginPage});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text conterollers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _stepGoalController = TextEditingController();
  final _kcalGoalController = TextEditingController();
  final _timeGoalController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _kmGoalController = TextEditingController();

  //memory management
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstnameController.dispose();
    _lastnameController.dispose();
    _stepGoalController.dispose();
    _kcalGoalController.dispose();
    _timeGoalController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _kmGoalController.dispose();
    super.dispose();
  }

  Future signUp() async {
    // aauthenticaten user
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      //adding user details

      addUserDetails(
        _firstnameController.text.trim(),
        _lastnameController.text.trim(),
        _emailController.text.trim(),
        double.parse(_stepGoalController.text.trim()),
        int.parse(_heightController.text.trim()),
        int.parse(_weightController.text.trim()),
        double.parse(_kcalGoalController.text.trim()),
        double.parse(_timeGoalController.text.trim()),
        double.parse(_kmGoalController.text.trim()),
      );
    } on FirebaseAuthException catch (e) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.message.toString()),
            );
          });
    }
  }

  Future addUserDetails(
    String firstname,
    String lastname,
    String email,
    double stepgoal,
    int height,
    int weight,
    double kcalgoal,
    double timegoal,
    double kmGoal,
  ) async {
    await FirebaseFirestore.instance.collection('users').add({
      'First Name': firstname,
      'Last Name': lastname,
      'email': email.toLowerCase(),
      'stepGoal': stepgoal,
      'height': height,
      'weight': weight,
      'kcalGoal': kcalgoal,
      'timeGoal': timegoal,
      'kmGoal': kmGoal,
      'flag': 0
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("Assets/signup.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
              child: Center(
            child: SingleChildScrollView(
              //bu wrap yazı yazmak istedğimizde klavye çıakrken ekran bozulmasınd iye
              child: Column(children: [
                SizedBox(height: 350),
                //FORM - name

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
                        controller: _firstnameController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'First Name',
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),

                //FORM - soyad

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
                        controller: _lastnameController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Last Name',
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

                // LOGIN - email
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
                        controller: _emailController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Email',
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // LOGIN - Password

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
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Password',
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // register - signup

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 32),
                      child: GestureDetector(
                        onTap: signUp,
                        child: Container(
                          padding:
                              EdgeInsets.only(right: 10, top: 10, bottom: 10),
                          decoration: BoxDecoration(
                              color: Color.fromARGB(255, 33, 71, 102),
                              borderRadius: BorderRadius.circular(17)),
                          child: Center(
                              child: Row(
                            children: [
                              Text(
                                '     Sign Up  ',
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

                SizedBox(height: 50),

                //FOOT

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: widget.showLoginPage,
                      child: Text('Have an account? Sign In.',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                    ),
                  ],
                ),
              ]),
            ),
          ))),
    );
  }
}
