// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:joggernaut/Widgets/IconWidget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:joggernaut/ZEYNEP/LoginPage.dart';

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

  Widget buildLogout() => SimpleSettingsTile(
      title: 'Logout',
      subtitle: '',
      leading: IconWidget(icon: Icons.logout, color: Colors.blue),
      onTap: () {
        FirebaseAuth.instance.signOut();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => LoginPage(
                      showRegisterPage: () {},
                    )));
      });

  Widget buildDeleteAccount() => SimpleSettingsTile(
      title: 'Delete Account',
      subtitle: '',
      leading: IconWidget(icon: Icons.delete, color: Colors.red),
      onTap: () {
        final User user = auth.currentUser!;
        final uid = user.uid!;
        FirebaseFirestore.instance.collection('users').doc(uid).delete();
      });

  Widget buildReportBug(BuildContext context) => SimpleSettingsTile(
      title: 'Report A Bug',
      subtitle: '',
      leading: IconWidget(icon: Icons.bug_report, color: Colors.green),
      onTap: () {});
  Widget buildSendFeedback(BuildContext context) => SimpleSettingsTile(
      title: 'Send Feedback',
      subtitle: '',
      leading: IconWidget(icon: Icons.delete, color: Colors.blueGrey),
      onTap: () {});

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
                  buildDeleteAccount(),
                ],
              ),
              const SizedBox(height: 32),
              SettingsGroup(
                title: 'FEEDBACK',
                children: <Widget>[
                  buildReportBug(context),
                  buildSendFeedback(context),
                ],
              ),
            ],
          ),
        ),
      );
}
