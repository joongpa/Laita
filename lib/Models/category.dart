class Category {
  String docID;
  String name;
  bool isTimeBased;

  Category({this.docID, this.name, this.isTimeBased});

  factory Category.fromMap(Map<String, dynamic> map, [String docID]) => Category(
    docID: docID,
    name: map['name'],
    isTimeBased: map['isTimeBased'],
  );

  Map<String, dynamic> toMap() => {
    'docID': docID,
    'name': name,
    'isTimeBased': isTimeBased,
  };
}