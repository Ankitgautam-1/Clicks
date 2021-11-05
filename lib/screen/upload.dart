// ignore_for_file: no_logic_in_create_state

import 'dart:io';

import 'package:clicks/provider/camera_description.dart';
import 'package:clicks/screen/enter_video_details.dart';
import 'package:clicks/screen/homepage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class UploadVideo extends StatefulWidget {
  final FirebaseApp app;
  const UploadVideo({Key? key, required this.app}) : super(key: key);

  @override
  _UploadVideoState createState() => _UploadVideoState(app: app);
}

class _UploadVideoState extends State<UploadVideo> {
  bool backCamera = true;
  final FirebaseApp app;
  _UploadVideoState({required this.app});
  CameraController? controller;
  bool _isrecording = false;
  bool ispause = false;
  XFile? video;
  bool isflash = false;
  bool mediauplaod = true;
  bool backcam = true;
  final picker = ImagePicker();
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() {
    controller = CameraController(
        backcam
            ? Provider.of<CameraDescriptionProvider>(context, listen: false)
                .cameras![0]
            : Provider.of<CameraDescriptionProvider>(context, listen: false)
                .cameras![1],
        ResolutionPreset.max,
        enableAudio: true);
    controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.offAll(Homepage(app: app));
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          body: Container(
            width: double.infinity,
            child: Column(
              children: [
                !controller!.value.isInitialized
                    ? Container(
                        height: 624,
                        color: Colors.grey.shade900,
                        alignment: Alignment.center,
                        child: Expanded(child: CircularProgressIndicator()),
                      )
                    : SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.80,
                        child: CameraPreview(
                          controller!,
                        ),
                      ),
                Expanded(
                  child: Container(
                    color: Colors.grey[900],
                    height: MediaQuery.of(context).size.height * 0.15,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  backcam = !backcam;
                                  init();
                                });
                              },
                              child: Icon(
                                Icons.cameraswitch_rounded,
                                color: Colors.white,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (isflash) {
                                  controller!.setFlashMode(FlashMode.off);
                                } else {
                                  controller!.setFlashMode(FlashMode.torch);
                                }
                                setState(() {
                                  isflash = !isflash;
                                });
                              },
                              child: isflash
                                  ? Icon(
                                      Icons.flash_on_rounded,
                                      color: Colors.yellow,
                                    )
                                  : Icon(
                                      Icons.flash_on_rounded,
                                      color: Colors.white,
                                    ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                if (_isrecording) {
                                  controller!
                                      .stopVideoRecording()
                                      .then((value) {
                                    this.video = value;
                                    setState(() {
                                      mediauplaod = false;
                                    });
                                  });
                                } else {
                                  controller!.startVideoRecording();
                                }
                                setState(() {
                                  _isrecording = !_isrecording;
                                });
                              },
                              child: !_isrecording
                                  ? Icon(
                                      Icons.camera,
                                      color: Colors.white,
                                    )
                                  : Icon(
                                      Icons.stop_rounded,
                                      color: Colors.red,
                                    ),
                            ),
                            GestureDetector(
                              onTap: !_isrecording
                                  ? () {}
                                  : () {
                                      if (ispause) {
                                        controller!.pauseVideoRecording();
                                      } else {
                                        controller!.resumeVideoRecording();
                                      }
                                      setState(() {
                                        ispause = !ispause;
                                      });
                                    },
                              child: _isrecording
                                  ? ispause
                                      ? Icon(
                                          Icons.play_arrow,
                                          color: Colors.white,
                                        )
                                      : Icon(
                                          Icons.pause,
                                          color: Colors.white,
                                        )
                                  : Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                    ),
                            )
                          ],
                        ),
                        mediauplaod
                            ? ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.blue,
                                ),
                                label: Text(
                                  "Get From Gallery",
                                  style:
                                      GoogleFonts.ubuntu(color: Colors.white),
                                ),
                                onPressed: getVideoFromPhone,
                                icon: Icon(
                                  Icons.video_call,
                                  color: Colors.white,
                                ),
                              )
                            : const SizedBox.shrink(),
                        video != null
                            ? Center(
                                child: TextButton.icon(
                                  onPressed: () {
                                    Get.off(
                                        VideoDetails(video: video!, app: app));
                                    controller!.dispose();
                                  },
                                  icon: Icon(Icons.video_call_rounded),
                                  label: Text("Upload"),
                                ),
                              )
                            : Container()
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future getVideoFromPhone() async {
    final pickedFile = await picker
        .pickVideo(source: ImageSource.gallery)
        .then((videoforphone) {
      if (videoforphone != null) {
        setState(() {
          video = videoforphone;
          mediauplaod = false;
        });
      }
    });
  }
}
