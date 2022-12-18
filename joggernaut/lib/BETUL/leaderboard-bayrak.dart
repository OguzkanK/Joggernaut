// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, sort_child_properties_last, library_private_types_in_public_api, file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'leaderboard-adim.dart';
import 'package:joggernaut/steps.dart';

class LeaderboardFlag extends StatefulWidget {
  const LeaderboardFlag({Key? key}) : super(key: key);

  @override
  _LeaderboardFlagState createState() => _LeaderboardFlagState();
}

class _LeaderboardFlagState extends State<LeaderboardFlag> {
  List itemsList = [];
  //ilk 3'ün profil fotoğrafı yoksa foto atama (listviewer olmadığı için fotolar tek tek alınıyor)
  String url1 =
      "https://www.pngitem.com/pimgs/m/575-5759580_anonymous-avatar-image-png-transparent-png.png";
  String url2 =
      "https://www.pngitem.com/pimgs/m/575-5759580_anonymous-avatar-image-png-transparent-png.png";
  String url3 =
      "https://www.pngitem.com/pimgs/m/575-5759580_anonymous-avatar-image-png-transparent-png.png";

  @override
  void initState() {
    getUsersList();
  }

  Future getUsersList() async {
    print('en azından girdi be abi');

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .orderBy('flag', descending: true)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((element) {
          setState(() {
            itemsList.add(element.data());
          });
        });
      });
      //ilk 3'ün profil fotoğrafı varsa kendi fotolarını atama
      if (itemsList[0]["imageUrl"] != null) {
        url1 = itemsList[0]["imageUrl"];
      }
      if (itemsList[1]["imageUrl"] != null) {
        url2 = itemsList[1]["imageUrl"];
      }
      if (itemsList[2]["imageUrl"] != null) {
        url3 = itemsList[2]["imageUrl"];
      }
      //listview içinde fotoğrafı olmayanlara fotoğraf atama (daha sonra database'de düzeltilecek!!)
      for (int i = 0; i < itemsList.length; i++) {
        if (itemsList[i]['imageUrl'] == null) {
          itemsList[i]['imageUrl'] =
              "https://www.pngitem.com/pimgs/m/575-5759580_anonymous-avatar-image-png-transparent-png.png";
        }
      }
      //print(itemsList);
      return itemsList;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(23, 23, 23, 1),
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => StepsPage()));
                });
          },
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LeaderboardStep()));
              },
              tooltip: 'Sort by count of steps',
              icon: const Icon(Icons.directions_walk)),
          IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LeaderboardFlag()));
              },
              tooltip: 'Sort by count of flags',
              icon: const Icon(Icons.emoji_flags)),
        ],
        backgroundColor: Color.fromRGBO(15, 32, 39, 1),
        title: Text(
          "Leaderboard",
          style: TextStyle(fontSize: 29),
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 20),
              height: 225,
              decoration: BoxDecoration(
                  color: Color.fromARGB(255, 140, 200, 228),
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20))),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 25.0),
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(url1),
                          radius: 40,
                        ),
                      ),
                      Positioned(
                          left: 0,
                          right: 0,
                          top: 0,
                          child: Image(image: AssetImage('Assets/111.png'))),
                    ],
                  ),
                  // SizedBox(
                  //   height: 10,
                  // ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 30.0),
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(url2),
                              radius: 35,
                            ),
                          ),
                          Positioned(
                              left: 0,
                              right: 0,
                              top: 0,
                              child:
                                  Image(image: AssetImage('Assets/222.png'))),
                        ],
                      ),
                      Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 30.0),
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(url3),
                              radius: 35,
                            ),
                          ),
                          Positioned(
                              left: 0,
                              right: 0,
                              top: 0,
                              child:
                                  Image(image: AssetImage('Assets/333.png'))),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              height: 50.0,
              width: 1080.0,
              //color: Color.fromRGBO(55, 146, 55, 1),
              child: Center(
                child: Text('By Flags',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 25, color: Colors.white)),
              ),
              decoration: BoxDecoration(
                color: Color.fromRGBO(31, 70, 101, 1),
                //borderRadius: BorderRadius.only(
                //bottomRight: Radius.circular(20),
                //bottomLeft: Radius.circular(20))
              ),
            ),
            Container(
              margin: EdgeInsets.all(10),
              child: SizedBox(
                height: MediaQuery.of(context).size.height -
                    (305 + kToolbarHeight + MediaQuery.of(context).padding.top),
                child: ListView.separated(
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage:
                                  NetworkImage(itemsList[index]["imageUrl"]),
                            ),
                            SizedBox(
                              width: 3,
                            ),
                            Text(
                                '    ${itemsList[index]["First Name"]}\n    ${itemsList[index]["Last Name"]}',
                                style: TextStyle(color: Colors.white))
                          ],
                        ),
                        leading: Text("#${index + 1}",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        trailing: Text('${itemsList[index]['flag']}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      );
                    },
                    separatorBuilder: (context, index) => Divider(
                          thickness: 1,
                          color: Colors.blueGrey,
                          indent: 10,
                          endIndent: 10,
                        ),
                    itemCount: itemsList.length),
              ),
            )
          ],
        ),
      ),
    );
  }
}
