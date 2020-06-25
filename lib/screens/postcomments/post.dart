import 'package:demoappfirebase/screens/postcomments/comment.dart';
import 'package:flutter/material.dart';

class Post extends StatefulWidget {
  static String id = "post_screen";
  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Post"),
        centerTitle: true,
        elevation: 5.0,
      ),
      body: Container(
        child: Column(
          children: [
            Card(
              semanticContainer: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: Image.network(
                'https://placeimg.com/640/480/any',
                fit: BoxFit.fill,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 5,
              margin: EdgeInsets.all(10),
            ),
            Card(
              child: ButtonBar(
                children: [
                  RaisedButton(
                    child: Text("Like"),
                    onPressed: (){

                    },
                  ),
                  RaisedButton(
                    child: Text("Comments"),
                    onPressed: (){
                      Navigator.pushNamed(context, Comment.id);
                    },
                  ),
                  RaisedButton(
                    child: Text("Shear"),
                    onPressed: (){

                    },
                  ),
                ],
              ),
            ),
          ],
        )
      ),
    );
  }
}
