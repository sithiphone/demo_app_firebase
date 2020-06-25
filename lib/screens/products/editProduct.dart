import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'dart:math' as Math;
import 'package:image/image.dart' as Img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class EditProduct extends StatefulWidget {
  static String id = "edit_screen";
  String docid, category, name, price, old_price, photo, filename;
  EditProduct({this.docid, this.category, this.name, this.price, this.old_price, this.photo, this.filename});
  @override
  _EditProductState createState() => _EditProductState(docid, category, name, price, old_price, photo, filename);
}

class _EditProductState extends State<EditProduct> {
  String docid, category, name, price, old_price, photo, filename, new_photo;
  _EditProductState(this.docid, this.category, this.name, this.price, this.old_price, this.photo, this.filename);
  bool _isLoading = false;
  File _image;
  String _currentSelected;
  Firestore firestore = Firestore.instance;
  Map<String, String> cat = new Map<String, String>();
  List<Map> categories = List<Map>();
  TextEditingController nameController, priceController, oldPriceController;
  @override
  void initState() {
    super.initState();
    _currentSelected = category;
    nameController = TextEditingController(text: name);
    priceController = TextEditingController(text: price);
    oldPriceController = TextEditingController(text: old_price);
    _getCategory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit food"),
        centerTitle: true,
        elevation: 5.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check_circle, color: Colors.white,size: 30.0,),
            onPressed: () async {
              _updateProduct(context);
            },
          ),
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
                  _image != null ? _selectedImage() : _imageFood(),
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
  Widget _imageFood(){
    return Stack(
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          height: 300.0,
          child: Image.network(photo),
        ),
        InkWell(
          child: Container(
            margin: EdgeInsets.fromLTRB(310.0, 210.0, 0.0, 0.0),
            child: Icon(Icons.add_circle, color: Colors.green,size: 60.0,),
          ),
          onTap: (){
            _getFile();
          },
        ),
      ],
    );
  }
  Widget _selectedImage(){
    return Stack(
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          height: 300.0,
          child: Image.file(_image),
        ),
        InkWell(
          child: Container(
            margin: EdgeInsets.fromLTRB(310.0, 210.0, 0.0, 0.0),
            child: Icon(Icons.add_circle, color: Colors.red,size: 60.0,),
          ),
          onTap: (){
            _getFile();
          },
        ),
      ],
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
        controller: nameController,
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
        controller: priceController,
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
        controller: oldPriceController,
      ),
    );
  }
  Future _getFile() async{
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
      new_photo = basename(_image.path);
    });
  }
  Future _getCategory() async {
    Future<QuerySnapshot> querySnapshot = firestore.collection('categories').getDocuments();
    querySnapshot.then((data){
      data.documents.forEach((val){
        cat = {
          'display' : val['name'],
          'value' : val.documentID,
        };
        setState(() {
          categories.add(cat);
        });
      });
    });
  }
  resizeAndUpdateImageToFirestorage(File file, String new_photo) async{
    final StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(filename);
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    int rand = new Math.Random().nextInt(100000);
    Img.Image image = Img.decodeImage(file.readAsBytesSync());
    Img.Image smallerImage = Img.copyResize(image, height: 300);
    var compressedImage = new File('$path/img_$rand.jpg')..writeAsBytesSync(Img.encodeJpg(smallerImage, quality: 85));
    new_photo != filename ? FirebaseStorage.instance.ref().child(new_photo).delete() : null;
    final StorageUploadTask task = firebaseStorageRef.putFile(compressedImage);
    var url = await(await task.onComplete).ref.getDownloadURL();
    String photoUrl = url.toString();
    return photoUrl;
  }

  Future _updateProduct(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    if(_image != null){
      String photoUrl = await resizeAndUpdateImageToFirestorage(_image, new_photo);
      firestore.collection('foods').document(docid).updateData({
        'name' : name,
        'price' : price,
        'old_price' : old_price,
        'category' : category,
        'photo' : photoUrl,
        'file_name' : filename,
      }).then((v){
        setState(() {
          _isLoading = false;
        });
        Navigator.pop(context);
      });
    }else{
      firestore.collection('foods').document(docid).updateData({
        'name' : name,
        'price' : price,
        'old_price' : old_price,
        'category' : category,
      }).then((v){
        setState(() {
          _isLoading = false;
        });
        Navigator.pop(context);
      });
    }
    setState(() {
      _isLoading = false;
    });
  }
}
