// ignore_for_file: no_logic_in_create_state

import 'package:cached_network_image/cached_network_image.dart';
import 'package:clicks/model/user_data.dart';
import 'package:clicks/provider/user_data_provider.dart';
import 'package:clicks/screen/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Homepage extends StatefulWidget {
  final FirebaseApp app;
  const Homepage({Key? key, required this.app}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState(app: app);
}

class _HomepageState extends State<Homepage> {
  final FirebaseApp app;

  _HomepageState({required this.app});
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          actions: [
            Consumer<UserDataProvider>(builder: (context, data, _) {
              return GestureDetector(
                onTap: () {
                  _scaffoldKey.currentState!.openDrawer();
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 11),
                  child: Container(
                    child: CircleAvatar(
                      radius: 28,
                      child: ClipOval(
                        child: SizedBox(
                          child: CachedNetworkImage(
                            width: 35,
                            height: 35,
                            placeholderFadeInDuration: Duration(seconds: 2),
                            fit: BoxFit.cover,
                            imageUrl: data.userData.imageurl,
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) =>
                                    CircularProgressIndicator(
                                        value: downloadProgress.progress),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
          backgroundColor: Colors.grey[900],
          leading: Center(
            child: Text(
              'Flyin',
              style: GoogleFonts.ubuntu(),
            ),
          ),
        ),
        body: const SingleChildScrollView(
          child: Center(
            child: Text('Homepage'),
          ),
        ),
        drawer: Drawer(
          child: Container(
            alignment: Alignment.centerLeft,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: Colors.grey[900],
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Consumer<UserDataProvider>(builder: (context, data, _) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ClipOval(
                              child: SizedBox(
                                width: 80,
                                height: 80,
                                child: CachedNetworkImage(
                                  placeholderFadeInDuration:
                                      Duration(seconds: 2),
                                  fit: BoxFit.cover,
                                  imageUrl: data.userData.imageurl,
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          CircularProgressIndicator(
                                              value: downloadProgress.progress),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.only(left: 12.0),
                                margin: EdgeInsets.only(top: 25.0),
                                width: 150,
                                child: Text(
                                  data.userData.username,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.left,
                                  style: GoogleFonts.ubuntu(
                                      color: Colors.white, fontSize: 17),
                                ),
                              ),
                            )
                          ],
                        );
                      }),
                    ],
                  ),
                ),
                ListTile(
                  onTap: () {
                    print("Go to profile");
                  },
                  leading: Icon(
                    Icons.person_rounded,
                    color: Colors.black,
                  ),
                  title: Text('Profile'),
                ),
                const Spacer(),
                TextButton.icon(
                  style: TextButton.styleFrom(
                      primary: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0)),
                  label: Text(
                    "Logout",
                    style: GoogleFonts.ubuntu(),
                  ),
                  onPressed: logout,
                  icon: const Icon(Icons.exit_to_app),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    print(
        "data here :${Provider.of<UserDataProvider>(context, listen: false).userData.imageurl}");
    super.initState();
  }

  void logout() async {
    FirebaseAuth _auth = FirebaseAuth.instanceFor(app: app);
    _auth.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("uid");

    prefs.remove('username');
    prefs.remove('imageurl');
    prefs.remove('phonenumber');
    UserData userData =
        UserData(imageurl: "", phonenumber: "", uid: "", username: "");
    Provider.of<UserDataProvider>(context, listen: false)
        .updateuserdata(userData);
    Get.offAll(SignIn(app: app));
  }
}
