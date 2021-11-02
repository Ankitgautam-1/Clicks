import 'package:clicks/provider/video_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PlayVideo extends StatefulWidget {
  const PlayVideo({Key? key}) : super(key: key);

  @override
  _PlayVideoState createState() => _PlayVideoState();
}

class _PlayVideoState extends State<PlayVideo> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      body: Consumer<VideoProvider>(
        builder: (context, data, _) {
          return Center(
            child: Text(
              data.video.title,
              style: GoogleFonts.aBeeZee(fontSize: 24),
            ),
          );
        },
      ),
    ));
  }
}
