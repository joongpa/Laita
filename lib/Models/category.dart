class Category {
  String docID;
  String name;
  bool isTimeBased;
  DateTime dateTime;

  Category({this.docID, this.name, this.isTimeBased, this.dateTime});

  factory Category.fromMap(Map<String, dynamic> map, [String docID]) => Category(
    docID: docID,
    name: map['name'],
    isTimeBased: map['isTimeBased'],
    dateTime: map['dateTime'].toDate(),
  );

  Map<String, dynamic> toMap() => {
    'docID': docID,
    'name': name,
    'isTimeBased': isTimeBased,
    'dateTime': dateTime,
  };
}