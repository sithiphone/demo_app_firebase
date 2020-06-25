import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demoappfirebase/screens/AppDrawer.dart';
import 'package:demoappfirebase/screens/categories/addcategory.dart';
import 'package:demoappfirebase/screens/categories/editCategory.dart';
import 'package:flutter/material.dart';

class Category extends StatefulWidget {
  static String id = "category_screen";
  @override
  _CategoryState createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  Firestore firestore = Firestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Categories"),
        centerTitle: true,
        elevation: 5.0,
      ),
      body: Container(
        child: StreamBuilder(
          stream: firestore.collection('categories').orderBy('created_at', descending: false).snapshots(),
          builder: (context, snapshot){
            List<DocumentSnapshot> categories = snapshot.data.documents;
            if(!snapshot.hasData){
              return Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.blue,
                ),
              );
            }else{
              return ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index){
                    int no = index + 1;
                    String docid = categories[index].documentID;
                    return Dismissible(
                      key: Key(docid),
                      onDismissed: (direction) async {
                        await firestore.collection('categories').document(docid).delete();
                      },
                      background: Container(color: Colors.redAccent,),
                      child: Card(
                        child: ListTile(
                          title: Text(categories[index].data['name'], style: TextStyle(fontSize: 20.0),),
                          leading: CircleAvatar(
                            child: Text(no.toString()),
                            radius: 16.0,
                          ),
                          trailing: IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: (){
                                String category = categories[index].data['name'];
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>EditCategory(docid: docid, category: category)));
                              }
                          ),
                        ),
                      ),
                    );
                  }
              );
            }
          },
        ),
      ),
      drawer: AppDrawer(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
        onPressed: (){
          Navigator.pushNamed(context, AddCategory.id);
        },
      ),
    );
  }
}
