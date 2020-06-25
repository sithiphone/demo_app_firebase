import 'package:demoappfirebase/screens/home.dart';
import 'package:demoappfirebase/screens/maps/appMap.dart';
import 'package:demoappfirebase/screens/maps/dropMarker.dart';
import 'package:demoappfirebase/screens/maps/geolocation.dart';
import 'package:demoappfirebase/screens/maps/mapPolygon.dart';
import 'package:demoappfirebase/screens/postcomments/post.dart';
import 'package:demoappfirebase/screens/products/product.dart';
import 'package:demoappfirebase/screens/todotasks/todoHome.dart';
import 'package:flutter/material.dart';

import 'categories/category.dart';

class AppDrawer extends StatelessWidget {

  Widget _createDrawerItem(IconData icon, String text, GestureTapCallback onTap){
    return ListTile(
      title: Row(
        children: <Widget>[
          Icon(icon),
          Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(text),
          ),
        ],
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            padding: EdgeInsets.all(0.0),
            margin: EdgeInsets.all(0.0),
            child: Column(
              children: <Widget>[
                UserAccountsDrawerHeader(
                  accountName: Text("Sithiphone PHANDALA"),
                  accountEmail: Text("sithiphone@nuol.edu.la"),
                  margin: EdgeInsets.all(0.0),
                  currentAccountPicture: CircleAvatar(
                    radius: 50.0,
                    backgroundImage: AssetImage('assets/user.png'),
                    backgroundColor: Colors.brown,
                  ),
                ),
              ],
            ),
          ),
          _createDrawerItem(Icons.home, "Home",
                  ()=>Navigator.pushNamed(context, Home.id)),
          _createDrawerItem(Icons.playlist_add_check, "Todo tasks",
              ()=>Navigator.pushNamed(context, TodoHome.id)),
          _createDrawerItem(Icons.category, "Categories",
              ()=>Navigator.pushNamed(context, Category.id)),
          _createDrawerItem(Icons.fastfood, "Foods",
              ()=>Navigator.pushNamed(context, Product.id)),
          _createDrawerItem(Icons.my_location, "Map search",
                  ()=>Navigator.pushNamed(context, AppMap.id)),
          _createDrawerItem(Icons.my_location, "Map Location",
                  ()=>Navigator.pushNamed(context, GeoLocation.id)),
          _createDrawerItem(Icons.open_with, "Map Polygon",
                  ()=>Navigator.pushNamed(context, MapPolygon.id)),
          _createDrawerItem(Icons.pin_drop, "Map droping marker",
                  ()=>Navigator.pushNamed(context, DropMarker.id)),
          _createDrawerItem(Icons.comment, "Comment",
                  ()=>Navigator.pushNamed(context, Post.id)),
          ListTile(
            title: Text('0.0.1'),
            onTap: (){},
          ),
        ],
      ),
    );
  }
}
