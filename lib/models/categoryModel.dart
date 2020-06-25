class CategoryModel {
  var docid, name, created_at;

  CategoryModel({this.docid, this.name, this.created_at});

  @override
  String toString() {
    // TODO: implement toString
    return "DocID: $docid, Name: $name, Created_at: $created_at";
  }
}