import 'package:clicks/screen/homepage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UploadingDone extends StatelessWidget {
  final FirebaseApp app;
  const UploadingDone({Key? key, required this.app}) : super(key: key);

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
            alignment: Alignment.center,
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "asset/images/uploading_done.jpg",
                  width: MediaQuery.of(context).size.width * 0.8,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 30),
                Text('Video is Uploaded'),
                SizedBox(height: 30),
                ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(primary: Colors.black),
                    onPressed: () {
                      Get.offAll(Homepage(app: app));
                    },
                    icon: Icon(Icons.video_call_rounded),
                    label: Text("Go to Mainpage"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
