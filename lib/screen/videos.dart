import 'package:cached_network_image/cached_network_image.dart';
import 'package:clicks/model/videos.dart';
import 'package:clicks/provider/video_provider.dart';
import 'package:clicks/screen/playing_video.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class VideosScreen extends StatefulWidget {
  const VideosScreen({Key? key}) : super(key: key);

  @override
  _VideosScreenState createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  List videos = [];
  Future<List> getVideos() async {
    videos.clear();
    final _firestore = FirebaseFirestore.instance;
    var collectionReference = _firestore.collection('videos');
    collectionReference
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> documents) {
      documents.docs.forEach((element) {
        Author author = Author(
            authorProfile: element.data()['author']['authorProfile'],
            authorUid: element.data()['author']['authorUid'],
            authorUserName: element.data()['author']['authorUsername']);
        Video video = Video(
            videoUid: element.data()['videoUid'],
            category: element.data()['category'],
            location: element.data()['location'],
            thumbnail: element.data()['thumbnail'],
            title: element.data()['title'],
            uploadTime: element.data()['uploadTime'],
            author: author,
            videoLink: element.data()['videoLink']);
        videos.add(video);
      });
    });
    return videos;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getVideos(),
      builder: (
        context,
        snapshot,
      ) {
        if (snapshot.hasError) {
          return Container(
            color: Colors.white,
            child: const Center(
              child: Text('Got Error while loading Data'),
            ),
          );
        } else if (snapshot.data == []) {
          return Container(
            color: Colors.white,
            child: const Center(
              child: Text('No Vides to found Check again'),
            ),
          );
        } else if (snapshot.data != []) {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: videos.length,
            itemBuilder: (context, i) {
              return GestureDetector(
                onTap: () {
                  Provider.of<VideoProvider>(context, listen: false)
                      .updateplayingvideo(videos[i]);
                  Get.to(PlayVideo());
                },
                child: Container(
                  color: Colors.grey[900],
                  height: MediaQuery.of(context).size.height * 0.35,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.26,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.network(
                                videos[i].thumbnail,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: ClipOval(
                              child: SizedBox(
                                width: 40,
                                height: 40,
                                child: CachedNetworkImage(
                                  placeholderFadeInDuration:
                                      Duration(seconds: 2),
                                  fit: BoxFit.cover,
                                  imageUrl: videos[i].author.authorProfile,
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
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        } else {
          return Container(
            color: Colors.white,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
