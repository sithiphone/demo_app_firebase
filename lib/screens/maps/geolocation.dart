import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;

class GeoLocation extends StatefulWidget {
  static String id = "geo_location_screen";
  @override
  _GeoLocationState createState() => _GeoLocationState();
}

class _GeoLocationState extends State<GeoLocation> {
  Completer<GoogleMapController> _controller = Completer();
//  static final LatLng _center = const LatLng(17.9757, 102.6331);
//  static final LatLng _destination = const LatLng(18.9501, 102.4438);
  static final LatLng _center = const LatLng(17.989727, 102.535007);
  static final LatLng _destination = const LatLng(17.939212, 102.626183);
  static final GoogleAPIKey = "AIzaSyBcuY4NSVBe1M4kWyTVlyT_v8IQr-h2lao";
  GoogleMapController mapController;
  String searchAddr;

  final Set<Marker> _markers = {};
  LatLng _lastMapPosition = _center;
  MapType _currentMapType = MapType.normal;

  static final CameraPosition _position1 = CameraPosition(
    bearing: 192.833,
    target: LatLng(13.7563, 100.5018),
    tilt: 59.440,
    zoom: 11.0,
  );

  Set<Marker> _markerPolyline = {};
  Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;
  @override
  void initState() {
    super.initState();
    setSourceAndDestinationIcons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Map"),
        centerTitle: true,
        elevation: 5.0,
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            mapType: _currentMapType,
            myLocationEnabled: true,
            compassEnabled: true,
            tiltGesturesEnabled: false,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 11.0
            ),
            onMapCreated: _onMapCreated,
            markers: _markerPolyline,
            polylines: _polylines,
            onCameraMove: _onCameraMove,
          ),
          Positioned(
            top: 30.0,
            right: 15.0,
            left: 15.0,
            child: Container(
              height: 50.0,
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Enter address',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(left: 15.0, top: 15.0),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: (){
                      searchAndNavigate();
                    },
                    iconSize: 30.0,
                  ),
                ),
                onChanged: (value){
                  setState(() {
                    searchAddr = value;
                  });
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 350.0, top: 100.0),
            child: Column(
              children: <Widget>[
                button(_onMapTypeButtonPressed, Icons.map, "mapButton"),
                SizedBox(height: 16.0,),
                button(_onAddMarkerButtonPressed, Icons.add_location, "locationButton"),
                SizedBox(height: 16.0,),
                button(_goToPosition, Icons.location_searching, "movePosition"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _onMapTypeButtonPressed(){
    setState(() {
      _currentMapType = _currentMapType == MapType.normal ? MapType.satellite : MapType.normal;
    });
  }
  _onAddMarkerButtonPressed(){
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId(_lastMapPosition.toString()),
        position: _lastMapPosition,
        infoWindow: InfoWindow(
          title: 'This is a Title',
          snippet: 'This is a snippet',
        ),
        icon: BitmapDescriptor.defaultMarker,
      ));
    });
  }
  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    setMapPins();
    setPolylines();
  }
  _onCameraMove(CameraPosition position){
    _lastMapPosition = position.target;
  }
  Widget button(Function function, IconData icon, String tag){
    return FloatingActionButton(
      heroTag: Key(tag),
      onPressed: function,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      backgroundColor: Colors.blue,
      child: Icon(
        icon,
        size: 36.0,
      ),
    );
  }

  void searchAndNavigate() async{
    final GoogleMapController controller = await _controller.future;
    Geolocator().placemarkFromAddress(searchAddr).then((result){
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(result[0].position.latitude, result[0].position.longitude),
        zoom: 14.0,
      )));
    });
  }

  Future<void> _goToPosition() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_position1));
  }

  void setSourceAndDestinationIcons() async{
    final Uint8List sourceIconByte = await getBytesFromAsset('assets/driving_pin.png', 50);
    final Uint8List destinationIconByte = await getBytesFromAsset('assets/destination_map_marker.png', 80);
    sourceIcon = await BitmapDescriptor.fromBytes(sourceIconByte);
    destinationIcon = await BitmapDescriptor.fromBytes(destinationIconByte);
  }

  void setMapPins(){
    setState(() {
      _markerPolyline.add(Marker(
        markerId: MarkerId('sourcePin'),
        position: _center,
        icon: sourceIcon,
      ));
      _markerPolyline.add(Marker(
        markerId: MarkerId('destinationPin'),
        position: _destination,
        icon: destinationIcon,
      ));
    });
  }

  setPolylines() async {
    List<PointLatLng> result = await polylinePoints?.getRouteBetweenCoordinates(
        GoogleAPIKey,
        _center.latitude,
        _center.longitude,
        _destination.latitude,
        _destination.longitude,
    );
    if(result.isNotEmpty){
      result.forEach((PointLatLng point){
        polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        );
      });

      setState(() {
        Polyline polyline = Polyline(
          polylineId: PolylineId('Poly'),
          color: Colors.blueAccent,
          points: polylineCoordinates,
        );
        _polylines.add(polyline);
      });
    }
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png)).buffer.asUint8List();
  }
}
