import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demoappfirebase/models/user.dart';
import 'package:demoappfirebase/screens/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math' as Math;
import 'package:image/image.dart' as Img;

class Signup extends StatefulWidget {
  static String id = "signup_screen";
  Signup({Key key}): super(key : key);
  @override
  _SignupState createState() => _SignupState();
}
class _SignupState extends State<Signup> {
  File _image;
  String filename;
  bool _isLoading = false;
  FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController nameConttroller = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordContoller = TextEditingController();

  Future _getFile() async{
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
      filename = basename(_image.path);
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Up"),
        centerTitle: true,
        elevation: 5.0,
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              _image == null? _imagePicker() : InkWell(
                child: Center(
                  child: CircleAvatar(
                    backgroundImage: FileImage(_image),
                    radius: 50.0,
                  ),
                ),
              ),
              _buildTextFieldName(),
              _buildTextFieldEmail(),
              _buildTextFieldPassword(),
              _buildTextFieldConfirmPassword(),
              _buildButtonSignup(context),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildTextFieldName(){
    return Padding(
      padding: EdgeInsets.only(top: 30.0),
      child: TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Name',
          icon: Icon(
            Icons.people,
            color: Colors.grey,
          ),
        ),
        validator: (value) => value.isEmpty? 'Please enter name': null,
        controller: nameConttroller,
      ),
    );
  }
  Widget _buildTextFieldEmail(){
    return Padding(
      padding: EdgeInsets.only(top: 30.0),
      child: TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Email',
          icon: Icon(
            Icons.email,
            color: Colors.grey,
          ),
        ),
        validator: (value) => value.isEmpty? 'Please enter email': null,
        controller: emailController,
      ),
    );
  }
  Widget _buildTextFieldPassword(){
    return Padding(
      padding: EdgeInsets.only(top: 12),
      child: TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: InputDecoration(
          hintText: "Password",
          icon: Icon(
            Icons.lock,
            color: Colors.grey,
          ),
        ),
        validator: (value) => value.isEmpty ? 'Please enter password': null,
        controller: passwordController,
      ),
    );
  }
  Widget _buildTextFieldConfirmPassword(){
    return Padding(
      padding: EdgeInsets.only(top: 12),
      child: TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: InputDecoration(
          hintText: "Confirm password",
          icon: Icon(
            Icons.lock,
            color: Colors.grey,
          ),
        ),
        validator: (value) => value.isEmpty ? 'Please confirm your password': null,
        controller: confirmPasswordContoller,
      ),
    );

  }
  Widget _buildButtonSignup(BuildContext context){
    return Padding(
      padding: EdgeInsets.only(top: 16),
      child: SizedBox(
          height: 40,
          child: RaisedButton(
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)
              ),
              color: Colors.blue,
              child: Text("Register",
                style: TextStyle(fontSize: 20, color: Colors.white),),
              onPressed: (){
                signUp(context);
              })
      ),
    );
  }
  Widget _imagePicker(){
    return Center(
      child: InkWell(
        child: CircleAvatar(
          backgroundImage: AssetImage("assets/user.png"),
          radius: 50.0,
        ),
        onTap: _getFile,
      ),
    );
  }
  void signUp(BuildContext context) async {
    if(_formKey.currentState.validate()){
      _formKey.currentState.save();
      String name = nameConttroller.text.trim();
      String email = emailController.text.trim();
      String password = passwordController.text.trim();
      String confirmPassword = confirmPasswordContoller.text.trim();
      if(password == confirmPassword && password.length >= 6){
        String photoUrl = await resizeAndUploadImageToFirestorage(_image);
        FirebaseUser user = (await _auth.createUserWithEmailAndPassword(email: email, password: password).catchError((err){
          print(err.toString());
        })).user;
        await Firestore.instance.collection('users').add(
          {
            'userid' : user.uid,
            'name' : name,
            'email' : email,
            'photo': photoUrl,
            'photo_filename': filename,
          }
        );
        print("New user created successful.");

        Navigator.pushNamedAndRemoveUntil(context, '/home', ModalRoute.withName('/home'));
      }
    }else{
        print("Password not match or less then 6");
    }
  }
  resizeAndUploadImageToFirestorage(File file) async{
    final StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(filename);
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    int rand = new Math.Random().nextInt(100000);

    Img.Image image = Img.decodeImage(file.readAsBytesSync());
    Img.Image smallerImage = Img.copyResize(image, width: 224, height: 224);

    var compressedImage = new File('$path/img_$rand.jpg')..writeAsBytesSync(Img.encodeJpg(smallerImage, quality: 85));
    final StorageUploadTask task = firebaseStorageRef.putFile(compressedImage);
    var url = await(await task.onComplete).ref.getDownloadURL();
    String photoUrl = url.toString();
    return photoUrl;
  }
}
