import 'package:clicks/model/videos.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class VideoProvider extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;

  Video video = Video(
      category: "category",
      location: "location",
      thumbnail: "thumbnail",
      title: "title",
      uploadTime: "uploadTime",
      author: Author(
          authorProfile: "authorProfile",
          authorUid: "authorUid",
          authorUserName: "authorUserName"),
      videoLink: "videoLink",
      videoUid: "videoUid");

  void updateplayingvideo(Video video) {
    this.video = video;
    notifyListeners();
  }

  void updatelike(dynamic data) {
    print('data$data');
    this.video.likes = data;
    notifyListeners();
  }

  get videotitle => video.title;
  get videothimbnail => video.thumbnail;
  get videoauthor => video.author;
  get videocategory => video.category;
  get videolocation => video.location;
  get videolink => video.videoLink;
}
