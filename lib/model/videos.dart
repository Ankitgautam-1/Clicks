import 'dart:convert';

class Video {
  Video({
    required this.category,
    required this.location,
    required this.thumbnail,
    required this.title,
    required this.uploadTime,
    required this.author,
    required this.videoLink,
    required this.videoUid,
    this.views,
    this.likes,
    this.dislikes,
  });
  get getthumbnail => thumbnail;

  get gettittle => title;
  get getauthor => author;
  get getvideoLink => videoLink;
  get getvideoUid => videoUid;
  get getlocation => location;
  get getcategory => category;

  String category;
  String location;
  String thumbnail;
  String title;
  String uploadTime;
  Author author;
  String videoLink;
  String videoUid;
  dynamic views;
  dynamic likes;
  dynamic dislikes;
}

class Author {
  Author({
    required this.authorProfile,
    required this.authorUid,
    required this.authorUserName,
  });
  get authorUsername => authorUserName;
  get authorUID => authorUid;
  get authorImage => authorProfile;
  String authorProfile;
  String authorUid;
  String authorUserName;
}
