// ignore_for_file: no_logic_in_create_state

import 'dart:developer';
import 'dart:io';

import 'package:clicks/screen/get_otp.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class SignIn extends StatefulWidget {
  final FirebaseApp app;
  const SignIn({Key? key, required this.app}) : super(key: key);

  @override
  _SignInState createState() => _SignInState(app: app);
}

class _SignInState extends State<SignIn> {
  FirebaseApp app;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final TextEditingController _ph = TextEditingController();
  final TextEditingController _username = TextEditingController();
  int _phlen = 0;
  final picker = ImagePicker();
  var _image;
  bool image = false;
  _SignInState({required this.app});
  void validation() async {
    if (_formkey.currentState!.validate()) {
      if (image) {
        Get.to(
          OtpValidation(
            app: app,
            phonenumber: _ph.text.trim(),
            image: _image,
            username: _username.text.trim(),
          ),
        );
      } else {
        Get.snackbar("Profile picture", "Profile picture is not selected ",
            snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.95,
            color: Colors.white,
            alignment: Alignment.topLeft,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    "Welcome,",
                    style: GoogleFonts.aBeeZee(fontSize: 25),
                  ),
                ),
                Center(
                    child: Stack(
                  children: [
                    !image
                        ? CircleAvatar(
                            radius: 50,
                            foregroundImage: const AssetImage(
                                'asset/images/profile_pic.jpg'),
                            backgroundColor: Colors.grey[200],
                          )
                        : ClipOval(
                            child: SizedBox(
                              width: 100,
                              height: 100,
                              child: Image.file(
                                _image,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                        ),
                        width: 35,
                        height: 35,
                        child: GestureDetector(
                          onTap: () {
                            Get.bottomSheet(getPic());
                          },
                          child: const Icon(
                            Icons.camera,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  ],
                )),
                Center(
                  child: Container(
                    color: Colors.white,
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Form(
                      key: _formkey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextFormField(
                            cursorColor: Colors.grey[700],
                            validator: (value) {
                              if (value!.isEmpty || value.length < 4) {
                                return "Username shoud be at least 4 letters";
                              }
                            },
                            decoration: InputDecoration(
                              errorStyle: GoogleFonts.aBeeZee(),
                              icon: const Icon(
                                Icons.person,
                                color: Colors.black,
                              ),
                              border: const OutlineInputBorder(),
                              hintText: 'Enter Your Name',
                              hintStyle: GoogleFonts.aBeeZee(),
                              label: Text("Username",
                                  style:
                                      GoogleFonts.aBeeZee(color: Colors.black)),
                              focusedBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.black, width: 0.8),
                              ),
                            ),
                            controller: _username,
                            keyboardType: TextInputType.name,
                          ),
                          SizedBox(
                            height: 50,
                          ),
                          TextFormField(
                            maxLength: 10,
                            cursorColor: Colors.grey[700],
                            validator: (value) {
                              if (value!.length != 10) {
                                return "Please enter 10 digits phone number";
                              }
                            },
                            decoration: InputDecoration(
                              errorStyle: GoogleFonts.aBeeZee(),
                              counterStyle: GoogleFonts.aBeeZee(),
                              icon: const Icon(
                                Icons.phone,
                                color: Colors.black,
                              ),
                              border: const OutlineInputBorder(),
                              hintText: 'Enter Mobile Number',
                              hintStyle: GoogleFonts.aBeeZee(),
                              label: Text("Phone",
                                  style:
                                      GoogleFonts.aBeeZee(color: Colors.black)),
                              focusedBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.black, width: 0.8),
                              ),
                            ),
                            controller: _ph,
                            keyboardType: TextInputType.phone,
                          ),
                          SizedBox(
                            height: 50,
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 110, vertical: 13)),
                            onPressed: validation,
                            child: Text(
                              "Login",
                              style: GoogleFonts.aBeeZee(),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getPic() {
    return Container(
      color: Colors.white,
      height: 150,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Choos your profile picture",
            style: GoogleFonts.ubuntu(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: [
              GestureDetector(
                onTap: getCamera,
                child: Container(
                  width: 50,
                  height: 50,
                  child: Icon(Icons.camera, color: Colors.white),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              GestureDetector(
                onTap: getImage,
                child: Container(
                  width: 50,
                  height: 50,
                  child: Icon(Icons.image, color: Colors.white),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              GestureDetector(
                onTap: deleteprofile,
                child: Container(
                  width: 50,
                  height: 50,
                  child: Icon(Icons.delete, color: Colors.white),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void deleteprofile() {
    setState(() {
      image = false;
      _image = Image.asset('asset/images/profile.jpg');
    });
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        File _im = File(pickedFile.path);
        _image = _im;
        image = true;
        print("image-->$_image");
      } else {
        print('No image selected.');
      }
    });
  }

  Future getCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(
      () {
        if (pickedFile != null) {
          File _im = File(pickedFile.path);
          _image = _im;
          image = true;
          print(" image ${_image.toString().trim()}");
        } else {
          print('No image selected.');
        }
      },
    );
  }
}
