
import '../Map.dart';
import 'category.dart';

class DailyInputEntry {
  String docID;
  DateTime dateTime;
  Map<String, double> categoryHours;

  DailyInputEntry({this.docID, dateTime, this.categoryHours}) {
    this.dateTime = daysAgo(0, dateTime);
  }

  factory DailyInputEntry.fromMap(Map<String, dynamic> map, [String docID]) => DailyInputEntry(
    docID: docID,
    dateTime: map['dateTime'],
    categoryHours: map['categoryHours'],
  );

  Map<String, dynamic> toMap() => {
    "docID": docID,
    "dateTime": dateTime,
    "categoryHours": categoryHours,
  };

}