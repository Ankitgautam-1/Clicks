import 'package:cached_network_image/cached_network_image.dart';
import 'package:clicks/model/user_data.dart';
import 'package:clicks/model/videos.dart';
import 'package:clicks/provider/user_data_provider.dart';
import 'package:clicks/provider/video_provider.dart';
import 'package:clicks/screen/playing_video.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:timeago/timeago.dart' as timeago;

class VideosScreen extends StatefulWidget {
  const VideosScreen({Key? key}) : super(key: key);

  @override
  _VideosScreenState createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  final _firestore = FirebaseFirestore.instance;
  List<Video> videos = [];
  Future<List<Video>> getVideos() async {
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
            dislikes: element.data()['dislikes'],
            likes: element.data()['likes'],
            views: element.data()['views'],
            videoUid: element.data()['videoUid'],
            category: element.data()['category'],
            location: element.data()['location'],
            thumbnail: element.data()['thumbnail'],
            title: element.data()['title'],
            uploadTime: element.data()['uploadTime'],
            author: author,
            videoLink: element.data()['videoLink']);
        videos.add(video);
        setState(() {
          videos = videos;
        });
      });
    });
    _refreshController.refreshCompleted();
    return videos;
  }

  RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  @override
  Widget build(BuildContext context) {
    print("here");
    return SmartRefresher(
      controller: _refreshController,
      onRefresh: getVideos,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: videos.length,
        itemBuilder: (context, i) {
          return Consumer<VideoProvider>(builder: (context, data, _) {
            return GestureDetector(
              onTap: () {
                var collectionReference =
                    _firestore.collection('videos').doc(videos[i].videoUid);
                UserData userData =
                    Provider.of<UserDataProvider>(context, listen: false)
                        .userData;
                if (videos[i].views != null) {
                  if (videos[i].views.contains(userData.uid)) {
                  } else {
                    collectionReference.update({
                      "views": FieldValue.arrayUnion([userData.uid])
                    });
                    videos[i].views.add([userData.uid]);
                    data.updateviews(videos[i].views);
                  }
                } else {
                  collectionReference.update({
                    "views": [userData.uid]
                  });
                  videos[i].views = [userData.uid];
                  data.updateviews(videos[i].views);
                }
                Provider.of<VideoProvider>(context, listen: false)
                    .updateplayingvideo(videos[i]);
                Get.to(PlayVideo());
              },
              child: Container(
                color: Colors.grey[900],
                height: MediaQuery.of(context).size.height * 0.3777,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.26,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CachedNetworkImage(
                              imageUrl: videos[i].thumbnail,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: ClipOval(
                            child: SizedBox(
                              width: 40,
                              height: 40,
                              child: CachedNetworkImage(
                                placeholderFadeInDuration: Duration(seconds: 2),
                                fit: BoxFit.cover,
                                imageUrl: videos[i].author.authorProfile,
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) =>
                                        CircularProgressIndicator(
                                            value: downloadProgress.progress),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .8,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      videos[i].title.toString().length < 23
                                          ? videos[i].title.toString()
                                          : videos[i]
                                              .title
                                              .toString()
                                              .substring(0, 23),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                          fontSize: 13, color: Colors.white),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Text(
                                      videos[i].location.toString().length < 20
                                          ? videos[i].location.toString()
                                          : videos[i]
                                              .location
                                              .toString()
                                              .substring(0, 20),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                          fontSize: 13, color: Colors.white),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * .8,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      videos[i]
                                                  .author
                                                  .authorUsername
                                                  .toString()
                                                  .length <
                                              6
                                          ? videos[i]
                                              .author
                                              .authorUsername
                                              .toString()
                                          : videos[i]
                                              .author
                                              .authorUsername
                                              .toString()
                                              .substring(0, 6),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  Text(
                                    "views: ${videos[i].views == null ? "0" : videos[i].views.length}",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    timeago.format(DateTime.parse(
                                        videos[i].uploadTime.toString())),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    videos[i].category.toString(),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          });
        },
      ),
    );
  }
}
