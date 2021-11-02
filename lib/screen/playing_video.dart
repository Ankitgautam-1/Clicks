import 'package:cached_network_image/cached_network_image.dart';
import 'package:clicks/provider/user_data_provider.dart';
import 'package:clicks/provider/video_provider.dart';
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
  late ChewieController chewieController;
  final GlobalKey<FormState> _commentkey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.network(
        Provider.of<VideoProvider>(context, listen: false)
            .video
            .videoLink
            .toString());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.grey[900],
      body: Consumer<VideoProvider>(
        builder: (context, data, _) {
          return GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: SingleChildScrollView(
              child: Container(
                color: Colors.grey[900],
                height: MediaQuery.of(context).size.height * 0.96,
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
                          aspectRatio:
                              0.83 / (MediaQuery.of(context).size.aspectRatio),
                          videoPlayerController: _controller,
                          autoPlay: true,
                          looping: true,
                          allowMuting: true,
                          showControls: true,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: Colors.grey[900],
                        child: Consumer<VideoProvider>(
                            builder: (context, data, _) {
                          return Container(
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 0, vertical: 11),
                                            child: Container(
                                              child: CircleAvatar(
                                                radius: 30,
                                                child: ClipOval(
                                                  child: SizedBox(
                                                    child: CachedNetworkImage(
                                                      width: 60,
                                                      height: 60,
                                                      placeholderFadeInDuration:
                                                          Duration(seconds: 2),
                                                      fit: BoxFit.cover,
                                                      imageUrl: data.video
                                                          .author.authorProfile,
                                                      progressIndicatorBuilder: (context,
                                                              url,
                                                              downloadProgress) =>
                                                          CircularProgressIndicator(
                                                              value:
                                                                  downloadProgress
                                                                      .progress),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          const Icon(
                                                              Icons.error),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                      Text(
                                        data.video.title,
                                        style: TextStyle(
                                            fontSize: 15, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      TextButton.icon(
                                          onPressed: () {},
                                          icon: Icon(
                                            Icons.thumb_up_alt_rounded,
                                            color: Colors.blue,
                                          ),
                                          label: Text('Like')),
                                      TextButton.icon(
                                          onPressed: () {},
                                          icon: Icon(
                                            Icons.thumb_down_alt_rounded,
                                            color: Colors.grey.shade100,
                                          ),
                                          label: Text(
                                            'Dislike',
                                            style: TextStyle(
                                                color: Colors.grey.shade100),
                                          )),
                                      TextButton.icon(
                                        onPressed: () {},
                                        icon: Icon(
                                          Icons.copy,
                                          color: Colors.grey.shade100,
                                        ),
                                        label: Text(
                                          'Share',
                                          style: TextStyle(
                                              color: Colors.grey.shade100),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(
                                        "views:${data.video.views == null ? "0" : data.video.views.length}",
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      Text(
                                        timeago.format(DateTime.parse(
                                            data.video.uploadTime.toString())),
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      Text(
                                        data.video.category.toString(),
                                        style: TextStyle(color: Colors.white),
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
                                            ? data.video.author.authorUsername
                                                .toString()
                                            : data.video.author.authorUsername
                                                .toString()
                                                .substring(0, 6),
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      TextButton(
                                        style: TextButton.styleFrom(
                                            backgroundColor: Colors.blue),
                                        onPressed: () {},
                                        child: const Text('View All Video',
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ),
                                    ],
                                  ),
                                  Form(
                                    key: _commentkey,
                                    child: TextFormField(
                                      validator: (value) => value != null
                                          ? value.trim().isEmpty
                                              ? "Enter somthing to comment"
                                              : null
                                          : "Enter somthing to comment",
                                      cursorColor: Colors.grey.shade400,
                                      keyboardType: TextInputType.text,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.grey.shade200,
                                        hintText: " Add Your Comment Here",
                                        hintStyle:
                                            TextStyle(color: Colors.black),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          borderSide: BorderSide(
                                              width: 1,
                                              color: Colors.grey.shade300),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          borderSide: BorderSide(
                                              width: 1, color: Colors.white),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 2),
                                        suffixIcon: IconButton(
                                          onPressed: () {},
                                          icon: Icon(Icons.send,
                                              color: Colors.blue[900]),
                                        ),
                                        icon: Icon(Icons.chat,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    chewieController.dispose();
    super.dispose();
  }
}
