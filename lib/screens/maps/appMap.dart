import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AppMap extends StatefulWidget {
  static String id = "map_screen";
  @override
  _AppMapState createState() => _AppMapState();
}

class _AppMapState extends State<AppMap> {
  Completer<GoogleMapController> _controller = Completer();
  MapType _currentMapType = MapType.normal;
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(17.9757, 102.6331),
    zoom: 14.4746,
  );
  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414,
  );
  GoogleMapController mapController;
  String searchAddr;
  final Set<Marker> markers = {};
  static final LatLng _center = LatLng(17.9757, 102.6331);

  LatLng _lastPosition = _center;
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
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 14.0,
            ),
            onMapCreated: (GoogleMapController controller){
              _controller.complete(controller);
            },
            markers: markers,
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
            padding: EdgeInsets.only(left: 340.0, top: 100.0),
            child: Column(
              children: <Widget>[
                buttonMap(_onMapTypeButtonPressed, Icons.map, 'buttonMapType'),
                SizedBox(height: 16.0,),
                buttonMap(_onMarkerButtonPressed, Icons.add_location, "buttonAddLocation"),
              ],
            ),
          ),
        ],
      ),
    );
  }
  onMapCreated(controller) {
    setState(() {
      mapController = controller;
    });
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

  Widget buttonMap(Function function, IconData icon, String tag){
    return FloatingActionButton(
      heroTag: Key(tag),
      onPressed: function,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      backgroundColor: Colors.blue,
      child: Icon(
        icon, size: 36.0,
      ),
    );
  }

  void _onMapTypeButtonPressed(){
    setState(() {
      _currentMapType = _currentMapType == MapType.normal? MapType.satellite : MapType.normal;
    });
  }

  void _onMarkerButtonPressed(){
    setState(() {
      markers.add(Marker(
        markerId: MarkerId(_lastPosition.toString()),
        position: _lastPosition,
        draggable: true,
        infoWindow: InfoWindow(
          title: 'This is a Title',
          snippet: 'This is a snippet',
        ),
        icon: BitmapDescriptor.defaultMarker,
      ));
    });
  }

  _onCameraMove(CameraPosition position){
    _lastPosition = position.target;
  }
}
