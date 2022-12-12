//Bu dosya sadece redirect içindir. Arayüzü yoktur.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../AuthPage.dart';
import '../steps.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key}); //5.54

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return StepsPage(); //giriş yapılıysa main page e at
          } else {
            return AuthPage(); //giriş yapılı değilse logine at
          }
        },
      ),
    );
  }
}
