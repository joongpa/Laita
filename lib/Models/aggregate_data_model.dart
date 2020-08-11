
import '../Map.dart';
import 'dart:math' as math;

class DailyInputEntry {
  String docID;
  DateTime dateTime;
  Map<String, dynamic> categoryHours;
  Map<String, dynamic> goalAmounts;

  DailyInputEntry({this.docID, this.dateTime, this.categoryHours, this.goalAmounts}) {
    this.dateTime = daysAgo(0, dateTime);
  }

  factory DailyInputEntry.fromMap(Map<String, dynamic> map, [String docID]) {
    if(map == null) return null;
    return DailyInputEntry(
    docID: docID,
    dateTime: (map['dateTime'] != null) ? map['dateTime'].toDate() : null,
    categoryHours: map['categoryHours'],
    goalAmounts: map['goalAmounts']
  );
  }

  Map<String, dynamic> toMap() => {
    "docID": docID,
    "dateTime": dateTime,
    "categoryHours": categoryHours,
    'goalAmounts': goalAmounts,
  };

  @override
  bool operator ==(other) {
    return other is DailyInputEntry && sameDay(dateTime, other.dateTime);
  }

  @override
  int get hashCode => dateTime.hashCode;

}