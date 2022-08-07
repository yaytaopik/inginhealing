import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inginhealing/service/location_search_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:inginhealing/widgets/button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'view_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Completer<GoogleMapController> _controller = Completer();
  TextEditingController _searchController = TextEditingController();
  TextEditingController _originController = TextEditingController();
  TextEditingController _destinationController = TextEditingController();
  TextEditingController _latsOrigin = TextEditingController();
  TextEditingController _lngsOrigin = TextEditingController();
  TextEditingController _latsDestination = TextEditingController();
  TextEditingController _lngsDestination = TextEditingController();
  Set<Marker> _markers = Set<Marker>();
  Set<Polygon> _polygons = Set<Polygon>();
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polygonLatLngs = <LatLng>[];
  bool showSaveButton = false;
  double latOrigin = 0.0;
  double lngOrigin = 0.0;
  double latDestination = 0.0;
  double lngDestination = 0.0;
  //firebase
  TextEditingController _judul = TextEditingController();
  TextEditingController _detail = TextEditingController();

  int _polygonIdCounter = 1;
  int _polyLineIdCounter = 1;

  static final CameraPosition _kbBinatang = CameraPosition(
    target: LatLng(-6.8897148, 107.6056363),
    zoom: 14.4746,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(-6.8897148, 107.6056363),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  static final Marker _kebunBinatang = Marker(
      markerId: MarkerId('_kebunBinatang'),
      infoWindow: InfoWindow(title: 'Kebun binatang'),
      icon: (BitmapDescriptor.defaultMarker),
      position: LatLng(-6.8897148, 107.6056363));

  static final Marker _alunAlun = Marker(
      markerId: MarkerId('_alunAlun'),
      infoWindow: InfoWindow(title: 'Alun alun'),
      icon: (BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)),
      position: LatLng(-6.9218518, 107.6027869));
//polyline
  static final Polyline _kPolyline = Polyline(
      polylineId: PolylineId('_kPolyline'),
      points: [
        LatLng(-6.8897148, 107.6056363),
        LatLng(-6.9218518, 107.6027869)
      ],
      width: 5,
      color: Colors.purple);

  //polygon
  static final Polygon _kPolygon = Polygon(
      polygonId: PolygonId('_kPolygon'),
      points: [
        LatLng(-6.8897148, 107.6056363),
        LatLng(-6.9218518, 107.6027869),
        LatLng(-6.8898, 107.606),
        LatLng(-6.9219, 107.603)
      ],
      strokeWidth: 5,
      fillColor: Colors.transparent);
  @override
  void initState() {
    // TODO: implement initState
    _setMarker(LatLng(6.8897148, 107.6056363));
  }

  void _setMarker(LatLng point) {
    setState(() {
      _markers.add(Marker(markerId: MarkerId('marker'), position: point));
    });
  }

  void _setPolygon(LatLng point) {
    final String polygonIdVal = 'polygon_$_polygonIdCounter';
    _polygonIdCounter++;

    _polygons.add(
      Polygon(
        polygonId: PolygonId(polygonIdVal),
        points: polygonLatLngs,
        strokeWidth: 2,
        fillColor: Colors.purpleAccent,
      ),
    );
  }

  void _setPolyline(List<PointLatLng> points) {
    final String polylineIdVal = 'polyline_$_polyLineIdCounter';
    _polyLineIdCounter++;
    _polylines.add(
      Polyline(
          polylineId: PolylineId(polylineIdVal),
          width: 2,
          color: Colors.purple,
          points: points
              .map(
                (point) => LatLng(point.latitude, point.longitude),
              )
              .toList()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text(
          'InginHealing',
          style:
              GoogleFonts.pacifico(fontStyle: FontStyle.normal, fontSize: 20),
        ),
        actions: <Widget>[
          TextButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ViewData()));
              },
              child: Text(
                'Lihat Data',
                style: TextStyle(color: Colors.white),
              )),
          showSaveButton
              ? TextButton(
                  onPressed: () {
                    showModalBottomSheet<void>(
                        isScrollControlled: true,
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            decoration: new BoxDecoration(
                                borderRadius: new BorderRadius.only(
                                    topLeft: const Radius.circular(25.0),
                                    topRight: const Radius.circular(25.0))),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: <Widget>[
                                  SizedBox(height: 60),
                                  Text(
                                    'Catat rencana healing',
                                    style: TextStyle(
                                        fontSize: 30, color: Colors.purple),
                                  ),
                                  SizedBox(height: 20),
                                  TextFormField(
                                    controller: _judul,
                                    style: TextStyle(color: Colors.black),
                                    obscureText: false,
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(Icons.title),
                                      labelText: 'Judul Healing',
                                      fillColor: Colors.grey,
                                      focusColor: Colors.grey,
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  TextFormField(
                                    controller: _detail,
                                    style: TextStyle(color: Colors.black),
                                    obscureText: false,
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(Icons.local_activity),
                                      labelText: 'Mau ngapain aja ?',
                                      fillColor: Colors.grey,
                                      focusColor: Colors.grey,
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  TextFormField(
                                    enabled: false,
                                    controller: _originController,
                                    style:
                                        TextStyle(color: Colors.grey.shade400),
                                    obscureText: false,
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(Icons.flight_takeoff),
                                      labelText: 'dari mana?',
                                      fillColor: Colors.grey,
                                      focusColor: Colors.grey,
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  TextFormField(
                                    enabled: false,
                                    controller: _destinationController,
                                    style:
                                        TextStyle(color: Colors.grey.shade400),
                                    obscureText: false,
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(Icons.flight_land),
                                      labelText: 'ke mana?',
                                      fillColor: Colors.grey,
                                      focusColor: Colors.grey,
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  SaveBtn(context, () async {
                                    WidgetsFlutterBinding.ensureInitialized();
                                    await Firebase.initializeApp();
                                    FirebaseFirestore.instance
                                        .collection("datahealing")
                                        .add({
                                      'darimana': _originController.text,
                                      'detail': _detail.text,
                                      'judul': _judul.text,
                                      'kemana': _destinationController.text,
                                      'origin': GeoPoint(latOrigin, lngOrigin),
                                      'destination': GeoPoint(
                                          latDestination, lngDestination),
                                    });
                                    Navigator.pop(context);
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Berhasil'),
                                            content:
                                                Text('Berhasil simpan data !'),
                                            actions: [
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text('OKE'))
                                            ],
                                          );
                                        });
                                    // .then((value) {
                                    //   print(value.id);
                                    //   showDialog(
                                    //       context: context,
                                    //       builder: (BuildContext context) {
                                    //         return AlertDialog(
                                    //           title: Text('Berhasil'),
                                    //           content: Text(
                                    //               'Berhasil simpan data !'),
                                    //           actions: [
                                    //             TextButton(
                                    //                 onPressed: () {
                                    //                   Navigator.pop(context);
                                    //                   Navigator.push(
                                    //                       context,
                                    //                       MaterialPageRoute(
                                    //                           builder: (context) =>
                                    //                               HomeScreen()));
                                    //                 },
                                    //                 child: Text('OKE'))
                                    //           ],
                                    //         );
                                    //       });
                                    //   Navigator.pop(context);
                                    // }).catchError((error) =>
                                    //         print("gagal simpan data $error"));
                                  }),
                                  cancelBtn(context, () {
                                    Navigator.pop(context);
                                  })
                                ],
                              ),
                            ),
                          );
                        });
                  },
                  child: Text(
                    'Simpan',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : Container(),
        ],
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: _originController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: 'Dari mana ?',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: _destinationController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: 'Mau kemana ?',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  var directions = await LocationSearchService().getDirections(
                    _originController.text,
                    _destinationController.text,
                  );
                  _goToPlace(
                    directions['start_location']['lat'],
                    directions['start_location']['lng'],
                    directions['bounds_ne'],
                    directions['bounds_sw'],
                  );

                  _setPolyline(directions['polyline_decoded']);
                },
                icon: Icon(Icons.search),
                tooltip: 'Cari lokasi',
              )
            ],
          ),
          Expanded(
            child: GoogleMap(
              mapType: MapType.normal,
              markers: {
                _kebunBinatang,
                _alunAlun,
              },
              polylines: _polylines,
              polygons: _polygons,
              initialCameraPosition: _kbBinatang,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              onTap: (point) {
                setState(() {
                  polygonLatLngs.add(point);
                  _setPolygon(point);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _goToPlace(
    // Map<String, dynamic> place,
    double lat,
    double lng,
    Map<String, dynamic> boundsNe,
    Map<String, dynamic> boundsSw,
  ) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 12),
      ),
    );

    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(boundsSw['lat'], boundsSw['lng']),
            northeast: LatLng(boundsNe['lat'], boundsNe['lng']),
          ),
          25),
    );
    setState(() {
      showSaveButton = true;
      latOrigin = boundsSw['lat'];
      lngOrigin = boundsSw['lng'];
      latDestination = boundsNe['lat'];
      lngDestination = boundsNe['lng'];
    });
    _setMarker(LatLng(lat, lng));
    print('Northeast');
    print(boundsNe['lat']);
    print('Southwest');
    print(boundsSw['lat']);
  }
}
