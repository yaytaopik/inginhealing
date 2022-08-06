import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

class CurrentLocation extends ChangeNotifier {
  //buat google map controller
  GoogleMapController? controller;
  Location currentLocation = Location();
  Set<Marker> markers = {};
  //void
  void getCurrentLoc() async {
    var location = await currentLocation.getLocation();
    currentLocation.onLocationChanged.listen((LocationData loc) {
      controller?.animateCamera(
        CameraUpdate.newCameraPosition(
          new CameraPosition(
              target: LatLng(loc.latitude ?? 0.0, loc.longitude ?? 0.0),
              zoom: 12.0),
        ),
      );
      print(loc.latitude);
      print(loc.longitude);
      // var currentLoc = markers.add(Marker(
      //     markerId: MarkerId('Home'),
      //     position: LatLng(loc.latitude ?? 0.0, loc.longitude ?? 0.0)));
      markers.add(Marker(
          markerId: MarkerId('Home'),
          position: LatLng(loc.latitude ?? 0.0, loc.longitude ?? 00)));
      // setState(() {
      //   markers.add(Marker(
      //       markerId: MarkerId('Home'),
      //       position: LatLng(loc.latitude ?? 0.0, loc.longitude ?? 00)));
      // });
    });
    notifyListeners();
  }
}
