import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class ServiceLocation with ChangeNotifier {
  String location = 'Loading..';
  String Address = 'Loading..';
  String myAddress = 'Loading..';
  String city = 'Loading..';
  String myCity = 'Loading..';
  double locationLat = 55.0111;
  double locationLong = 15.0569;

  // String? location;
  // String? Address;

  //action
  Future<Position> getGeolocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      await Geolocator.openAppSettings();
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> GetAddressFromLatLong(Position position) async {
    List<Placemark> placemarks = await GeocodingPlatform.instance
        .placemarkFromCoordinates(position.latitude, position.longitude,
            localeIdentifier: "en");
    print(placemarks);
    Placemark place = placemarks[0];
    Address =
        '${place.locality}, ${place.subAdministrativeArea}, ${place.country}';
    city = '${place.subAdministrativeArea}';
  }

  void getLocation() async {
    Position position = await getGeolocationPosition();
    location = 'Lat: ${position.latitude} , Long: ${position.longitude}';
    myAddress = Address;
    locationLat = position.latitude;
    locationLong = position.longitude;
    print('loclat');
    print(locationLat);
    print('loclong');
    print(locationLong);
    GetAddressFromLatLong(position).then((value) {
      myAddress = Address;
      myCity = city;
    });
    notifyListeners();
  }
}
