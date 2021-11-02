import 'package:clicks/model/videos.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';

Future<List> getVideos() async {
  List videos = [];
  final _firestore = FirebaseFirestore.instance;
  var collectionReference = _firestore.collection('videos');
  collectionReference
      .get()
      .then((QuerySnapshot<Map<String, dynamic>> documents) {
    for (var element in documents.docs) {
      Author author = Author(
          authorProfile: element.data()['author']['authorProfile'],
          authorUid: element.data()['author']['authorUid'],
          authorUserName: element.data()['author']['authorUsername']);
      // Videos video = Videos(
      //     videoUid: element.data()['videoUid'],
      //     category: element.data()['category'],
      //     location: element.data()['location'],
      //     thumbnail: element.data()['thumbnail'],
      //     title: element.data()['title'],
      //     uploadTime: element.data()['uploadTime'],
      //     author: author,
      //     videoLink: element.data()['videoLink']);
      videos.add(Video(
          videoUid: element.data()['videoUid'],
          category: element.data()['category'],
          location: element.data()['location'],
          thumbnail: element.data()['thumbnail'],
          title: element.data()['title'],
          uploadTime: element.data()['uploadTime'],
          author: author,
          videoLink: element.data()['videoLink']));
      return videos;
    }
  });
  return [];
}
