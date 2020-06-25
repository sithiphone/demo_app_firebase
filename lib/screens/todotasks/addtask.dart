import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demoappfirebase/models/task.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddTask extends StatefulWidget {
  static String id = "add_task_screen";
  @override
  _AddTaskState createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  Firestore firestore = Firestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController taskController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add task"),
        centerTitle: true,
        elevation: 5.0,
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
              children: <Widget>[
                TextFormField(
                  maxLines: 1,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: 'ໜ້າວຽກ',
                    icon: Icon(Icons.playlist_add_check),
                  ),
                  autofocus: true,
                  controller: taskController,
                ),
                SizedBox(height: 20.0,),
                RaisedButton(
                  child: Text("OK", style: TextStyle(fontSize: 20.0, color: Colors.white),),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  color: Colors.blue,
                  onPressed: (){
                    addTask();
                  },
                ),
              ],
          ),
        ),
      ),
    );
  }

  Future addTask() async{
    if(_formKey.currentState.validate()){
      _formKey.currentState.save();
      String task = taskController.text.trim();
      FirebaseUser _user = await _auth.currentUser();
      await firestore.collection('tasks').add(<String, dynamic>{
        'task' : task,
        'created_at' : FieldValue.serverTimestamp(),
        'userid' : _user.uid
      });
      Navigator.pop(context);
    }else{
      print("Task is empty!");
    }
  }

}
