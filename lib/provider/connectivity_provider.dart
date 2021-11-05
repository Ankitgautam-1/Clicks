import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class DataConnection extends ChangeNotifier {
  Connectivity _connectivity = Connectivity();
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  getDataConnection() async {
    await getConnectivity();
    _connectivity.onConnectivityChanged.listen((result) {
      if (result == ConnectivityResult.none) {
        _isOnline = false;
        notifyListeners();
      } else {
        _isOnline = true;
        notifyListeners();
      }
    });
  }

  Future<void> getConnectivity() async {
    try {
      var state = await _connectivity.checkConnectivity();
      if (state == ConnectivityResult.none) {
        _isOnline = false;
        notifyListeners();
      } else {
        _isOnline = true;
      }
    } on PlatformException catch (e) {
      print('Got Error while get data connnection details ${e.toString()}');
    }
  }
}
