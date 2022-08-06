import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:inginhealing/service/current_location.dart';
import 'package:inginhealing/service/service_location.dart';
import 'package:inginhealing/widgets/home_bottomsheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _controller;
  bool isLoading = false;
  String? errorMessage;
  Location currentLocation = Location();
  Set<Marker> _markers = {};
  void getLocation() async {
    var location = await currentLocation.getLocation();
    currentLocation.onLocationChanged.listen((LocationData loc) {
      _controller
          ?.animateCamera(CameraUpdate.newCameraPosition(new CameraPosition(
        target: LatLng(loc.latitude ?? 0.0, loc.longitude ?? 0.0),
        zoom: 12.0,
      )));
      print(loc.latitude);
      print(loc.longitude);
      setState(() {
        _markers.add(Marker(
            markerId: MarkerId('Home'),
            position: LatLng(loc.latitude ?? 0.0, loc.longitude ?? 0.0)));
      });
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      getLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CurrentLocation>(
            create: (context) => CurrentLocation()),
        ChangeNotifierProvider<ServiceLocation>(
            create: (context) => ServiceLocation())
      ],
      child: Consumer<ServiceLocation>(
        builder: (context, sLocation, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text('InginHealing'),
              centerTitle: true,
            ),
            body: Stack(
              children: <Widget>[
                Consumer<CurrentLocation>(
                    builder: (context, myLocation, child) {
                  return Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                          target: LatLng(48.8561, 2.2930), zoom: 12.0),
                      onMapCreated: (GoogleMapController controller) {
                        // myLocation.controller = controller;
                        _controller = controller;
                      },
                      // markers: myLocation.markers,
                      markers: _markers,
                    ),
                  );
                }),
                //Scrollable bottom sheet
                DraggableScrollableSheet(
                    initialChildSize: 0.4,
                    minChildSize: 0.2,
                    maxChildSize: 0.6,
                    builder: (context, scrollController) {
                      return SingleChildScrollView(
                        controller: scrollController,
                        child: Container(
                          padding: EdgeInsets.all(8.0),
                          color: Colors.grey.shade200,
                          child: HomeBottomSheet(),
                        ),
                      );
                    })
              ],
            ),
          );
        },
      ),
    );
  }
}
