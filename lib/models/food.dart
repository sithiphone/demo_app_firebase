class Food {
  var docid, name, price, old_price, photo, created_at;

  Food({this.docid, this.name, this.photo, this.price});

  @override
  String toString() {
    return "DocID: $docid, Name: $name, Price: $price, Photo: $photo";
  }
}