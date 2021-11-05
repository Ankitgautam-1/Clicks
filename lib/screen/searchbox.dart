// ignore_for_file: no_logic_in_create_state

import 'package:cached_network_image/cached_network_image.dart';
import 'package:clicks/model/videos.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/string_extensions.dart';

class SerachBox extends StatefulWidget {
  const SerachBox({Key? key, required this.app}) : super(key: key);
  final FirebaseApp app;
  @override
  _SerachBoxState createState() => _SerachBoxState(app: app);
}

class _SerachBoxState extends State<SerachBox> {
  final FirebaseApp app;
  final TextEditingController _searchtext = TextEditingController();
  _SerachBoxState({required this.app});
  final _firestore = FirebaseFirestore.instance;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _listofjsondata = [];
  List<dynamic> _listofvideos = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            color: Colors.grey[900],
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: TextField(
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      hintText: "Search here",
                      border: OutlineInputBorder(
                          borderSide: (BorderSide(width: 0))),
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: IconButton(
                        splashColor: Colors.transparent,
                        color: Colors.black,
                        onPressed: () {
                          _searchtext.clear();
                        },
                        icon: const Icon(Icons.clear),
                      ),
                      icon: Icon(
                        Icons.search_rounded,
                        color: Colors.white,
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: (BorderSide(
                              width: 0, color: Colors.transparent))),
                    ),
                    onSubmitted: (value) async {
                      await serachvideos(value.trim().capitalize!)
                          .whenComplete(() {
                        print("calledsetstate");
                        setState(() {});
                      });
                    },
                    controller: _searchtext,
                    autofocus: true,
                  ),
                ),
                Container(
                  height: 600,
                  child: ListView.builder(
                      itemCount: _listofvideos.length,
                      itemBuilder: (context, i) {
                        return ListTile(
                          leading: CachedNetworkImage(
                              width: 90,
                              height: 30,
                              imageUrl: _listofvideos[i].thumbnail),
                        );
                      }),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> serachvideos(String value) async {
    _listofvideos.clear();
    print("getting");
    final videos = await _firestore
        .collection("videos")
        .where("title", isEqualTo: value)
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> value) {
      _listofjsondata = value.docs;
    });

    _listofjsondata.forEach((element) {
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
      _listofvideos.add(video);
      print("Added the video:$_listofvideos");
    });
  }
}
