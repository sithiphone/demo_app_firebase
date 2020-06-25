import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DropMarker extends StatefulWidget {
  static String id = "droping_marker_screen";
  @override
  _DropMarketState createState() => _DropMarketState();
}

class _DropMarketState extends State<DropMarker> {
  Completer<GoogleMapController> _controller = Completer();
  LatLng _center = LatLng(17.9757, 102.6331);
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

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
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            compassEnabled: true,
            tiltGesturesEnabled: false,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 14.0,
            ),
            onMapCreated: (GoogleMapController controller){
              _controller.complete(controller);
            },
            markers: Set<Marker>.of(markers.values),
            onLongPress: (latlong){
              _addMarkerLongPressed(latlong);
            },
          ),
        ],
      ),
    );
  }

  Future _addMarkerLongPressed(LatLng latlong) {
    String markerRandomId = Random.secure().toString();
    setState(() {
      final MarkerId markerId = MarkerId(markerRandomId);
      Marker marker = Marker(
        markerId: markerId,
        draggable: true,
        position: latlong,
        infoWindow: InfoWindow(
          title: 'Marker here',
          snippet: 'This is snippet',
        ),
        icon: BitmapDescriptor.defaultMarker,
      );
      markers[markerId] = marker;
    });
  }
}
