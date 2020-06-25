import 'package:demoappfirebase/models/food.dart';
import 'package:demoappfirebase/screens/categories/addcategory.dart';
import 'package:demoappfirebase/screens/categories/category.dart';
import 'package:demoappfirebase/screens/categories/editCategory.dart';
import 'package:demoappfirebase/screens/maps/appMap.dart';
import 'package:demoappfirebase/screens/maps/dropMarker.dart';
import 'package:demoappfirebase/screens/maps/geolocation.dart';
import 'package:demoappfirebase/screens/maps/mapPolygon.dart';
import 'package:demoappfirebase/screens/products/addProduct.dart';
import 'package:demoappfirebase/screens/products/editProduct.dart';
import 'package:demoappfirebase/screens/products/productDetail.dart';
import 'package:demoappfirebase/screens/resetpwd.dart';
import 'package:demoappfirebase/screens/signup.dart';
import 'package:demoappfirebase/screens/todotasks/addtask.dart';
import 'package:demoappfirebase/screens/todotasks/edittask.dart';
import 'package:demoappfirebase/screens/todotasks/todoHome.dart';
import 'package:flutter/material.dart';
import 'models/user.dart';
import 'screens/home.dart';
import 'screens/login.dart';
import 'screens/products/product.dart';
import 'screens/postcomments/post.dart';
import 'screens/postcomments/comment.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  var user = User();
  var logedUser = null;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: Login.id ,
      routes: {
        Login.id : (context) => Login(),
        Home.id : (context) => Home(),
        Signup.id : (context) => Signup(),
        ResetPassword.id : (context) => ResetPassword(),
        TodoHome.id : (context) => TodoHome(),
        AddTask.id : (context) => AddTask(),
        Category.id : (context) => Category(),
        AddCategory.id : (context) => AddCategory(),
        EditCategory.id : (context) => EditCategory(),
        Product.id : (context) => Product(),
        AddProduct.id : (context) => AddProduct(),
        EditProduct.id : (context) => EditProduct(),
        ProductDetail.id : (context) => ProductDetail(),
        AppMap.id : (context) => AppMap(),
        GeoLocation.id : (context) => GeoLocation(),
        MapPolygon.id : (context) => MapPolygon(),
        DropMarker.id : (context) => DropMarker(),
        Post.id : (context) => Post(),
        Comment.id : (context) => Comment(),
      },
    );
  }
}
