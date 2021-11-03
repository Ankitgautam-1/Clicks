import 'package:flutter/cupertino.dart';
import 'package:camera/camera.dart';

class CameraDescriptionProvider extends ChangeNotifier {
  List<CameraDescription>? cameras;
  CameraDescriptionProvider({this.cameras});
  void updatecamera(List<CameraDescription> cameras) {
    this.cameras = cameras;
  }
}
