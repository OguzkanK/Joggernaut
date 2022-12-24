// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:joggernaut/Widgets/IconWidget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:joggernaut/ZEYNEP/LoginPage.dart';
import 'package:joggernaut/ZEYNEP/goalView.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  late XFile? profilePic;

  static String imageURL =
      "https://www.pngitem.com/pimgs/m/575-5759580_anonymous-avatar-image-png-transparent-png.png";

  Widget buildProfilePic() => SimpleSettingsTile(
      title: 'Change Profile Picture',
      subtitle: '',
      leading: IconWidget(
          icon: Icons.person, color: Color.fromARGB(255, 148, 39, 99)),
      onTap: () async {
        final User user = auth.currentUser!;
        final uid = user.email!;
        profilePic = await ImagePicker().pickImage(source: ImageSource.gallery);
        File picFile = File(profilePic!.path);
        final ref = FirebaseStorage.instance.ref().child(uid);
        await ref.putFile(picFile);
        imageURL = await ref.getDownloadURL();
        setState(() {});
      });

  Widget goals() => SimpleSettingsTile(
      title: 'Personal Informations',
      subtitle: 'Set new goals, change weight',
      leading: IconWidget(icon: Icons.info, color: Colors.blue),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GoalView()),
        );
      });
  Widget buildLogout() => SimpleSettingsTile(
      title: 'Logout',
      subtitle: '',
      leading: IconWidget(icon: Icons.logout, color: Colors.blue),
      onTap: () {
        FirebaseAuth.instance.signOut();
        Navigator.popUntil(
            context, ModalRoute.withName(Navigator.defaultRouteName));
      });

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.all(24),
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                  imageURL,
                ),
                radius: 150,
              ),
              SettingsGroup(
                title: 'GENERAL',
                children: <Widget>[
                  buildProfilePic(),
                  buildLogout(),
                  goals(),
                ],
              ),
              const SizedBox(height: 320),
              Center(child: Text("version 1.0")),
            ],
          ),
        ),
      );
}
