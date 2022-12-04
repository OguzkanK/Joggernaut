import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'ZEYNEP/LoginPage.dart';
import 'ZEYNEP/RedirectPage.dart'; // Firebase import

Future main() async {
  WidgetsFlutterBinding.ensureInitialized(); //Firebase starting
  await Firebase.initializeApp(); //Firebase starting
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(),
    );
  }
}
