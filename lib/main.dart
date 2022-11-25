// ignore_for_file: no_logic_in_create_state

import 'package:clicks/model/user_data.dart';
import 'package:clicks/provider/camera_description.dart';
import 'package:clicks/provider/user_data_provider.dart';
import 'package:clicks/provider/video_provider.dart';
import 'package:clicks/screen/homepage.dart';
import 'package:clicks/screen/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'provider/connectivity_provider.dart';

var uid, profileurl, username, phonenumber, email;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  List<dynamic>? data;
  FirebaseApp app = await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
    ],
  );
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
      ChangeNotifierProvider<DataConnection>(
        create: (context) => DataConnection(),
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
      UserData userData = UserData(
          imageurl:
              "https://i.picsum.photos/id/668/200/200.jpg?hmac=mVqr1fc4nHFre2QMZp5cuqUKLIRSafUtWt2vwlA9jG0",
          phonenumber: "8850945124",
          uid: "SLQBMnVLHzOh8dT1WFQLhcKq0th1",
          username: "Test User");
      print("Userdata class:$userData");
      Provider.of<UserDataProvider>(context, listen: false)
          .updateuserdata(userData);
      Get.offAll(() => Homepage(app: app));
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
