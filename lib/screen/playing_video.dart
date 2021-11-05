import 'package:cached_network_image/cached_network_image.dart';
import 'package:clicks/model/user_data.dart';
import 'package:clicks/provider/user_data_provider.dart';
import 'package:clicks/provider/video_provider.dart';
import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:timeago/timeago.dart' as timeago;

class PlayVideo extends StatefulWidget {
  const PlayVideo({Key? key}) : super(key: key);

  @override
  _PlayVideoState createState() => _PlayVideoState();
}

class _PlayVideoState extends State<PlayVideo> {
  late VideoPlayerController _controller;
  ChewieController? chewieController;
  bool _hasnolike = false;
  final _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _commentkey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.network(
      Provider.of<VideoProvider>(context, listen: false)
          .video
          .videoLink
          .toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[900],
        body: SingleChildScrollView(
          child: MediaQuery.of(context).orientation == Orientation.portrait
              ? Container(
                  color: Colors.grey.shade900,
                  height: MediaQuery.of(context).size.height,
                  child: Consumer<VideoProvider>(
                    builder: (context, data, _) {
                      return GestureDetector(
                        onTap: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        child: Column(
                          children: [
                            Container(
                              height: 200,
                              child: Chewie(
                                controller: ChewieController(
                                  materialProgressColors: ChewieProgressColors(
                                      backgroundColor: Colors.grey.shade700,
                                      bufferedColor: Colors.grey.shade300,
                                      playedColor: Colors.red.shade400),
                                  aspectRatio: 0.83 /
                                      (MediaQuery.of(context).size.aspectRatio),
                                  videoPlayerController: _controller,
                                  autoPlay: true,
                                  looping: false,
                                  allowMuting: true,
                                  showControls: true,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                color: Colors.grey[900],
                                child: Container(
                                  width: double.infinity,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Consumer<VideoProvider>(
                                              builder: (context, data, _) {
                                                return GestureDetector(
                                                  onTap: () {},
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 0,
                                                        vertical: 11),
                                                    child: Container(
                                                      child: CircleAvatar(
                                                        radius: 30,
                                                        child: ClipOval(
                                                          child: SizedBox(
                                                            child:
                                                                CachedNetworkImage(
                                                              width: 60,
                                                              height: 60,
                                                              placeholderFadeInDuration:
                                                                  Duration(
                                                                      seconds:
                                                                          2),
                                                              fit: BoxFit.cover,
                                                              imageUrl: data
                                                                  .video
                                                                  .author
                                                                  .authorProfile,
                                                              progressIndicatorBuilder: (context,
                                                                      url,
                                                                      downloadProgress) =>
                                                                  CircularProgressIndicator(
                                                                      value: downloadProgress
                                                                          .progress),
                                                              errorWidget: (context,
                                                                      url,
                                                                      error) =>
                                                                  const Icon(Icons
                                                                      .error),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            Text(
                                              data.video.title,
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                var collectionReference =
                                                    _firestore
                                                        .collection('videos')
                                                        .doc(data
                                                            .video.videoUid);
                                                collectionReference.get().then(
                                                    (DocumentSnapshot<
                                                            Map<String,
                                                                dynamic>>
                                                        snapshot) {
                                                  List dislikesonvideo =
                                                      snapshot
                                                          .data()!['dislikes'];
                                                  UserData userData = Provider
                                                          .of<UserDataProvider>(
                                                              context,
                                                              listen: false)
                                                      .userData;
                                                  if (dislikesonvideo
                                                      .contains(userData.uid)) {
                                                    collectionReference.update({
                                                      "dislikes": FieldValue
                                                          .arrayRemove(
                                                              [userData.uid])
                                                    });

                                                    data.video.dislikes
                                                        .remove(userData.uid);
                                                    data.updatedislike(
                                                        data.video.likes);
                                                  }
                                                  collectionReference =
                                                      _firestore
                                                          .collection('videos')
                                                          .doc(data
                                                              .video.videoUid);
                                                  collectionReference
                                                      .get()
                                                      .then((DocumentSnapshot<
                                                              Map<String,
                                                                  dynamic>>
                                                          snapshot) {
                                                    List likesonvideo = snapshot
                                                        .data()!['likes'];
                                                    UserData userData = Provider
                                                            .of<UserDataProvider>(
                                                                context,
                                                                listen: false)
                                                        .userData;
                                                    if (likesonvideo
                                                        .isNotEmpty) {
                                                      print("in if block");
                                                      if (likesonvideo.contains(
                                                              userData.uid) &&
                                                          likesonvideo.length ==
                                                              1) {
                                                        print("in if 1");
                                                        collectionReference
                                                            .update(
                                                                {"likes": []});
                                                        data.video.likes = [];
                                                        data.updatelike(
                                                            data.video.likes);
                                                      } else if (likesonvideo
                                                              .contains(userData
                                                                  .uid) &&
                                                          likesonvideo
                                                              .isNotEmpty) {
                                                        print("in if  2");
                                                        collectionReference
                                                            .update({
                                                          "likes": FieldValue
                                                              .arrayRemove([
                                                            userData.uid
                                                          ])
                                                        });

                                                        data.video.likes.remove(
                                                            userData.uid);
                                                        data.updatelike(
                                                            data.video.likes);
                                                      } else if (!(data
                                                              .video.likes
                                                              .contains(userData
                                                                  .uid)) &&
                                                          data.video.likes
                                                                  .length ==
                                                              0) {
                                                        print("in if 3");
                                                        collectionReference
                                                            .update({
                                                          "likes": [
                                                            userData.uid
                                                          ]
                                                        });
                                                        data.video.likes = [
                                                          userData.uid
                                                        ];
                                                        data.updatelike(
                                                            data.video.likes);
                                                      } else if (!(data
                                                              .video.likes
                                                              .contains(userData
                                                                  .uid)) &&
                                                          data.video.likes
                                                                  .length >
                                                              0) {
                                                        print("in if 5");
                                                        //user has already like video
                                                        collectionReference
                                                            .update({
                                                          "likes": FieldValue
                                                              .arrayUnion([
                                                            userData.uid
                                                          ])
                                                        });
                                                        data.video.likes
                                                            .add(userData.uid);
                                                        data.updatelike(
                                                            data.video.likes);
                                                      }
                                                    } else {
                                                      print(
                                                          'else block for no likes on video');
                                                      collectionReference
                                                          .update({
                                                        "likes": [userData.uid]
                                                      });
                                                      data.video.likes = [
                                                        userData.uid
                                                      ];
                                                      data.updatelike(
                                                          data.video.likes);
                                                    }
                                                  });
                                                });
                                              },
                                              child: Column(
                                                children: [
                                                  Icon(
                                                      Icons
                                                          .thumb_up_alt_rounded,
                                                      color: data.video.likes ==
                                                              null
                                                          ? Colors.grey.shade200
                                                          : data.video.likes.contains(
                                                                  Provider.of<UserDataProvider>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .userData
                                                                      .uid)
                                                              ? Colors.blue[700]
                                                              : Colors.grey
                                                                  .shade200),
                                                  Center(
                                                    child: Text(
                                                        data.video.likes == null
                                                            ? "0"
                                                            : data.video.likes
                                                                .length
                                                                .toString(),
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        )),
                                                  )
                                                ],
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                var collectionReference =
                                                    _firestore
                                                        .collection('videos')
                                                        .doc(data
                                                            .video.videoUid);
                                                collectionReference.get().then(
                                                    (DocumentSnapshot<
                                                            Map<String,
                                                                dynamic>>
                                                        snapshot) {
                                                  List likesonvideo =
                                                      snapshot.data()!['likes'];
                                                  UserData userData = Provider
                                                          .of<UserDataProvider>(
                                                              context,
                                                              listen: false)
                                                      .userData;
                                                  if (likesonvideo
                                                      .contains(userData.uid)) {
                                                    collectionReference.update({
                                                      "likes": FieldValue
                                                          .arrayRemove(
                                                              [userData.uid])
                                                    });

                                                    data.video.likes
                                                        .remove(userData.uid);
                                                    data.updatelike(
                                                        data.video.likes);
                                                    collectionReference =
                                                        _firestore
                                                            .collection(
                                                                'videos')
                                                            .doc(data.video
                                                                .videoUid);
                                                    collectionReference
                                                        .get()
                                                        .then((DocumentSnapshot<
                                                                Map<String,
                                                                    dynamic>>
                                                            snapshot) {
                                                      List dislikesonvideo =
                                                          snapshot.data()![
                                                              'dislikes'];
                                                      UserData userData = Provider
                                                              .of<UserDataProvider>(
                                                                  context,
                                                                  listen: false)
                                                          .userData;
                                                      if (dislikesonvideo
                                                          .isNotEmpty) {
                                                        print("in if block");
                                                        if (dislikesonvideo
                                                                .contains(
                                                                    userData
                                                                        .uid) &&
                                                            dislikesonvideo
                                                                    .length ==
                                                                1) {
                                                          print("in if 1");
                                                          collectionReference
                                                              .update({
                                                            "dislikes": []
                                                          });
                                                          data.video.dislikes =
                                                              [];
                                                          data.updatedislike(
                                                              data.video
                                                                  .dislikes);
                                                        } else if (dislikesonvideo
                                                                .contains(
                                                                    userData
                                                                        .uid) &&
                                                            dislikesonvideo
                                                                .isNotEmpty) {
                                                          print("in if  2");
                                                          collectionReference
                                                              .update({
                                                            "disikes": FieldValue
                                                                .arrayRemove([
                                                              userData.uid
                                                            ])
                                                          });
                                                          var arr = [];
                                                          data.video.dislikes
                                                              .remove(
                                                                  userData.uid);
                                                          data.updatedislike(
                                                              data.video
                                                                  .dislikes);
                                                        } else if (!(data
                                                                .video.dislikes
                                                                .contains(
                                                                    userData
                                                                        .uid)) &&
                                                            data.video.dislikes
                                                                    .length ==
                                                                0) {
                                                          print("in if 3");
                                                          collectionReference
                                                              .update({
                                                            "dislikes": [
                                                              userData.uid
                                                            ]
                                                          });
                                                          data.video.dislikes =
                                                              [userData.uid];
                                                          data.updatedislike(
                                                              data.video
                                                                  .dislikes);
                                                        } else if (!(data
                                                                .video.dislikes
                                                                .contains(
                                                                    userData
                                                                        .uid)) &&
                                                            data.video.dislikes
                                                                    .length >
                                                                0) {
                                                          print("in if 5");

                                                          collectionReference
                                                              .update({
                                                            "dislikes":
                                                                FieldValue
                                                                    .arrayUnion([
                                                              userData.uid
                                                            ])
                                                          });
                                                          data.video.dislikes
                                                              .add(
                                                                  userData.uid);
                                                          data.updatedislike(
                                                              data.video
                                                                  .dislikes);
                                                        }
                                                      } else {
                                                        print(
                                                            'else block for no likes on video');
                                                        collectionReference
                                                            .update({
                                                          "dislikes": [
                                                            userData.uid
                                                          ]
                                                        });
                                                        data.video.dislikes = [
                                                          userData.uid
                                                        ];
                                                        data.updatedislike(data
                                                            .video.dislikes);
                                                      }
                                                    });
                                                  } else {
                                                    var collectionReference =
                                                        _firestore
                                                            .collection(
                                                                'videos')
                                                            .doc(data.video
                                                                .videoUid);
                                                    collectionReference
                                                        .get()
                                                        .then((DocumentSnapshot<
                                                                Map<String,
                                                                    dynamic>>
                                                            snapshot) {
                                                      List dislikesonvideo =
                                                          snapshot.data()![
                                                              'dislikes'];
                                                      UserData userData = Provider
                                                              .of<UserDataProvider>(
                                                                  context,
                                                                  listen: false)
                                                          .userData;
                                                      if (dislikesonvideo
                                                          .isNotEmpty) {
                                                        print("in if block");
                                                        if (dislikesonvideo
                                                                .contains(
                                                                    userData
                                                                        .uid) &&
                                                            dislikesonvideo
                                                                    .length ==
                                                                1) {
                                                          print("in if 1");
                                                          collectionReference
                                                              .update({
                                                            "dislikes": []
                                                          });
                                                          data.video.dislikes =
                                                              [];
                                                          data.updatedislike(
                                                              data.video
                                                                  .dislikes);
                                                        } else if (dislikesonvideo
                                                                .contains(
                                                                    userData
                                                                        .uid) &&
                                                            dislikesonvideo
                                                                .isNotEmpty) {
                                                          print("in if  2");
                                                          collectionReference
                                                              .update({
                                                            "disikes": FieldValue
                                                                .arrayRemove([
                                                              userData.uid
                                                            ])
                                                          });
                                                          var arr = [];
                                                          data.video.dislikes
                                                              .remove(
                                                                  userData.uid);
                                                          data.updatedislike(
                                                              data.video
                                                                  .dislikes);
                                                        } else if (!(data
                                                                .video.dislikes
                                                                .contains(
                                                                    userData
                                                                        .uid)) &&
                                                            data.video.dislikes
                                                                    .length ==
                                                                0) {
                                                          print("in if 3");
                                                          collectionReference
                                                              .update({
                                                            "dislikes": [
                                                              userData.uid
                                                            ]
                                                          });
                                                          data.video.dislikes =
                                                              [userData.uid];
                                                          data.updatedislike(
                                                              data.video
                                                                  .dislikes);
                                                        } else if (!(data
                                                                .video.dislikes
                                                                .contains(
                                                                    userData
                                                                        .uid)) &&
                                                            data.video.dislikes
                                                                    .length >
                                                                0) {
                                                          print("in if 5");

                                                          collectionReference
                                                              .update({
                                                            "dislikes":
                                                                FieldValue
                                                                    .arrayUnion([
                                                              userData.uid
                                                            ])
                                                          });
                                                          data.video.dislikes
                                                              .add(
                                                                  userData.uid);
                                                          data.updatedislike(
                                                              data.video
                                                                  .dislikes);
                                                        }
                                                      } else {
                                                        print(
                                                            'else block for no likes on video');
                                                        collectionReference
                                                            .update({
                                                          "dislikes": [
                                                            userData.uid
                                                          ]
                                                        });
                                                        data.video.dislikes = [
                                                          userData.uid
                                                        ];
                                                        data.updatedislike(data
                                                            .video.dislikes);
                                                      }
                                                    });
                                                  }
                                                });
                                              },
                                              child: Column(
                                                children: [
                                                  Icon(
                                                      Icons
                                                          .thumb_down_alt_rounded,
                                                      color: data.video
                                                                  .dislikes ==
                                                              null
                                                          ? Colors.grey.shade200
                                                          : data.video.dislikes
                                                                  .contains(Provider.of<
                                                                              UserDataProvider>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .userData
                                                                      .uid)
                                                              ? Colors.blue[700]
                                                              : Colors.grey
                                                                  .shade200),
                                                  Center(
                                                    child: Text(
                                                      data.video.dislikes ==
                                                              null
                                                          ? "0"
                                                          : data.video.dislikes
                                                              .length
                                                              .toString(),
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            TextButton.icon(
                                              onPressed: () async {
                                                await FlutterClipboard.copy(
                                                    data.video.videoLink);
                                                Scaffold.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: ScaffoldMessenger(
                                                      child: Text(
                                                        "Video Link copied",
                                                        style: GoogleFonts
                                                            .ubuntu(),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                              icon: Icon(
                                                Icons.copy,
                                                color: Colors.grey.shade100,
                                              ),
                                              label: Text(
                                                'Share',
                                                style: TextStyle(
                                                    color:
                                                        Colors.grey.shade100),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Text(
                                              "views: ${data.video.views == null ? "0" : data.video.views.length}",
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                            Text(
                                              timeago.format(DateTime.parse(data
                                                  .video.uploadTime
                                                  .toString())),
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            Text(
                                              data.video.category.toString(),
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Text(
                                              data.video.author.authorUsername
                                                          .toString()
                                                          .length <
                                                      6
                                                  ? data.video.author
                                                      .authorUsername
                                                      .toString()
                                                  : data.video.author
                                                      .authorUsername
                                                      .toString()
                                                      .substring(0, 6),
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                  backgroundColor: Colors.blue),
                                              onPressed: () {},
                                              child: const Text(
                                                  'View All Video',
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                            ),
                                          ],
                                        ),
                                        SingleChildScrollView(
                                          child: Form(
                                            key: _commentkey,
                                            child: TextFormField(
                                              validator: (value) => value !=
                                                      null
                                                  ? value.trim().isEmpty
                                                      ? "Enter somthing to comment"
                                                      : null
                                                  : "Enter somthing to comment",
                                              cursorColor: Colors.grey.shade400,
                                              keyboardType: TextInputType.text,
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor: Colors.grey.shade200,
                                                hintText:
                                                    " Add Your Comment Here",
                                                hintStyle: TextStyle(
                                                    color: Colors.black),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  borderSide: BorderSide(
                                                      width: 1,
                                                      color:
                                                          Colors.grey.shade300),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  borderSide: BorderSide(
                                                      width: 1,
                                                      color: Colors.white),
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 2),
                                                suffixIcon: IconButton(
                                                  onPressed: () {},
                                                  icon: Icon(
                                                    Icons.send,
                                                    color: Colors.blue[900],
                                                  ),
                                                ),
                                                icon: Icon(
                                                  Icons.chat,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )
              : Consumer<VideoProvider>(
                  builder: (context, data, _) {
                    return GestureDetector(
                      onTap: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      child: Column(
                        children: [
                          Container(
                            child: Chewie(
                              controller: ChewieController(
                                materialProgressColors: ChewieProgressColors(
                                    backgroundColor: Colors.grey.shade700,
                                    bufferedColor: Colors.grey.shade300,
                                    playedColor: Colors.red.shade400),
                                aspectRatio: 1.04 *
                                    (MediaQuery.of(context).size.aspectRatio),
                                videoPlayerController: _controller,
                                autoPlay: true,
                                looping: false,
                                allowMuting: true,
                                showControls: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    if (chewieController != null) {
      chewieController!.dispose();
    }
    super.dispose();
  }
}
