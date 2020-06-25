import 'package:flutter/material.dart';

class Comment extends StatefulWidget {
  static String id = "comment_screen";
  @override
  _CommentState createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Comments"),
        centerTitle: true,
        elevation: 5.0,
      ),
      body: Container(
        child: Column(
          children: [
            TextFormField(
              maxLines: 10,
              keyboardType: TextInputType.text,
            ),
            RaisedButton(
              child: Text("Send"),
              onPressed: (){
                //
              },
            ),
          ],
        ),
      ),
    );
  }
}
