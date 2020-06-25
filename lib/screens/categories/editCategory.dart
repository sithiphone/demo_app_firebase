import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class EditCategory extends StatefulWidget {
  static String id = "edit_category_screen";
  String docid;
  String category;
  EditCategory({this.docid, this.category});
  @override
  _EditCategoryState createState() => _EditCategoryState(docid, category);
}

class _EditCategoryState extends State<EditCategory> {
  String docid;
  String category;
  TextEditingController categoryController = TextEditingController();
  Firestore firestore = Firestore.instance;

  _EditCategoryState(this.docid, this.category);

  @override
  void initState() {
    super.initState();
    categoryController = TextEditingController(text: category);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit category"),
        centerTitle: true,
        elevation: 5.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check_circle, color: Colors.white, size: 30.0,),
            onPressed: (){
              updateCategory();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: TextField(
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25.0),
              controller: categoryController,
              onChanged: (value){
                category = value;
              },
            ),
          ),
        ),
      ),
    );
  }

  void updateCategory() async{
    await firestore.collection('categories').document(docid).updateData({
      'name' : category,
    }).then((v){
      Navigator.pop(context);
    });
  }
}
