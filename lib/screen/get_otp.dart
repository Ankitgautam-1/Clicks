// ignore_for_file: no_logic_in_create_state

import 'dart:io';

import 'package:clicks/model/user_data.dart';
import 'package:clicks/provider/user_data_provider.dart';
import 'package:clicks/screen/homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtpValidation extends StatefulWidget {
  final String username;
  final File image;
  final FirebaseApp app;
  final String phonenumber;
  const OtpValidation(
      {Key? key,
      required this.app,
      required this.phonenumber,
      required this.image,
      required this.username})
      : super(key: key);

  @override
  _OtpValidationState createState() => _OtpValidationState(
      app: app, phonenumber: phonenumber, image: image, username: username);
}

class _OtpValidationState extends State<OtpValidation> {
  final String username;
  final File image;
  final FirebaseApp app;
  final String phonenumber;

  var verificationId = "";
  _OtpValidationState(
      {required this.app,
      required this.phonenumber,
      required this.image,
      required this.username});
  TextEditingController _1st = TextEditingController();
  TextEditingController _2nd = TextEditingController();
  TextEditingController _3rd = TextEditingController();
  TextEditingController _4th = TextEditingController();
  TextEditingController _5th = TextEditingController();
  TextEditingController _6th = TextEditingController();
  bool Isloading = false;
  FirebaseAuth auth = FirebaseAuth.instance;
  String _otp = "";
  User? user;
  final String _ph = "";

  @override
  void initState() {
    super.initState();
    sendotp();
  }

  void sendotp() async {
    FirebaseAuth _auth = FirebaseAuth.instanceFor(app: app);

    _auth.verifyPhoneNumber(
      phoneNumber: "+91" + phonenumber,
      verificationCompleted: (PhoneAuthCredential phoneAuthCredential) {
        _auth.signInWithCredential(phoneAuthCredential);
      },
      verificationFailed: (FirebaseAuthException error) {
        if (error.code == 'invalid-phone-number') {
          print('The provided phone number is not valid.');
        }
      },
      codeSent: (verificationId, resendToken) {
        print("Otp is send ");
        Get.snackbar(
          "",
          "",
          titleText: const Text(
            'OTP Verification',
            style: TextStyle(
              fontSize: 15,
            ),
          ),
          messageText: Text(
            'A OTP Message is send to your Mobile number $phonenumber is verify it',
            style: const TextStyle(
              fontSize: 11,
            ),
          ),
        );
        setState(() {
          this.verificationId = verificationId;
        });
        print('$verificationId here it\'s');
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        this.verificationId = verificationId;
      },
      timeout: const Duration(seconds: 60),
    );
  }

  Future<void> verify(String otp) async {
    setState(() {
      Isloading = true;
    });
    try {
      print(' ver :$verificationId');
      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: otp);
      print('Signed In $phoneAuthCredential');
      try {
        auth
            .signInWithCredential(phoneAuthCredential)
            .then((UserCredential userCredential) async {
          user = auth.currentUser;
          if (user != null) {
            firebase_storage.Reference ref = firebase_storage
                .FirebaseStorage.instance
                .ref()
                .child("User_details")
                .child('/${user!.uid}/${user!.uid}');

            ref.putFile(image).then((taskstate) async {
              String imageurl = await ref.getDownloadURL();
              print('imageurl:$imageurl');
              final _firestore = FirebaseFirestore.instance;
              final videos = await _firestore
                  .collection("videos")
                  .where("author.authorUid", isEqualTo: user!.uid)
                  .get()
                  .then((value) {
                if (value.docs.isNotEmpty) {
                  value.docs.forEach((element) {
                    print(
                        "all video by this creater:${element.data()["videoUid"]}");
                    _firestore
                        .collection("videos")
                        .doc(element.data()["videoUid"])
                        .update({"author.authorProfile": imageurl});
                  });
                }
              });
              final DatabaseReference db =
                  FirebaseDatabase(app: app).reference();
              db.child('Users').child(user!.uid).set({
                'username': username,
                "imageurl": imageurl,
                "uid": user!.uid,
                "phone": phonenumber
              }).then((value) async {
                UserData userData = UserData(
                    imageurl: imageurl,
                    phonenumber: phonenumber,
                    uid: user!.uid,
                    username: username);
                print("Userdata class:$userData");
                Provider.of<UserDataProvider>(context, listen: false)
                    .updateuserdata(userData);
                setState(() {
                  Isloading = false;
                });
                print(
                    "data from getotp :${Provider.of<UserDataProvider>(context, listen: false).userData.imageurl}");
                SharedPreferences Sp = await SharedPreferences.getInstance();
                Sp.setString("username", username);
                Sp.setString("uid", user!.uid);
                Sp.setString("imageurl", imageurl);
                Sp.setString("phonenumber", phonenumber);
                Get.offAll(Homepage(app: app));
              });
            });
          }
        }).onError((error, stackTrace) {
          Get.snackbar(
            "Phone verification",
            "Error occured $error",
            snackPosition: SnackPosition.BOTTOM,
          );
        });
      } catch (e) {
        Get.snackbar(
          "Phone verification",
          "Error occured $e",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print("Error while Signin with phone ");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
            alignment: Alignment.topLeft,
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () async {
                      Get.back();
                      try {
                        await auth.signOut();
                      } catch (e) {}
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
                  ),
                  Center(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Image.asset(
                            'asset/images/Mobile_verify.jpg',
                            width: 280,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Text(
                          'OTP Verification',
                          style: GoogleFonts.ubuntu(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 20),
                    child: Text(
                      'We will send you an One Time Password on this mobile number',
                      textAlign: TextAlign.left,
                      style: GoogleFonts.ubuntu(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.03,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 58,
                        width: 45,
                        child: TextFormField(
                          cursorColor: Colors.black,
                          cursorWidth: 1,
                          controller: _1st,
                          autofocus: true,
                          onChanged: (value) {
                            if (value.length == 1) {
                              FocusScope.of(context).nextFocus();
                            }
                          },
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                          decoration: InputDecoration(
                            counterText: "",
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(width: 2.0, color: Colors.black),
                            ),
                            border: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(width: 1.4),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 58,
                        width: 45,
                        child: TextFormField(
                          cursorColor: Colors.black,
                          cursorWidth: 1,
                          controller: _2nd,
                          autofocus: true,
                          onChanged: (value) {
                            if (value.length == 1) {
                              FocusScope.of(context).nextFocus();
                            }
                            if (value.length != 1) {
                              FocusScope.of(context).previousFocus();
                            }
                          },
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                          decoration: InputDecoration(
                            counterText: "",
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(width: 2.0, color: Colors.black),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(width: 1.4),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 58,
                        width: 45,
                        child: TextFormField(
                          cursorColor: Colors.black,
                          cursorWidth: 1,
                          controller: _3rd,
                          autofocus: true,
                          onChanged: (value) {
                            if (value.length == 1) {
                              FocusScope.of(context).nextFocus();
                            }
                            if (value.length != 1) {
                              FocusScope.of(context).previousFocus();
                            }
                          },
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                          decoration: InputDecoration(
                            counterText: "",
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(width: 2.0, color: Colors.black),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(width: 1.4),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 58,
                        width: 45,
                        child: TextFormField(
                          cursorWidth: 1,
                          cursorColor: Colors.black,
                          controller: _4th,
                          autofocus: true,
                          onChanged: (value) {
                            if (value.length == 1) {
                              FocusScope.of(context).nextFocus();
                            }
                            if (value.length != 1) {
                              FocusScope.of(context).previousFocus();
                            }
                          },
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                          decoration: InputDecoration(
                            counterText: "",
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(width: 2.0, color: Colors.black),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(width: 1.4),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 58,
                        width: 45,
                        child: TextFormField(
                          cursorColor: Colors.black,
                          cursorWidth: 1,
                          controller: _5th,
                          autofocus: true,
                          onChanged: (value) {
                            if (value.length == 1) {
                              FocusScope.of(context).nextFocus();
                            }
                            if (value.length != 1) {
                              FocusScope.of(context).previousFocus();
                            }
                          },
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                          decoration: InputDecoration(
                            counterText: "",
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(width: 2.0, color: Colors.black),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(width: 1.4),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 58,
                        width: 45,
                        child: TextFormField(
                          cursorColor: Colors.black,
                          cursorWidth: 1,
                          controller: _6th,
                          autofocus: true,
                          onChanged: (value) {
                            if (value.length == 1) {
                              FocusScope.of(context).nextFocus();
                            }
                            if (value.length != 1) {
                              FocusScope.of(context).previousFocus();
                            }
                          },
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                          decoration: InputDecoration(
                            counterText: "",
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(width: 2.0, color: Colors.black),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(width: 1.4),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.03,
                  ),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 90, vertical: 12),
                        primary: Color.fromRGBO(0, 0, 0, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13.0),
                        ),
                      ),
                      onPressed: () async {
                        FocusScope.of(context)
                            .unfocus(); //to hide the keyboard by unfocusing on textformfield
                        _otp = _1st.text +
                            _2nd.text +
                            _3rd.text +
                            _4th.text +
                            _5th.text +
                            _6th.text;
                        print("Your otp is  $_otp");

                        await verify(_otp);
                      },
                      child: Text(
                        'Verify OTP',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Didn\'t receive OTP ?',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          sendotp();
                        },
                        child: const Text(
                          ' Resend OTP',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Isloading
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : Container(),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
