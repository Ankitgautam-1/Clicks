import 'package:clicks/model/videos.dart';
import 'package:flutter/cupertino.dart';

class VideoProvider extends ChangeNotifier {
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

  get videotitle => video.title;
}
