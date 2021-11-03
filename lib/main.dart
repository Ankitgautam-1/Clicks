// ignore_for_file: no_logic_in_create_state

import 'dart:convert';

import 'package:clicks/model/user_data.dart';
import 'package:clicks/model/videos.dart';
import 'package:clicks/provider/camera_description.dart';
import 'package:clicks/provider/user_data_provider.dart';
import 'package:clicks/provider/video_provider.dart';
import 'package:clicks/screen/homepage.dart';
import 'package:clicks/screen/login.dart';
import 'package:clicks/services/get_video.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

var uid, profileurl, username, phonenumber, email;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  List<dynamic>? data;
  FirebaseApp app = await Firebase.initializeApp();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<UserDataProvider>(
        create: (context) => UserDataProvider(),
      ),
      ChangeNotifierProvider<CameraDescriptionProvider>(
        create: (context) => CameraDescriptionProvider(),
      ),
      ChangeNotifierProvider<VideoProvider>(
        create: (context) => VideoProvider(),
      ),
    ],
    child: GetMaterialApp(
      theme: ThemeData(textTheme: GoogleFonts.ubuntuTextTheme()),
      debugShowCheckedModeBanner: false,
      home: MyApp(app: app),
    ),
  ));
}

class MyApp extends StatefulWidget {
  final FirebaseApp app;
  const MyApp({Key? key, required this.app}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState(app: app);
}

class _MyAppState extends State<MyApp> {
  final FirebaseApp app;
  _MyAppState({required this.app});
  @override
  void initState() {
    checkuid().whenComplete(() async {
      uid == null
          ? Get.offAll(SignIn(app: app))
          : Get.offAll(Homepage(app: app));
    });
    super.initState();
  }

  Future<void> checkuid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getString('uid') != null) {
      uid = prefs.getString('uid');

      username = prefs.getString('username');
      profileurl = prefs.getString('imageurl');
      print('imageurl:$profileurl');
      phonenumber = prefs.getString('phonenumber');
      UserData userData = UserData(
          imageurl: profileurl,
          phonenumber: phonenumber,
          uid: uid,
          username: username);
      print("Userdata class:${userData.imageurl}");
      Provider.of<UserDataProvider>(context, listen: false)
          .updateuserdata(userData);
      print(
          "Provider class:${Provider.of<UserDataProvider>(context, listen: false).userData.uid}");
    } else {
      print("getting null $uid");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.95,
        color: Colors.white);
  }
}
