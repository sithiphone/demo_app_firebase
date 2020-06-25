import 'package:cloud_firestore/cloud_firestore.dart';
class Task {
  var userid, docid, task_name;
  static Task fromDocument(DocumentSnapshot doc){
    Task task = new Task();
    task.docid = doc.documentID;
    task.userid = doc['user_id'];
    task.task_name = doc['task_name'];
  }
  String toString(){
    return "User_ID: $userid " +
        "Doc_ID: $docid " +
        "Task: $task_name";
  }
}