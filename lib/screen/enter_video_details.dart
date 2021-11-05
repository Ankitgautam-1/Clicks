// ignore_for_file: no_logic_in_create_state

import 'dart:io';

import 'package:clicks/model/user_data.dart';
import 'package:clicks/model/videos.dart';
import 'package:clicks/provider/user_data_provider.dart';
import 'package:clicks/screen/uploading_done.dart';
import 'package:clicks/services/user_location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class VideoDetails extends StatefulWidget {
  final FirebaseApp app;
  final XFile video;
  const VideoDetails({Key? key, required this.video, required this.app})
      : super(key: key);

  @override
  _VideoDetailsState createState() =>
      _VideoDetailsState(video: video, app: app);
}

class _VideoDetailsState extends State<VideoDetails> {
  final FirebaseApp app;

  final XFile video;
  LocationData? locationData;
  Location location = Location();
  final TextEditingController _locationdata = TextEditingController(text: "");
  final TextEditingController _videotitle = TextEditingController();
  String _chosenCategory = "Education";
  final picker = ImagePicker();
  var _image;
  bool image = false;
  bool isloading = false;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  _VideoDetailsState({required this.video, required this.app});
  void deleteprofile() {
    setState(() {
      image = false;
      _image = Image.asset('asset/images/profile.jpg');
    });
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        File _im = File(pickedFile.path);
        _image = _im;
        image = true;
        print("image-->$_image");
      } else {
        print('No image selected.');
      }
    });
  }

  Future getCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(
      () {
        if (pickedFile != null) {
          File _im = File(pickedFile.path);
          _image = _im;
          image = true;
          print(" image ${_image.toString().trim()}");
        } else {
          print('No image selected.');
        }
      },
    );
  }

  Widget getPic() {
    return Container(
      color: Colors.white,
      height: 150,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Choos your profile picture",
            style: GoogleFonts.ubuntu(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: [
              GestureDetector(
                onTap: getCamera,
                child: Container(
                  width: 50,
                  height: 50,
                  child: Icon(Icons.camera, color: Colors.white),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              GestureDetector(
                onTap: getImage,
                child: Container(
                  width: 50,
                  height: 50,
                  child: Icon(Icons.image, color: Colors.white),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              GestureDetector(
                onTap: deleteprofile,
                child: Container(
                  width: 50,
                  height: 50,
                  child: Icon(Icons.delete, color: Colors.white),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 280,
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Form(
                    key: _formkey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Stack(
                            children: [
                              !image
                                  ? Container(
                                      child: Image.asset(
                                        'asset/images/image_upload.jpg',
                                        width: 180,
                                        height: 180,
                                      ),
                                    )
                                  : SizedBox(
                                      width: 180,
                                      height: 180,
                                      child: Image.file(
                                        _image,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black,
                                  ),
                                  width: 35,
                                  height: 35,
                                  child: GestureDetector(
                                    onTap: () {
                                      Get.bottomSheet(getPic());
                                    },
                                    child: const Icon(
                                      Icons.upload,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        TextFormField(
                          validator: (value) {
                            if (value!.isEmpty || value.length < 4) {
                              return "Title shoud be at least 4 letters";
                            }
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                                borderSide: (BorderSide(
                                    color: Colors.black, width: 1))),
                            focusedBorder: OutlineInputBorder(
                                borderSide: (BorderSide(
                                    color: Colors.black, width: 1))),
                            icon: Icon(
                              Icons.video_call_rounded,
                              color: Colors.grey,
                            ),
                            hintText: "Video Title",
                          ),
                          controller: _videotitle,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.video_collection,
                              color: Colors.grey,
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            DropdownButton<String>(
                              dropdownColor: Colors.grey[100],
                              focusColor: Colors.grey,
                              value: _chosenCategory,
                              iconEnabledColor: Colors.black,
                              items: <String>[
                                'Education',
                                'Fun',
                                'Vlog',
                                'Gameming',
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style:
                                        GoogleFonts.ubuntu(color: Colors.black),
                                  ),
                                );
                              }).toList(),
                              hint: Text('select a category'),
                              onChanged: (data) {
                                setState(() {
                                  _chosenCategory = data!;
                                });
                              },
                            ),
                          ],
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              icon: Icon(Icons.location_on_rounded)),
                          controller: _locationdata,
                          readOnly: true,
                          enabled: false,
                        ),
                        Center(
                          child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.black,
                              ),
                              onPressed: () async {
                                UserData _userdata =
                                    Provider.of<UserDataProvider>(context,
                                            listen: false)
                                        .userData;
                                await uploading(_userdata);
                              },
                              icon: Icon(Icons.video_call_rounded),
                              label: Text("Upload the Video")),
                        )
                      ],
                    ),
                  ),
                ),
                isloading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : Container()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> uploading(UserData userdata) async {
    if (video != null) {
      if (_image != null) {
        if (_formkey.currentState!.validate()) {
          try {
            setState(() {
              isloading = true;
            });
            String uploadTime = DateTime.now().toString();
            String videoUid = userdata.uid.trim() + "_" + uploadTime.trim();
            print("VideoUId$videoUid");
            String imagename = videoUid + "_tumbnail";
            String videoname = videoUid + "_video";
            String imageUrl = "";
            String videoUrl = "";
            firebase_storage.Reference ref = firebase_storage
                .FirebaseStorage.instance
                .ref()
                .child("Videos")
                .child("/$videoUid/$imagename");
            ref.putFile(_image).whenComplete(() async {
              imageUrl = await ref.getDownloadURL();
              print("imageUrl:$imageUrl");
              File videoasfile = File(video.path);
              ref = firebase_storage.FirebaseStorage.instance
                  .ref()
                  .child("Videos")
                  .child("/$videoUid/$videoname");

              ref.putFile(videoasfile).whenComplete(() async {
                videoUrl = await ref.getDownloadURL();
                print("VideoUrl:$videoUrl");

                final _firestore = FirebaseFirestore.instance;
                CollectionReference<Map<String, dynamic>> collection_ref =
                    _firestore.collection("videos");
                setState(() {
                  isloading = false;
                });
                collection_ref.doc(videoUid).set({
                  "likes": [],
                  "dislikes": [],
                  "views": [],
                  "category": _chosenCategory,
                  "location": _locationdata.text,
                  "thumbnail": imageUrl,
                  "title": _videotitle.text.trim().capitalize,
                  "uploadTime": uploadTime,
                  "author": {
                    "authorProfile": userdata.imageurl,
                    "authorUsername": userdata.username,
                    "authorUid": userdata.uid,
                  },
                  "videoLink": videoUrl,
                  "videoUid": videoUid,
                }).whenComplete(() {
                  Get.offAll(UploadingDone(app: app));
                });
              });
            });
          } catch (e) {
            print("Got error $e");
          }
        } else {
          print("in else");
        }
      } else {
        Get.snackbar("Video uploading", "Image not found",
            snackPosition: SnackPosition.BOTTOM);
      }
    } else {
      Get.snackbar("Video uploading", "Files not found",
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  void initState() {
    super.initState();
    getLocationData();
  }

  void getLocationData() async {
    Location location = Location();
    await location.getLocation().then((value) {
      locationData = value;
    });
    _locationdata.text = await Geocoding().getAddress(locationData!, context);
    setState(() {});
  }
}
