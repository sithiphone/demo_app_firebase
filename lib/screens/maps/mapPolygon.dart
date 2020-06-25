import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPolygon extends StatefulWidget {
  static String id = "map_polygon_screen";
  @override
  _MapPolygonState createState() => _MapPolygonState();
}

class _MapPolygonState extends State<MapPolygon> {
  Completer<GoogleMapController> _controller = Completer();
  static final LatLng _center = LatLng(17.939212, 102.626183);
  Set<Polygon> polygons = {};
  static List<LatLng> locations = [
    LatLng(17.938048,102.626322),
    LatLng(17.939465,102.626938),
    LatLng(17.940475,102.627056),
    LatLng(17.942027,102.627002),
    LatLng(17.941910,102.624360),
    LatLng(17.940961,102.623855),
    LatLng(17.941330,102.623240),
    LatLng(17.940828,102.622772),
    LatLng(17.940398,102.623396),
    LatLng(17.940276,102.623412),
    LatLng(17.939964,102.623976),
    LatLng(17.938676,102.623676),
  ];
  MapType _currentMapType = MapType.normal;
  String searchAddr;
  Polygon polygon = Polygon(
    polygonId: PolygonId('AppPolygon'),
    points: locations,
    fillColor: Colors.black54,
    strokeColor: Colors.deepOrange,
      strokeWidth: 2,
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    polygons.add(polygon);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Map polygon"),
        centerTitle: true,
        elevation: 5.0,
      ),
      body: Container(
        child: Stack(
          children: <Widget>[
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 16.0
              ),
              mapType: _currentMapType,
              polygons: polygons,
              onMapCreated: _onMapCreated,
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
                  button(_onTapMapType, Icons.map, "buttonMapType"),
                  SizedBox(height: 10.0,),
                  button(null, Icons.add_location, "buttonPin"),
                  SizedBox(height: 10.0,),
                  button(null, Icons.fullscreen, "buttonFocus"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _onTapMapType(){
    setState(() {
      _currentMapType = _currentMapType == MapType.normal? MapType.satellite : MapType.normal;
    });
  }
  _onMapCreated(GoogleMapController controller){
    _controller.complete(controller);
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
}
