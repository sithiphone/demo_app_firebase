import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demoappfirebase/models/user.dart';
import 'package:demoappfirebase/screens/home.dart';
import 'package:demoappfirebase/screens/resetpwd.dart';
import 'package:demoappfirebase/screens/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class Login extends StatefulWidget {
  static String id = "login_screen";
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User loggedUser = new User();
  bool _isLoading = false;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("Login demo", style: TextStyle(color: Colors.white),),
        centerTitle: true,
        elevation: 5.0,
      ),
      body: ModalProgressHUD(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              _logo(),
              _textFieldEmail(),
              _textFieldPassword(),
              _buttonSignIn(context),
              _buildLine("Do you have an account?"),
              _buttonRegister(context),
              _buildLine("Othor.."),
              _buttonForgotPassword(),
            ],
          ),
        ),
        inAsyncCall: _isLoading,
      ),
    );
  }

  Widget _logo(){
    return Hero(
      tag: Hero,
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
        child: CircleAvatar(
          backgroundColor: Colors.blue,
          radius: 50.0,
          child: Image.asset('assets/car-service.png'),
        ),
      ),
    );
  }

  Widget _textFieldEmail(){
    return Padding(
      padding: EdgeInsets.only(top: 30.0),
      child: TextFormField(
        maxLength: 80,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: InputDecoration(
          hintText: "Email",
          icon: Icon(Icons.mail, color: Colors.grey,)
        ),
        validator: (value) => value.isEmpty? 'Please enter email': null,
        controller: emailController,
      ),
    );
  }

  Widget _textFieldPassword(){
    return Padding(
      padding: EdgeInsets.only(top: 30.0),
      child: TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: InputDecoration(
            hintText: "Password",
            icon: Icon(Icons.mail, color: Colors.grey,)
        ),
        validator: (value) => value.isEmpty? 'Please enter password': null,
        controller: passwordController,
      ),
    );
  }

  Widget _buttonSignIn(BuildContext context){
    return Padding(
      padding: EdgeInsets.only(top: 16.0),
      child: RaisedButton(
        elevation: 5.0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0)
        ),
        color: Colors.blue,
        child: Text("Login",
          style: TextStyle(fontSize: 20.0, color: Colors.white),
        ),
        onPressed: (){
          signIn(context);
        },
    ),
    );
  }

  Widget _buildLine(String text){
    return Container(
      margin: EdgeInsets.only(top: 16.0),
      child: Row(
        children: <Widget>[
          Expanded(child: Divider(color: Colors.green[800],),),
          Padding(padding: EdgeInsets.all(6.0),
            child: Text(text, style: TextStyle(color: Colors.black87),),),
          Expanded(child: Divider(color: Colors.green[800],),),
        ],
      ),
    );
  }

  Widget _buttonRegister(BuildContext context){
    return Padding(
      padding: EdgeInsets.only(top: 16.0),
      child: RaisedButton(
        child: Text("Register", style: TextStyle(fontSize: 20.0, color: Colors.white),),
        color: Colors.blue,
        onPressed: (){
          Navigator.pushNamed(context, Signup.id);
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
    );
  }

  Widget _buttonForgotPassword(){
    return Padding(
      padding: EdgeInsets.only(top: 16.0),
      child: RaisedButton(
        child: Text('Forgot password', style: TextStyle(fontSize: 20.0, color: Colors.white),),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0)
        ),
        color: Colors.blue,
        onPressed: (){
          Navigator.pushNamed(context, ResetPassword.id);
        },
      ),
    );
  }

  Future<FirebaseUser> signIn(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    final AuthResult result = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim()).catchError((err){
          print(err.message);
          scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(err.message, style: TextStyle(color: Colors.white),),
            backgroundColor: Colors.red,
          ));
          setState(() {
            _isLoading = false;
          });
    });
    if(result != null){
      setState(() {
        _isLoading = false;
      });
      Firestore.instance.collection('users')
          .where('userid', isEqualTo: result.user.uid)
          .snapshots()
          .listen((data) =>
        data.documents.forEach((doc) => {
          loggedUser.id = doc.documentID,
          loggedUser.name = doc['name'],
          loggedUser.email = doc['email'],
          loggedUser.photo = doc['photo'],
        })
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));

    }
  }
}
