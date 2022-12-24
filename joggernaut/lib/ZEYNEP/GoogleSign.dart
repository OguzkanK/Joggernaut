import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:joggernaut/ZEYNEP/goalView.dart';

class GoogleSignInProvider extends ChangeNotifier {
  final googleSignIn = GoogleSignIn();

  GoogleSignInAccount? _user;
  GoogleSignInAccount get user => _user!;

  Future googleLogin() async {
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return;
    _user = googleUser;
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);
    notifyListeners();

    //burdan aşağısında google login ile ilk defa giriş yapılıyorsa users collectionuna kaydetmek için olan kodlar var.
    var result = await FirebaseAuth.instance.signInWithCredential(credential);
    if (result.user!.metadata.creationTime !=
        result.user!.metadata.lastSignInTime) {
      await FirebaseFirestore.instance.collection('users').add({
        'Full Name': result.user?.displayName,
        'Email': result.user?.email!.toLowerCase(),
        'height': 0,
        'weight': 0,
        'kcalGoal': 0,
        'timeGoal': 0,
        'kmGoal': 0,
        'flag': 0
      });
      MaterialPageRoute(builder: (context) => const GoalView());
    } else {
      print(result.additionalUserInfo!.isNewUser);
    }
  }
}
