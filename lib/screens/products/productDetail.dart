import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
class ProductDetail extends StatefulWidget {
  static String id = "product_detail";
  String docid, category, name, price, old_price, photo, filename;
  ProductDetail({this.docid, this.category, this.name, this.price, this.old_price, this.photo, this.filename});
  @override
  _ProductDetailState createState() => _ProductDetailState(docid, category, name, price, old_price, photo, filename);
}
class _ProductDetailState extends State<ProductDetail> {
  String docid, category, category_name, name, price, old_price, photo, filename, new_photo;
  _ProductDetailState(this.docid, this.category, this.name, this.price, this.old_price, this.photo, this.filename);
  double rating = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCategoryName(category);
    _getRating(docid);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Product detail"),
        centerTitle: true,
        elevation: 5.0,
      ),
      body: Container(
        color: Colors.blueAccent,
        child: Column(
          children: <Widget>[
            Image.network(photo),
            _RatingStar(),
            _categoryName(),
            _foodName(),
            _price(),
          ],
        ),
      ),
    );
  }
  Widget _RatingStar(){
    return Container(
      constraints: BoxConstraints(minWidth: double.infinity),
      color: Colors.white70,
      height: 100.0,
      alignment: Alignment.center,
      child: SmoothStarRating(
          allowHalfRating: false,
          onRatingChanged: (v) {
            rating = v;
            Firestore.instance.collection('foods').document(docid).updateData({
              'rate' : v,
            });
            setState(() { });
          },
          starCount: 5,
          rating: rating != null? rating : 1,
          size: 40.0,
          filledIconData: Icons.star,
          halfFilledIconData: Icons.star_border,
          color: Colors.blue,
          borderColor: Colors.blue,
          spacing:0.0
      ),
    );
  }
  Widget _categoryName(){
    return Container(
      color: Colors.deepOrange,
      height: 50.0,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(category_name != null? category_name: '', style: TextStyle(fontSize: 30.0, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
      ),
    );
  }
  Widget _foodName(){
    return Container(
      color: Colors.orangeAccent,
      height: 100.0,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(name, style: TextStyle(fontSize: 40.0, color: Colors.orange[900], fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
      ),
    );
  }
  Widget _price(){
    return Expanded(
      child: Container(
        color: Colors.deepOrange,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("$price kip", style: TextStyle(fontSize: 70.0, color: Colors.white, fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
            Text("$old_price kip", style: TextStyle(fontSize: 40.0, color: Colors.white, decoration: TextDecoration.lineThrough),textAlign: TextAlign.center,),
          ],
        ),
      ),
    );
  }
  void _getCategoryName(String docid) {
    Firestore.instance.collection('categories').document(docid).snapshots().listen((dsn){
      setState(() {
        category_name = dsn.data['name'];
      });
    });
  }
  void _getRating(String docid){
    Firestore.instance.collection('foods').document(docid).snapshots().listen((dsn){
      setState(() {
        rating = dsn.data['rate'];
      });
    });
  }
}
