import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ResetPassword extends StatefulWidget {
  static String id = "reset_password_screen";
  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reset password"),
        centerTitle: true,
        elevation: 5.0,
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Form(
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                _showImage(),
                _buildEditextEmail(),
                _buildResetButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _showImage(){
    return Container(
      child: Icon(Icons.vpn_key, size: 100.0, color: Colors.grey[600],),
    );
  }
  Widget _buildEditextEmail(){
    return TextFormField(
      maxLines: 1,
      keyboardType: TextInputType.emailAddress,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Email',
        icon: Icon(Icons.mail),
      ),
      validator: (value) => value.isEmpty ? 'Please enter email': null,
      controller: emailController,
    );
  }
  Widget _buildResetButton(){
    return Padding(
      padding: EdgeInsets.fromLTRB(40.0, 50.0, 40.0, 0.0),
      child: RaisedButton(
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        onPressed: (){
          resetPassword();
        },
        child: Text("Reset mypassword", style: TextStyle(fontSize: 18.0, color: Colors.white),),
        color: Colors.blue,
      ),
    );
  }

  void resetPassword() {
    String email = emailController.text.trim();
    _auth.sendPasswordResetEmail(email: email).catchError((err){
      print(err.message);
    });
    scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text("We send the detail to $email please check your email.",
      style: TextStyle(color: Colors.white),),
      backgroundColor: Colors.green,
    ));
  }
}
