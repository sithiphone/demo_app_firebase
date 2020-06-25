import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demoappfirebase/models/task.dart';
import 'package:demoappfirebase/screens/todotasks/addtask.dart';
import 'package:demoappfirebase/screens/todotasks/edittask.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class TodoHome extends StatefulWidget {
  static String id = "todo_home_screen";
  @override
  _TodoHomeState createState() => _TodoHomeState();
}
enum ConfirmDelete {CANCEL, OK}

class _TodoHomeState extends State<TodoHome> {
  int _selectedIndex = 0;
  var tasks = List<Task>();
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser _user;
  Firestore firestore = Firestore.instance;
  var deleteItems = List<String>();
  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Add',
      style: optionStyle,
    ),
    Text(
      'Index 1: Delete',
      style: optionStyle,
    ),
  ];
  void _onItemTapped(int index){
    setState(() {
      _selectedIndex = index;
    });
    switch (index){
      case 0:
        Navigator.pushNamed(context, AddTask.id);
        break;
      case 1:
        if(!deleteItems.isEmpty)
        _asyncComfirmDeleteDialog(context);
        break;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tasks"),
        centerTitle: true,
        elevation: 5.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.file_download),
            onPressed: (){
              setState(() {
                deleteItems.clear();
              });
            },
          )
        ],
      ),
      body: StreamBuilder(
        stream: firestore.collection('tasks').orderBy('created_at', descending: false).snapshots(),
        builder: (context, snapshot){
          if(!snapshot.hasData){
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.blue[500],
              ),
            );
          }else{
            List<DocumentSnapshot> docs_tasks = snapshot.data.documents;
//            print(docs_tasks.length);
            tasks.clear();
            docs_tasks.forEach((v) {
              Task task = new Task();
              task.docid = v.documentID;
              task.task_name = v.data['task'];
              task.userid = v.data['userid'];
              tasks.add(task);
            });
            return ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index){
                return Dismissible(
                  key: Key(tasks[index].docid),
                  background: Container(color: Colors.red),
                  onDismissed: (direction) async{
                    deleteTask(tasks[index].docid, index);
                  },
                  child: ListTile(leading: deleteItems.contains(tasks[index].docid)? Icon(Icons.check_box) : Icon(Icons.check_box_outline_blank),
                    title: Text(tasks[index].task_name),
                    subtitle: Text(tasks[index].docid),
                    onTap: (){
                      setState(() {
                        if(deleteItems.contains(tasks[index].docid)){
                          deleteItems.remove(tasks[index].docid);
                        }else{
                          deleteItems.add(tasks[index].docid);
                        }
                        deleteItems.forEach((v) => print(v));
                      });
                    },
                    trailing: GestureDetector(
                      child: Icon(Icons.edit, color: Colors.blue,),
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context){
                          Task task = new Task();
                          task = tasks[index];
                          task.docid = tasks[index].docid;
                          task.task_name = tasks[index].task_name;
                          task.userid = tasks[index].userid;
                          return EditTask(task: task);
                        }));
                      },
                    ),),
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, color: Colors.white, size: 50.0,),
            title: Text("Add"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.remove_circle, color: Colors.white, size: 50.0,),
            title: Text("Delete"),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        onTap: _onItemTapped,
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<ConfirmDelete> _asyncComfirmDeleteDialog(BuildContext context) async {
    return showDialog<ConfirmDelete>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0)
          ),
          title: Text('Delete confirmation!'),
          content: const Text(
              'Are you sure to delete this task?'),
          actions: <Widget>[
            FlatButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop(ConfirmDelete.CANCEL);
                setState(() {});
              },
            ),
            FlatButton(
              child: const Text('OK'),
              onPressed: () {
                deleteItems.forEach((doc){
                  firestore.collection('tasks').document(doc).delete().then((msg){
                    deleteItems.remove(doc);
                  });
                });
                Navigator.of(context).pop(ConfirmDelete.OK);
              },
            )
          ],
        );
      },
    );
  }

  void deleteTask(String doc_id, int index) async{
    await Firestore.instance.collection('tasks').document(doc_id).delete().then((_){
      deleteItems.remove(doc_id);
    });
  }


}
