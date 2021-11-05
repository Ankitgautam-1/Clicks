// ignore_for_file: no_logic_in_create_state

import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:clicks/model/user_data.dart';
import 'package:clicks/model/videos.dart';
import 'package:clicks/provider/camera_description.dart';
import 'package:clicks/provider/connectivity_provider.dart';
import 'package:clicks/provider/user_data_provider.dart';
import 'package:clicks/screen/location_permission.dart';
import 'package:clicks/screen/login.dart';
import 'package:clicks/screen/no_internet.dart';
import 'package:clicks/screen/searchbox.dart';
import 'package:clicks/screen/upload.dart';
import 'package:clicks/screen/videos.dart';
import 'package:clicks/services/get_video.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart' as loc;

class Homepage extends StatefulWidget {
  final FirebaseApp app;
  const Homepage({Key? key, required this.app}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState(app: app);
}

class _HomepageState extends State<Homepage>
    with AutomaticKeepAliveClientMixin {
  final FirebaseApp app;

  @override
  bool get wantKeepAlive => true;
  loc.Location location = loc.Location();
  _HomepageState({required this.app});
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  Future<void> getPrmission() async {
    if (!(await Permission.camera.isGranted)) {
      Permission permission = Permission.camera;
      var statusCamera = await permission.request();
      if (statusCamera == PermissionStatus.granted ||
          statusCamera == PermissionStatus.limited) {
        List<CameraDescription> cameras;
        cameras = await availableCameras();
        Provider.of<CameraDescriptionProvider>(context, listen: false)
            .updatecamera(cameras);
        print("cameras$cameras");
        if (await Permission.locationAlways.isGranted) {
          cameras = await availableCameras();
          Provider.of<CameraDescriptionProvider>(context, listen: false)
              .updatecamera(cameras);
          Get.to(LocationPermissoin(app: app));
        } else {
          cameras = await availableCameras();
          Provider.of<CameraDescriptionProvider>(context, listen: false)
              .updatecamera(cameras);
          Get.to(LocationPermissoin(app: app));
          print('Location is not granted');
        }
      } else {}
    } else {
      List<CameraDescription> cameras;
      cameras = await availableCameras();
      Provider.of<CameraDescriptionProvider>(context, listen: false)
          .updatecamera(cameras);
      print("cameras$cameras");
      print("camera is graneted");

      if (await location.serviceEnabled()) {
        if (await Permission.locationWhenInUse.isGranted) {
          cameras = await availableCameras();
          Provider.of<CameraDescriptionProvider>(context, listen: false)
              .updatecamera(cameras);
          Get.to(UploadVideo(app: app));
        } else {
          Get.to(LocationPermissoin(app: app));
        }
      } else {
        Get.to(LocationPermissoin(app: app));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: Consumer<DataConnection>(builder: (context, data, _) {
        if (data.isOnline != null) {
          return data.isOnline
              ? Scaffold(
                  backgroundColor: Colors.grey[900],
                  key: _scaffoldKey,
                  appBar: AppBar(
                    actions: [
                      Container(
                        height: 10,
                        child: OpenContainer(
                          closedColor: Colors.grey.shade900,
                          transitionType: ContainerTransitionType.fadeThrough,
                          transitionDuration: Duration(milliseconds: 600),
                          openBuilder: (context, _) {
                            return SerachBox(app: app);
                          },
                          closedBuilder: (context, openserachbox) {
                            return GestureDetector(
                              onTap: openserachbox,
                              child: SizedBox(
                                height: 20,
                                width: 30,
                                child: Icon(
                                  Icons.search_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Consumer<UserDataProvider>(builder: (context, data, _) {
                        return GestureDetector(
                          onTap: () {
                            _scaffoldKey.currentState!.openDrawer();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 0, vertical: 11),
                            child: CircleAvatar(
                              radius: 28,
                              child: ClipOval(
                                child: SizedBox(
                                  child: CachedNetworkImage(
                                    width: 35,
                                    height: 35,
                                    fit: BoxFit.cover,
                                    imageUrl: data.userData.imageurl,
                                    progressIndicatorBuilder: (context, url,
                                            downloadProgress) =>
                                        CircularProgressIndicator(
                                            value: downloadProgress.progress),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
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
                  body: const VideosScreen(),
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.centerFloat,
                  floatingActionButton: FloatingActionButton.small(
                      onPressed: () {
                        getPrmission();
                      },
                      child: Icon(Icons.add)),
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
                                Consumer<UserDataProvider>(
                                    builder: (context, data, _) {
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
                                            progressIndicatorBuilder: (context,
                                                    url, downloadProgress) =>
                                                CircularProgressIndicator(
                                                    value: downloadProgress
                                                        .progress),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.error),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          padding:
                                              const EdgeInsets.only(left: 12.0),
                                          margin: EdgeInsets.only(top: 25.0),
                                          width: 150,
                                          child: Text(
                                            data.userData.username,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.left,
                                            style: GoogleFonts.ubuntu(
                                                color: Colors.white,
                                                fontSize: 17),
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0)),
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
                )
              : NoInternet();
        } else {
          return NoInternet();
        }
      }),
    );
  }

  @override
  void initState() {
    super.initState();
    Provider.of<DataConnection>(context, listen: false).getDataConnection();
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
