import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationService extends StatefulWidget {
  const LocationService({super.key});

  @override
  State<LocationService> createState() => _LocationServiceState();
}

class _LocationServiceState extends State<LocationService> {
  Timer? _timer;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _checkPermission();
    _startLocationUpdates();
  }

  void _checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      await Geolocator.requestPermission();
    }
  }

  void _startLocationUpdates() {
    try{
      _timer = Timer.periodic(Duration(seconds: 5), (Timer t) async {
        Position position = await Geolocator.getCurrentPosition();
        setState(() {
          _currentPosition = position;
        });
        print("Location Updated: ${position.latitude}, ${position.longitude}");
        // Optionally, save to server or storage here
      });
    }catch(e){
      print(e.toString());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Location every 2 minutes")),
      body: Center(
        child: _currentPosition == null
            ? Text("Getting location...")
            : Text("Lat: ${_currentPosition!.latitude}, "
            "Lng: ${_currentPosition!.longitude}"),
      ),
    );
  }
}

