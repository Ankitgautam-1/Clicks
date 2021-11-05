import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:provider/provider.dart';

class Geocoding {
  final String apikey = "58f6afdd9e6947d1b48437540521dca6";

  Future<dynamic> getAddress(LocationData position, context) async {
    final String baseurl = "https://api.opencagedata.com/geocode/v1/json?q=" +
        position.latitude.toString() +
        "+" +
        position.longitude.toString() +
        "&key=" +
        apikey;

    try {
      http.Response response = await http.get(Uri.parse(baseurl));
      if (response.statusCode == 200) {
        String jsonData = response.body;
        var decodeData = jsonDecode(jsonData);
        var address = decodeData["results"][0]["components"]["state_district"] +
            "," +
            decodeData["results"][0]["components"]["state"];

        print(baseurl);
        print("response:$jsonData");

        print('Your address is ->$address');

        return address;
      } else if (response.statusCode == 400) {
        print(
            "Invalid request (bad request; a required parameter is missing; invalid coordinates; invalid version; invalid format)");
        return "Failed";
      } else if (response.statusCode == 404) {
        print("Invalid API endpoint");
        return "Failed";
      } else {
        print("Error $e");
        return "Failed";
      }
    } catch (e) {
      print("Error occured while connecting to the server $e");
      return "Failed";
    }
  }
}
