import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddCategory extends StatefulWidget {
  static String id = "add_category_screen";
  @override
  _AddCategoryState createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  String category;
  Firestore firestore = Firestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add category"),
        centerTitle: true,
        elevation: 5.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add_circle, size: 30.0,),
            onPressed: (){
              addCategory();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: TextField(
              onChanged: (value){
                category = value;
              },
              keyboardType: TextInputType.text,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 30.0),
              decoration: InputDecoration(
                hintText: 'category',
              ),
            ),
          ),
        ),
      ),
    );
  }

  void addCategory() async {
    await firestore.collection('categories').add({
      'name' : category,
      'created_at' : Timestamp.now(),
    }).then((v){
      Navigator.pop(context);
    });
  }
}
