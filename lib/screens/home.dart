import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demoappfirebase/models/customer.dart';
import 'package:demoappfirebase/models/user.dart';
import 'package:demoappfirebase/screens/AppDrawer.dart';
import 'package:demoappfirebase/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  static String id = "home_screen";
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  FirebaseUser user;
  FirebaseAuth _auth = FirebaseAuth.instance;
  Firestore firestore = Firestore.instance;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  User loggedUser = new User();
  Map<String, String> customer = Map<String, String>();
  List<Map> customers = List<Map>();
  TextEditingController _customerController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLogedUser();
    getCustomers();
    print(customers);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            color: Colors.white,
            onPressed: (){
              signOut(context);
            },
          ),
        ],
        centerTitle: true,
        elevation: 5.0,
      ),
      body: Container(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Text("HOME SCREEN",
                style: TextStyle(
                    fontSize: 30.0,
                    color: Colors.blue
                ),
              ),
              TextFormField(
                maxLines: 1,
                keyboardType: TextInputType.text,
                autofocus: true,
                controller: _customerController,
                decoration: InputDecoration(
                  icon: Icon(Icons.person),
                  hintText: 'Name',
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  RaisedButton(
                    child: Text("Search"),
                    onPressed: (){
                    },
                  ),
                  RaisedButton(
                    child: Text("Add"),
                    onPressed: (){
                      addCustomer();
                    },
                  ),
                ],
              ),
              Container(
                height: 44.0,
                child: ListView.builder(
                    itemCount: customers.length,
                    itemBuilder: (context, index){
                      return ListTile(
                        leading: Icon(Icons.person),
//                        title: Text(customers[index].customer_name),
                      );
                })
              ),
            ],
          ),
        ),
      ),
      drawer: AppDrawer(),
    );
  }

  getCustomers() async {
    user = await _auth.currentUser();
    print("USER_ID: " + user.uid);
    await firestore.collection('customers').orderBy('created_at', descending: false).snapshots().forEach((data) {
      customers.clear();
      data.documents.forEach((doc) {
//        print(doc['customer_name']);
        customer = {
          'docid' : doc.documentID,
          'customer_name' : doc['customer_name'],
          'user_id' : doc['user_id'],
          'created_at' : doc['created_at'].toString()
        };
      });
      setState(() {
        customers.add(customer);
      });
    });
  }

   getLogedUser() async {
    user = await _auth.currentUser();
     Firestore.instance.collection('users').where('userid', isEqualTo: user.uid).snapshots().listen((data)=>
      data.documents.forEach((doc) => {
        loggedUser.id = user.uid,
        loggedUser.name = doc['name'],
        loggedUser.email = doc['email'],
        loggedUser.photo = doc['photo'],
      })
    );
  }
  void signOut(BuildContext context){
    _auth.signOut();
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => Login()),
        ModalRoute.withName('/login'));
  }

  Future addCustomer() async {
    if(_formKey.currentState.validate()){
      _formKey.currentState.save();
      String customer = _customerController.text.trim();
      FirebaseUser _user = await _auth.currentUser();
      await firestore.collection('customers').add(<String, dynamic>{
        'customer_name': customer,
        'created_at': FieldValue.serverTimestamp(),
        'user_id': _user.uid
      });
      getCustomers();
    }
  }
}
