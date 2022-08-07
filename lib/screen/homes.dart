import 'package:flutter/material.dart';
import 'package:google_maps_widget/google_maps_widget.dart';

class Homes extends StatefulWidget {
  const Homes({Key? key}) : super(key: key);

  @override
  State<Homes> createState() => _HomesState();
}

class _HomesState extends State<Homes> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: GoogleMapsWidget(
        apiKey: "AIzaSyDRWrgaEZQBpmraYXwbH2DNSzNpsTgnyZw",
        sourceLatLng: LatLng(-6.8897148, 107.6056363),
        destinationLatLng: LatLng(-6.9024589, 107.6165074),

        ///////////////////////////////////////////////////////
        //////////////    OPTIONAL PARAMETERS    //////////////
        ///////////////////////////////////////////////////////

        routeWidth: 2,
        sourceMarkerIconInfo: MarkerIconInfo(
          assetPath: "assets/icons/home.png",
        ),
        destinationMarkerIconInfo: MarkerIconInfo(
          assetPath: "assets/icons/restaurant.png",
        ),
        driverMarkerIconInfo: MarkerIconInfo(
          assetPath: "assets/icons/motorcycle.png",
          assetMarkerSize: Size.square(125),
          rotation: 90,
        ),
        updatePolylinesOnDriverLocUpdate: true,
        // mock stream
        driverCoordinatesStream: Stream.periodic(
          Duration(milliseconds: 500),
          (i) => LatLng(
            -6.8897148 + i / 10000,
            107.6056363 - i / 10000,
          ),
        ),
        sourceName: "This is source name",
        driverName: "Alex",
        onTapDriverMarker: (currentLocation) {
          print("Driver is currently at $currentLocation");
        },
        totalTimeCallback: (time) => print(time),
        totalDistanceCallback: (distance) => print(distance),
      ),
    );
  }
}
