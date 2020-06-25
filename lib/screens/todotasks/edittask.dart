import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demoappfirebase/models/task.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditTask extends StatefulWidget {
  Task task;
  EditTask({this.task});
  static String id = "edit_task_screen";
  @override
  _EditTaskState createState() => _EditTaskState(task);
}

class _EditTaskState extends State<EditTask> {
  Task task;
  _EditTaskState(this.task);
  Firestore firestore = Firestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController taskController;

  @override
  void initState() {
    super.initState();
    taskController = new TextEditingController(text: task.task_name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit task"),
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
                    icon: Icon(Icons.mode_edit),
                  ),
                  autofocus: true,
                  controller: taskController,
                ),
                SizedBox(height: 20.0,),
                RaisedButton(
                  child: Text("Finish", style: TextStyle(fontSize: 20.0, color: Colors.white),),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  color: Colors.blue,
                  onPressed: (){
                    editTask();
                  },
                ),
              ],
          ),
        ),
      ),
    );
  }

  Future editTask() async{
    if(_formKey.currentState.validate()){
      _formKey.currentState.save();
      String taskEditText = taskController.text.trim();
      FirebaseUser _user = await _auth.currentUser();
      await firestore.collection('tasks').document(task.docid).updateData({
        'task' : taskEditText,
        'created_at' : FieldValue.serverTimestamp(),
        'userid' : _user.uid
      });
      Navigator.pop(context);
    }else{
      print("Task is empty!");
    }
  }
}
