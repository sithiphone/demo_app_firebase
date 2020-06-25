import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demoappfirebase/screens/products/addProduct.dart';
import 'package:demoappfirebase/screens/products/editProduct.dart';
import 'package:demoappfirebase/screens/products/productDetail.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../AppDrawer.dart';

class Product extends StatefulWidget {
  static String id = "product_screen";
  @override
  _ProductState createState() => _ProductState();
}
enum ConfirmDelete {CANCEL, OK}
class _ProductState extends State<Product> {
  Firestore firestore = Firestore.instance;
  Map<String, String> food = Map<String, String>();
  List<Map> foods = List<Map>();

  @override
  void initState() {
    getProducts();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Food catalog"),
        centerTitle: true,
        elevation: 5.0,
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: GridView.builder(
              itemCount: foods.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemBuilder: (context, int index){
                  String foodid = foods[index]['docid'];
                  String name = foods[index]['name'];
                  String price = foods[index]['price'];
                  String old_price = foods[index]['old_price'];
                  String photo = foods[index]['photo'];
                  String filename = foods[index]['file_name'];
                  String category = foods[index]['category'];
                return Card(
                  child: Hero(
                    tag: foodid,
                    child: Material(
                      child: InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return ProductDetail(docid: foodid, category: category, name: name, price: price, old_price: old_price, photo: photo, filename: filename);
                          }));
                        },
                        child: GridTile(
                          header: Container(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              child: Icon(Icons.edit, color: Colors.green,),
                              onTap: (){
                                Navigator.push(context,
                                    MaterialPageRoute(
                                        builder: (context)=>
                                            EditProduct(docid: foodid,category: category, name: name, price: price, old_price: old_price, photo: photo, filename: filename)));
                              },
                            ),
                          ),
                          footer: Container(
                            color: Colors.black38,
                            child: ListTile(
//                              leading: Text(foods[index]['name'], style: TextStyle(fontWeight: FontWeight.bold),),
                            trailing: InkWell(
                              child: Icon(Icons.delete_forever, color: Colors.red,),
                              onTap: (){
                                _asyncComfirmDeleteDialog(context, foodid, filename);
                              },
                            ),
                              title: Text(price + " Kip", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),),
//                              subtitle: old_price != null ? Text(old_price + " Kip", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, decoration: TextDecoration.lineThrough),) : null,
                              subtitle: name != null ? Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),) : null,
                            ),
                          ),
                          child: Image.network(foods[index]['photo'], fit: BoxFit.cover,),
                        ),
                      ),
                    ),
                  ),
                );
              },
          ),
        ),
      ),
      drawer: AppDrawer(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add_circle, size: 50.0,),
        onPressed: (){
          Navigator.pushNamed(context, AddProduct.id);
        },
      ),
    );
  }

  Future getProducts() async{
    await firestore.collection('foods').orderBy('created_at', descending: false).snapshots().forEach((data){
      foods.clear();
      data.documents.forEach((doc){
        print(doc['name']);
        food = {
          'docid' : doc.documentID,
          'name' : doc['name'],
          'photo' : doc['photo'],
          'file_name' : doc['file_name'],
          'price' : doc['price'],
          'old_price' : doc['old_price'],
          'category' : doc['category'],
          'created_at' : doc['created_at'].toString(),
        };
        setState(() {
          foods.add(food);
        });
      });
    });
  }
  Future<ConfirmDelete> _asyncComfirmDeleteDialog(BuildContext context, String docid, String file_name) async {
    return showDialog<ConfirmDelete>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0)
          ),
          title: Text('Delete confirmation!'),
          content: const Text(
              'Are you sure to delete this food item?'),
          actions: <Widget>[
            FlatButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop(ConfirmDelete.CANCEL);
                setState(() {});
              },
            ),
            FlatButton(
              child: const Text('OK'),
              onPressed: () {
                firestore.collection('foods').document(docid).delete().then((msg){
                  setState(() {
                    foods.remove(docid);
                  });
                });

                FirebaseStorage.instance.ref().child(file_name).delete();
                Navigator.of(context).pop(ConfirmDelete.OK);
              },
            )
          ],
        );
      },
    );
  }
}
