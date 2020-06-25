import 'package:cloud_firestore/cloud_firestore.dart';

class User{
  var id, docid, group, name, email, photo, mobile, address;
  bool isChecked;
  User(){
    this.isChecked = false;
  }

  static User fromDocument(DocumentSnapshot doc){
    User user = User();
    user.docid = doc.documentID;
    user.id = doc.data['userid'];
    user.group = doc.data['group'];
    user.name = doc.data['name'];
    user.email = doc.data['email'];
    user.photo = doc.data['photo'];
    user.mobile = doc.data['mobile'];
    user.address = doc.data['address'];
  }

  String toString(){
    return "ID: $id " +
    "DocId: $docid " +
    "Group: $group " +
    "Name: $name " +
    "Email: $email " +
    "Photo: $photo " +
    "Mobile: $mobile " +
    "Address: $address ";
  }
}