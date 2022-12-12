// import 'package:flutter/material.dart';
// import 'steps.dart';

// // Firebase import
// void main() {
//   runApp(
//       const MaterialApp(home: StepsPage(), debugShowCheckedModeBanner: false));
//   startForegroundService();
// }

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'ZEYNEP/GoogleSign.dart';
import 'steps.dart';

import 'ZEYNEP/RedirectPage.dart'; // Firebase import

// Firebase import

Future main() async {
  WidgetsFlutterBinding.ensureInitialized(); //Firebase starting
  await Firebase.initializeApp(); //Firebase starting
  runApp(const MyApp());
  startForegroundService();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (context) => GoogleSignInProvider(),
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: MainPage(),
        ),
      );
}
