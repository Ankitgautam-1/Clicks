import 'package:clicks/model/user_data.dart';
import 'package:flutter/cupertino.dart';

class UserDataProvider extends ChangeNotifier {
  UserData userData =
      UserData(username: "", uid: "", phonenumber: "", imageurl: "");
  void updateuserdata(UserData userdata) {
    this.userData = userdata;
    notifyListeners();
  }
}
