import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demoappfirebase/models/categoryModel.dart';
import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math' as Math;
import 'package:image/image.dart' as Img;

class AddProduct extends StatefulWidget {
  static String id = "add_product_screen";
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  Firestore firestore = Firestore.instance;
  Map<String, String> category = new Map<String, String>();
  List<Map> categories = List<Map>();
  String _currentSelected;
  String name;
  String price;
  String old_price;
  String filename;
  File _image;
  bool _isLoading = false;
  @override
  void initState() {
    _getCategory();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add food"),
        centerTitle: true,
        elevation: 5.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add_circle, color: Colors.white, size: 40.0,),
            onPressed: () async {
              _addProduct(context);
            },
          )
        ],
      ),
      body: SafeArea(
        child: ModalProgressHUD(
          inAsyncCall: _isLoading,
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _image != null? Container(
                    height: 300.0,
                    child: Image.file(_image),
                  ) :_imageFood(),
                  _categoryDropdown(),
                  _textFieldName(),
                  _textFieldPrice(),
                  _textFieldOldPrice(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _imageFood(){
    return Stack(
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          height: 300.0,
          child: Image.asset('assets/food.png'),
        ),
        InkWell(
          child: Container(
            margin: EdgeInsets.fromLTRB(210.0, 210.0, 0.0, 0.0),
            child: Icon(Icons.add_circle, color: Colors.white,size: 60.0,),
          ),
          onTap: (){
            _getFile();
          },
        ),
      ],
    );
  }
  Future _getCategory() async {
    Future<QuerySnapshot> querySnapshot = firestore.collection('categories').getDocuments();
    querySnapshot.then((data){
      data.documents.forEach((val){
        category = {
          'display' : val['name'],
          'value' : val.documentID,
        };
        setState(() {
          categories.add(category);
        });
      });
    });
  }
  Widget _categoryDropdown() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: DropDownFormField(

        titleText: 'Food category',
        hintText: 'Please choose one',
        value: _currentSelected,
        onChanged: (value){
          setState(() {
            _currentSelected = value;
          });
        },
        onSaved: (value){
          setState(() {
            _currentSelected = value;
          });
        },
        dataSource: categories,
        textField: 'display',
        valueField: 'value',
      ),
    );
  }
  Widget _textFieldName(){
    return Container(
      padding: EdgeInsets.all(16.0),
      child: TextField(
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          hintText: 'Product name'
        ),
        onChanged: (value){
          name = value;
        },
      ),
    );
  }
  Widget _textFieldPrice(){
    return Container(
      padding: EdgeInsets.all(16.0),
      child: TextField(
        onChanged: (value){
          price = value;
        },
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: 'Price'
        ),
      ),
    );
  }
  Widget _textFieldOldPrice(){
    return Container(
      padding: EdgeInsets.all(16.0),
      child: TextField(
        onChanged: (value){
          old_price = value;
        },
        decoration: InputDecoration(
          hintText: 'Old price'
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }

  Future _getFile() async{
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
      filename = basename(_image.path);
    });
  }
  resizeAndUploadImageToFirestorage(File file) async{
    final StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(filename);
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    int rand = new Math.Random().nextInt(100000);
    Img.Image image = Img.decodeImage(file.readAsBytesSync());
    Img.Image smallerImage = Img.copyResize(image, height: 300);
    var compressedImage = new File('$path/img_$rand.jpg')..writeAsBytesSync(Img.encodeJpg(smallerImage, quality: 85));
    final StorageUploadTask task = firebaseStorageRef.putFile(compressedImage);
    var url = await(await task.onComplete).ref.getDownloadURL();
    String photoUrl = url.toString();
    return photoUrl;
  }
  Future _addProduct(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    String photoUrl = await resizeAndUploadImageToFirestorage(_image);
    firestore.collection('foods').add({
      'category': _currentSelected,
      'name' : name,
      'price' : price,
      'old_price' : old_price,
      'photo' : photoUrl,
      'file_name' : filename,
      'created_at' : Timestamp.now(),
    }).then((v){
      setState(() {
        _isLoading = false;
      });
      Navigator.pop(context);
    });
    setState(() {
      _isLoading = false;
    });
  }
}
