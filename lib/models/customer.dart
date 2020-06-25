import 'package:cloud_firestore/cloud_firestore.dart';
class Customer {
  var userid, docid, customer_name, created_at;
  static Customer fromDocument(DocumentSnapshot doc){
    Customer customer = new Customer();
    customer.docid = doc.documentID;
    customer.userid = doc['user_id'];
    customer.customer_name = doc['customer_name'];
  }

  String toString(){
    return "UserID: $userid" + " Doc ID: $docid" + " Customer name: $customer_name";
  }
}