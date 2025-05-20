import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  // Step 1: Private constructor
  LocationService._privateConstructor();

  // Step 2: Static instance
  static final LocationService instance =
      LocationService._privateConstructor();

  // Step 3: Public factory to access the same instance
  factory LocationService() {
    return instance;
  }

  Future<Position?> getLocation(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: "Location services are disabled.");
      return null;
    }

    // Check and request permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: "Location permissions are denied");
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
          msg: "Location permissions are permanently denied.");
      return null;
    }

    // Get current position
    Position position = await Geolocator.getCurrentPosition();
    return position;
  }
}
