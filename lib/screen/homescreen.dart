import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inginhealing/service/location_search_service.dart';

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
  Set<Marker> _markers = Set<Marker>();
  Set<Polygon> _polygons = Set<Polygon>();
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polygonLatLngs = <LatLng>[];

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
      appBar: AppBar(),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    TextField(
                      controller: _originController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(hintText: 'Dari mana ?'),
                    ),
                    TextField(
                      controller: _destinationController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(hintText: 'Mau kemana ?'),
                    ),
                  ],
                ),
              ),
              IconButton(
                  onPressed: () async {
                    var directions =
                        await LocationSearchService().getDirections(
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
//                   onPressed: () async {
//                     // LocationSearchService().getDirections(
//                     //     _originController.text, _destinationController.text);
//                      var directions = await LocationSearchService().getDirections(
//                     _originController.text,
//                     _destinationController.text,
//                   );
//                         _goToPlace(directions['start_location']['lat'], directions['start_location']['lng'])
//  _setPolyline(directions['polyline_decoded']);
//                     // var place = await LocationSearchService()
//                     //     .getPlace(_searchController.text);
//                     // _goToPlace(place);
//                   },
                  icon: Icon(Icons.search))
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
    // final double lat = place['geometry']['location']['lat'];
    // final double lng = place['geometry']['location']['lng'];

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
    _setMarker(LatLng(lat, lng));
  }
}
